import 'dart:collection';
import 'dart:async';

import 'package:app_links/app_links.dart';

class OAuthCallbackEvent {
  const OAuthCallbackEvent({
    required this.status,
    required this.providerId,
    required this.connectionId,
    this.error,
  });

  final String status;
  final String providerId;
  final String connectionId;
  final String? error;

  bool get isSuccess => status.toLowerCase() == 'success';
}

class OAuthDeepLinkService {
  OAuthDeepLinkService();
  static const int _maxPendingEvents = 1;
  static const Set<String> _allowedStatuses = {'success', 'error', 'cancelled'};
  static const Set<String> _allowedErrorCodes = {
    'access_denied',
    'invalid_state',
    'provider_unavailable',
    'connection_failed',
    'malformed_callback',
  };

  final AppLinks _appLinks = AppLinks();
  final Queue<OAuthCallbackEvent> _pendingEvents = Queue<OAuthCallbackEvent>();
  late final StreamController<OAuthCallbackEvent> _events =
      StreamController<OAuthCallbackEvent>.broadcast(
        onListen: _flushPendingEvents,
      );

  StreamSubscription<Uri>? _subscription;
  bool _initialized = false;

  Stream<OAuthCallbackEvent> get events => _events.stream;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final initialUri = await _appLinks.getInitialLink();
      _handleUri(initialUri);
    } catch (_) {
      // Ignore initial deep-link failures to keep app startup resilient.
    }

    _subscription = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (_) {
        // Ignore stream errors and keep the app running.
      },
    );
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _events.close();
  }

  void _handleUri(Uri? uri) {
    if (uri == null) return;
    if (uri.scheme.toLowerCase() != 'cloudvault') return;
    if (uri.host.toLowerCase() != 'oauth-callback') return;

    final status = uri.queryParameters['status']?.trim() ?? '';
    final providerId = uri.queryParameters['providerId']?.trim() ?? '';
    final connectionId = uri.queryParameters['connectionId']?.trim() ?? '';
    final error = uri.queryParameters['error']?.trim();

    if (status.isEmpty) return;
    final normalizedStatus = status.toLowerCase();
    if (!_allowedStatuses.contains(normalizedStatus)) {
      _emit(
        OAuthCallbackEvent(
          status: 'error',
          providerId: providerId,
          connectionId: connectionId,
          error: 'invalid_status',
        ),
      );
      return;
    }

    final normalizedError = _normalizeErrorCode(error);

    if (normalizedStatus == 'success' &&
        (providerId.isEmpty || connectionId.isEmpty)) {
      _emit(
        OAuthCallbackEvent(
          status: 'error',
          providerId: providerId,
          connectionId: connectionId,
          error: 'malformed_callback',
        ),
      );
      return;
    }

    if (normalizedStatus != 'success' && normalizedError == null) {
      _emit(
        OAuthCallbackEvent(
          status: normalizedStatus,
          providerId: providerId,
          connectionId: connectionId,
          error: 'connection_failed',
        ),
      );
      return;
    }

    _emit(
      OAuthCallbackEvent(
        status: normalizedStatus,
        providerId: providerId,
        connectionId: connectionId,
        error: normalizedError,
      ),
    );
  }

  String? _normalizeErrorCode(String? rawError) {
    if (rawError == null || rawError.isEmpty) return null;
    var normalized = rawError.toLowerCase().trim();
    normalized = normalized.replaceAll(RegExp(r'[^a-z0-9_]+'), '_');
    normalized = normalized.replaceAll(RegExp(r'_+'), '_');
    normalized = normalized.replaceAll(RegExp(r'^_+|_+$'), '');
    if (normalized.isEmpty) return null;
    if (!_allowedErrorCodes.contains(normalized)) return null;
    return normalized;
  }

  void _emit(OAuthCallbackEvent event) {
    if (_events.hasListener) {
      _events.add(event);
      return;
    }
    while (_pendingEvents.length >= _maxPendingEvents) {
      _pendingEvents.removeFirst();
    }
    _pendingEvents.add(event);
  }

  void _flushPendingEvents() {
    while (_events.hasListener && _pendingEvents.isNotEmpty) {
      _events.add(_pendingEvents.removeFirst());
    }
  }
}

final OAuthDeepLinkService appOAuthDeepLinkService = OAuthDeepLinkService();
