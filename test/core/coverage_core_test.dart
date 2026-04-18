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

  group('ApiClient', () {
    late QueuedHttpClient httpClient;
    late ApiClient apiClient;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      await AuthSession.instance.clearTokens();
      httpClient = QueuedHttpClient();
      apiClient = ApiClient(httpClient: httpClient);
    });

    test('getJson sends query and auth headers and parses JSON map', () async {
      await AuthSession.instance.setTokens(
        bearerToken: 'bearer-123',
        appCheckToken: 'app-check-123',
      );
      httpClient.enqueue((http.BaseRequest request) {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/test-get');
        expect(request.url.queryParameters['page'], '2');
        expect(request.headers['Authorization'], 'Bearer bearer-123');
        expect(request.headers['X-Firebase-AppCheck'], 'app-check-123');
        expect(request.headers['Content-Type'], 'application/json');
        return streamedJsonResponse(200, <String, dynamic>{'ok': true});
      });

      final Map<String, dynamic> response = await apiClient.getJson(
        '/test-get',
        query: const <String, String>{'page': '2'},
      );

      expect(response['ok'], true);
    });

    test('postJson wraps non-map json body into data field', () async {
      httpClient.enqueue((http.BaseRequest request) async {
        expect(request.method, 'POST');
        final Map<String, dynamic> payload = await decodeJsonRequest(request);
        expect(payload['query'], 'report');
        return streamedTextResponse(200, '[1,2,3]');
      });

      final Map<String, dynamic> response = await apiClient.postJson(
        '/test-post',
        body: const <String, dynamic>{'query': 'report'},
      );

      expect(response['data'], <dynamic>[1, 2, 3]);
    });

    test('deleteJson handles empty body as empty map', () async {
      httpClient.enqueue((http.BaseRequest request) {
        expect(request.method, 'DELETE');
        return streamedTextResponse(200, '');
      });

      final Map<String, dynamic> response = await apiClient.deleteJson(
        '/test-delete',
      );

      expect(response, isEmpty);
    });

    test('postJson throws ApiException on non-2xx status', () async {
      httpClient.enqueue(
        (_) => streamedTextResponse(500, '{"error":"failed"}'),
      );

      await expectLater(
        apiClient.postJson('/test-error'),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'statusCode', 500)
              .having((ApiException e) => e.body, 'body', contains('failed')),
        ),
      );
    });

    test('postJson rethrows decode exceptions for invalid JSON', () async {
      httpClient.enqueue((_) => streamedTextResponse(200, '{invalid-json'));

      await expectLater(
        apiClient.postJson('/test-invalid-json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('postJson maps network errors to ApiException', () async {
      httpClient.enqueue((_) {
        throw StateError('network failed');
      });

      await expectLater(
        apiClient.postJson('/test-network-fail'),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.message,
            'message',
            'Network request failed',
          ),
        ),
      );
    });

    test('401 response attempts refresh and still fails when refresh is unavailable', () async {
      httpClient.enqueue((_) => streamedTextResponse(401, '{"error":"expired"}'));

      await expectLater(
        apiClient.getJson('/test-401'),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
    });

    test('refreshBearerToken returns false without a valid firebase user context', () async {
      final bool refreshed = await apiClient.refreshBearerToken();
      expect(refreshed, isFalse);
    });

    test('postBytes returns binary response payload', () async {
      httpClient.enqueue(
        (_) => streamedBytesResponse(200, <int>[1, 2, 3, 4]),
      );

      final List<int> bytes = await apiClient.postBytes('/test-bytes');

      expect(bytes, <int>[1, 2, 3, 4]);
    });

    test('postBytes throws ApiException on non-2xx response', () async {
      httpClient.enqueue(
        (_) => streamedTextResponse(404, 'not-found'),
      );

      await expectLater(
        apiClient.postBytes('/test-bytes-fail'),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'statusCode', 404)
              .having((ApiException e) => e.body, 'body', contains('not-found')),
        ),
      );
    });

    test('postBytesCapped returns bytes when response fits max size', () async {
      httpClient.enqueue(
        (_) => streamedBytesResponse(200, <int>[9, 8, 7]),
      );

      final List<int> bytes = await apiClient.postBytesCapped(
        '/test-capped-ok',
        maxBytes: 16,
      );

      expect(bytes, <int>[9, 8, 7]);
    });

    test('postBytesCapped throws max size error when payload is too large', () async {
      httpClient.enqueue(
        (_) => http.StreamedResponse(
          Stream<List<int>>.fromIterable(<List<int>>[
            <int>[1, 2, 3],
            <int>[4, 5, 6],
          ]),
          200,
          contentLength: 6,
        ),
      );

      await expectLater(
        apiClient.postBytesCapped('/test-capped-overflow', maxBytes: 4),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'statusCode', 413)
              .having(
                (ApiException e) => e.errorCode,
                'errorCode',
                'max_preview_size_exceeded',
              ),
        ),
      );
    });

    test('postBytesCapped reads server error body for non-2xx responses', () async {
      httpClient.enqueue(
        (_) => streamedTextResponse(500, 'preview failed'),
      );

      await expectLater(
        apiClient.postBytesCapped('/test-capped-http-fail', maxBytes: 32),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'statusCode', 500)
              .having(
                (ApiException e) => e.body,
                'body',
                contains('preview failed'),
              ),
        ),
      );
    });

    test('postBytesCapped maps send timeout into request_timeout', () async {
      httpClient.enqueue((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return streamedBytesResponse(200, <int>[1]);
      });

      await expectLater(
        apiClient.postBytesCapped(
          '/test-capped-send-timeout',
          maxBytes: 10,
          timeout: const Duration(milliseconds: 5),
        ),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.errorCode,
            'errorCode',
            'request_timeout',
          ),
        ),
      );
    });

    test('postBytesCapped maps stream timeout into request_timeout', () async {
      httpClient.enqueue(
        (_) => http.StreamedResponse(
          Stream<List<int>>.fromFuture(
            Future<List<int>>.delayed(
              const Duration(milliseconds: 40),
              () => <int>[1, 2, 3],
            ),
          ),
          200,
        ),
      );

      await expectLater(
        apiClient.postBytesCapped(
          '/test-capped-stream-timeout',
          maxBytes: 20,
          timeout: const Duration(milliseconds: 5),
        ),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.errorCode,
            'errorCode',
            'request_timeout',
          ),
        ),
      );
    });

    test('postMultipart validates missing payload', () async {
      await expectLater(
        apiClient.postMultipart(
          '/multipart',
          fields: const <String, String>{'a': '1'},
          fileField: 'file',
          fileName: 'x.bin',
        ),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.message,
            'message',
            contains('missing'),
          ),
        ),
      );
    });

    test('postMultipart validates stream metadata', () async {
      await expectLater(
        apiClient.postMultipart(
          '/multipart',
          fields: const <String, String>{},
          fileField: 'file',
          fileStream: Stream<List<int>>.fromIterable(<List<int>>[
            <int>[1],
          ]),
          fileName: 'x.bin',
        ),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.message,
            'message',
            contains('non-null fileLength'),
          ),
        ),
      );

      await expectLater(
        apiClient.postMultipart(
          '/multipart',
          fields: const <String, String>{},
          fileField: 'file',
          fileStream: Stream<List<int>>.fromIterable(<List<int>>[
            <int>[1],
          ]),
          fileLength: -1,
          fileName: 'x.bin',
        ),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.message,
            'message',
            contains('invalid fileLength'),
          ),
        ),
      );
    });

    test('postMultipart sends bytes payload and parses JSON response', () async {
      await AuthSession.instance.setTokens(bearerToken: 'multipart-token');
      httpClient.enqueue((http.BaseRequest request) {
        expect(request, isA<http.MultipartRequest>());
        final http.MultipartRequest multipart = request as http.MultipartRequest;
        expect(multipart.fields['kind'], 'avatar');
        expect(multipart.files, hasLength(1));
        expect(multipart.files.single.filename, 'avatar.png');
        expect(multipart.headers['Authorization'], 'Bearer multipart-token');
        return streamedJsonResponse(200, <String, dynamic>{'ok': true});
      });

      final Map<String, dynamic> result = await apiClient.postMultipart(
        '/multipart-success',
        fields: const <String, String>{'kind': 'avatar'},
        fileField: 'file',
        fileBytes: Uint8List.fromList(<int>[1, 2, 3]),
        fileName: 'avatar.png',
      );

      expect(result['ok'], true);
    });

    test('postMultipart supports filePath payload branch', () async {
      final File tempFile = File(
        '${Directory.systemTemp.path}${Platform.pathSeparator}api_client_upload_test.txt',
      );
      addTearDown(() async {
        if (await tempFile.exists()) {
          await tempFile.delete();
        }
      });
      await tempFile.writeAsString('test-file');

      httpClient.enqueue((http.BaseRequest request) {
        final http.MultipartRequest multipart = request as http.MultipartRequest;
        expect(multipart.files.single.filename, 'upload.txt');
        return streamedJsonResponse(200, <String, dynamic>{'path': 'ok'});
      });

      final Map<String, dynamic> result = await apiClient.postMultipart(
        '/multipart-path',
        fields: const <String, String>{'kind': 'file'},
        fileField: 'file',
        filePath: '  ${tempFile.path}  ',
        fileName: 'upload.txt',
      );

      expect(result['path'], 'ok');
    });

    test('postMultipart supports stream payload branch', () async {
      httpClient.enqueue((http.BaseRequest request) {
        final http.MultipartRequest multipart = request as http.MultipartRequest;
        expect(multipart.files.single.length, 3);
        return streamedJsonResponse(200, <String, dynamic>{'stream': true});
      });

      final Map<String, dynamic> result = await apiClient.postMultipart(
        '/multipart-stream',
        fields: const <String, String>{'kind': 'stream'},
        fileField: 'file',
        fileStream: Stream<List<int>>.fromIterable(<List<int>>[
          <int>[1, 2, 3],
        ]),
        fileLength: 3,
        fileName: 'stream.bin',
      );

      expect(result['stream'], true);
    });

    test('postMultipart throws ApiException for non-2xx responses', () async {
      httpClient.enqueue((_) => streamedTextResponse(403, 'forbidden'));

      await expectLater(
        apiClient.postMultipart(
          '/multipart-fail',
          fields: const <String, String>{'kind': 'file'},
          fileField: 'file',
          fileBytes: Uint8List.fromList(<int>[1]),
          fileName: 'x.bin',
        ),
        throwsA(
          isA<ApiException>()
              .having((ApiException e) => e.statusCode, 'statusCode', 403)
              .having(
                (ApiException e) => e.body,
                'body',
                contains('forbidden'),
              ),
        ),
      );
    });

    test('postMultipart maps send timeout into request_timeout', () async {
      httpClient.enqueue((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return streamedJsonResponse(200, <String, dynamic>{'ok': true});
      });

      await expectLater(
        apiClient.postMultipart(
          '/multipart-timeout',
          fields: const <String, String>{},
          fileField: 'file',
          fileBytes: Uint8List.fromList(<int>[1]),
          fileName: 'x.bin',
          timeout: const Duration(milliseconds: 5),
        ),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.errorCode,
            'errorCode',
            'request_timeout',
          ),
        ),
      );
    });

    test('postMultipart maps network failures into ApiException', () async {
      httpClient.enqueue((_) {
        throw StateError('socket error');
      });

      await expectLater(
        apiClient.postMultipart(
          '/multipart-network-fail',
          fields: const <String, String>{},
          fileField: 'file',
          fileBytes: Uint8List.fromList(<int>[1]),
          fileName: 'x.bin',
        ),
        throwsA(
          isA<ApiException>().having(
            (ApiException e) => e.message,
            'message',
            'Network request failed',
          ),
        ),
      );
    });

    test('postMultipart rethrows decode exceptions for invalid JSON', () async {
      httpClient.enqueue((_) => streamedTextResponse(200, '{broken-json'));

      await expectLater(
        apiClient.postMultipart(
          '/multipart-invalid-json',
          fields: const <String, String>{},
          fileField: 'file',
          fileBytes: Uint8List.fromList(<int>[1]),
          fileName: 'x.bin',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('postMultipart returns empty map for empty response body', () async {
      httpClient.enqueue((_) => streamedTextResponse(200, ''));

      final Map<String, dynamic> result = await apiClient.postMultipart(
        '/multipart-empty',
        fields: const <String, String>{},
        fileField: 'file',
        fileBytes: Uint8List.fromList(<int>[1]),
        fileName: 'x.bin',
      );

      expect(result, isEmpty);
    });
  });
}
