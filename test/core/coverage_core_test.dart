import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_vault/api/api_client.dart';
import 'package:cloud_vault/api/api_config.dart';
import 'package:cloud_vault/api/api_exception.dart';
import 'package:cloud_vault/api/auth_session.dart';
import 'package:cloud_vault/data/oauth_callback_handler.dart';
import 'package:cloud_vault/data/oauth_deep_link_service.dart';
import 'package:cloud_vault/state/locale_controller.dart';
import 'package:cloud_vault/state/theme_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_http_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiConfig and ApiException', () {
    test('resolveApiUri normalizes slashes and query parameters', () {
      final Uri uri = ApiConfig.resolveApiUri(
        '/files/list',
        queryParameters: <String, String>{'page': '2'},
      );

      expect(uri.toString(), 'http://localhost:3000/v1/files/list?page=2');
    });

    test('ApiException.toString formats message with code and error code', () {
      final ApiException exception = ApiException(
        'failed',
        statusCode: 401,
        errorCode: 'token_expired',
      );

      expect(exception.toString(), 'failed (401) [token_expired]');
    });
  });

  group('AuthSession', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await AuthSession.instance.clearTokens();
    });

    test('init reads persisted tokens from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'api_bearer_token': 'persisted-bearer',
        'api_app_check_token': 'persisted-app-check',
      });

      await AuthSession.instance.init();

      expect(AuthSession.instance.bearerToken, 'persisted-bearer');
      expect(AuthSession.instance.appCheckToken, 'persisted-app-check');
    });

    test('setTokens and clearTokens update in-memory values', () async {
      await AuthSession.instance.setTokens(
        bearerToken: 'token-1',
        appCheckToken: 'app-check-1',
      );

      expect(AuthSession.instance.bearerToken, 'token-1');
      expect(AuthSession.instance.appCheckToken, 'app-check-1');

      await AuthSession.instance.clearTokens();

      expect(AuthSession.instance.bearerToken, isNot('token-1'));
      expect(AuthSession.instance.appCheckToken, isNot('app-check-1'));
    });
  });

  group('LocaleController', () {
    test('init loads supported persisted locale', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'app_locale': 'en',
      });
      final LocaleController controller = LocaleController();
      int notifications = 0;
      controller.addListener(() {
        notifications += 1;
      });

      await controller.init();

      expect(controller.locale.languageCode, 'en');
      expect(notifications, 1);
    });

    test('setLocale ignores unsupported values and updates supported values', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final LocaleController controller = LocaleController();
      await controller.init();

      await controller.setLocale('de');
      expect(controller.locale.languageCode, 'uk');

      await controller.setLocale('en');
      expect(controller.locale.languageCode, 'en');
    });
  });

  group('ThemeController', () {
    test('init reads persisted light mode', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'theme_mode': 'light',
      });
      final ThemeController controller = ThemeController();

      await controller.init();

      expect(controller.isDarkMode, isFalse);
    });

    test('toggleTheme flips value and persists state', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final ThemeController controller = ThemeController();
      await controller.init();

      await controller.toggleTheme();
      expect(controller.isDarkMode, isFalse);

      await controller.toggleTheme();
      expect(controller.isDarkMode, isTrue);
    });
  });

  group('OAuth callback handler', () {
    test('success event with connected storage shows success message', () async {
      final List<String> messages = <String>[];
      final List<String> errors = <String>[];

      await handleOAuthCallbackEvent(
        event: const OAuthCallbackEvent(
          status: 'success',
          providerId: 'google-drive',
          connectionId: 'c1',
        ),
        refreshOnSuccess: () async => true,
        hasConnection: (_) => true,
        showMessage: messages.add,
        showErrorWithRetry: (message, _) => errors.add(message),
        onRetry: () async {},
      );

      expect(messages.single, 'Google Drive connected successfully');
      expect(errors, isEmpty);
    });

    test('success event with missing connection shows delayed callback message', () async {
      final List<String> messages = <String>[];

      await handleOAuthCallbackEvent(
        event: const OAuthCallbackEvent(
          status: 'success',
          providerId: 'dropbox',
          connectionId: 'c1',
        ),
        refreshOnSuccess: () async => true,
        hasConnection: (_) => false,
        showMessage: messages.add,
        showErrorWithRetry: (_, __) {},
        onRetry: () async {},
      );

      expect(
        messages.single,
        'Connection callback received, but storage is not available yet',
      );
    });

    test('cancelled event maps known and unknown error codes', () async {
      final List<String> messages = <String>[];

      await handleOAuthCallbackEvent(
        event: const OAuthCallbackEvent(
          status: 'cancelled',
          providerId: 'dropbox',
          connectionId: 'c1',
          error: 'access_denied',
        ),
        refreshOnSuccess: () async => true,
        hasConnection: (_) => false,
        showMessage: messages.add,
        showErrorWithRetry: (_, __) {},
        onRetry: () async {},
      );

      await handleOAuthCallbackEvent(
        event: const OAuthCallbackEvent(
          status: 'cancelled',
          providerId: 'dropbox',
          connectionId: 'c1',
          error: 'other',
        ),
        refreshOnSuccess: () async => true,
        hasConnection: (_) => false,
        showMessage: messages.add,
        showErrorWithRetry: (_, __) {},
        onRetry: () async {},
      );

      expect(
        messages,
        <String>['Authorization was cancelled', 'Connection was cancelled'],
      );
    });

    test('error event reports mapped message and exposes retry callback', () async {
      final List<String> errors = <String>[];
      int retryCalls = 0;
      Future<void> Function()? capturedRetry;

      Future<void> onRetry() async {
        retryCalls += 1;
      }

      await handleOAuthCallbackEvent(
        event: const OAuthCallbackEvent(
          status: 'error',
          providerId: 'dropbox',
          connectionId: 'c1',
          error: 'invalid_state',
        ),
        refreshOnSuccess: () async => true,
        hasConnection: (_) => false,
        showMessage: (_) {},
        showErrorWithRetry: (message, retry) {
          errors.add(message);
          capturedRetry = retry;
        },
        onRetry: onRetry,
      );

      expect(errors.single, 'Authorization state is invalid. Please retry');
      expect(capturedRetry, isNotNull);

      await capturedRetry!.call();
      expect(retryCalls, 1);
    });

    test('success event with failed refresh does nothing', () async {
      final List<String> messages = <String>[];
      final List<String> errors = <String>[];

      await handleOAuthCallbackEvent(
        event: const OAuthCallbackEvent(
          status: 'success',
          providerId: 'dropbox',
          connectionId: 'c1',
        ),
        refreshOnSuccess: () async => false,
        hasConnection: (_) => true,
        showMessage: messages.add,
        showErrorWithRetry: (message, _) => errors.add(message),
        onRetry: () async {},
      );

      expect(messages, isEmpty);
      expect(errors, isEmpty);
    });

    test('unknown error code maps to generic oauth failure', () async {
      String? errorMessage;

      await handleOAuthCallbackEvent(
        event: const OAuthCallbackEvent(
          status: 'error',
          providerId: 'dropbox',
          connectionId: 'c1',
          error: 'something_unexpected',
        ),
        refreshOnSuccess: () async => true,
        hasConnection: (_) => false,
        showMessage: (_) {},
        showErrorWithRetry: (message, _) => errorMessage = message,
        onRetry: () async {},
      );

      expect(errorMessage, 'OAuth connect failed');
    });
  });

}
