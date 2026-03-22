import 'provider_labels.dart';
import 'oauth_deep_link_service.dart';

typedef OAuthRefreshFn = Future<bool> Function();
typedef OAuthHasConnectionFn = bool Function(String connectionId);
typedef OAuthShowMessageFn = void Function(String message);
typedef OAuthShowErrorWithRetryFn =
    void Function(String message, Future<void> Function() onRetry);

Future<void> handleOAuthCallbackEvent({
  required OAuthCallbackEvent event,
  required OAuthRefreshFn refreshOnSuccess,
  required OAuthHasConnectionFn hasConnection,
  required OAuthShowMessageFn showMessage,
  required OAuthShowErrorWithRetryFn showErrorWithRetry,
  required Future<void> Function() onRetry,
}) async {
  if (event.isSuccess) {
    final refreshed = await refreshOnSuccess();
    if (!refreshed) return;

    final isConnected = hasConnection(event.connectionId);
    if (!isConnected) {
      showMessage('Connection callback received, but storage is not available yet');
      return;
    }

    final providerName = providerDisplayName(event.providerId);
    showMessage('$providerName connected successfully');
    return;
  }

  showErrorWithRetry(_mapOAuthErrorToMessage(event.error), onRetry);
}

String _mapOAuthErrorToMessage(String? errorCode) {
  switch (errorCode?.toLowerCase()) {
    case 'access_denied':
      return 'Authorization was cancelled';
    case 'invalid_state':
      return 'Authorization state is invalid. Please retry';
    case 'provider_unavailable':
      return 'Provider is temporarily unavailable';
    case 'connection_failed':
      return 'Failed to connect provider';
    case 'malformed_callback':
      return 'Malformed OAuth callback payload';
    case 'invalid_status':
      return 'Invalid OAuth callback status';
    default:
      return 'OAuth connect failed';
  }
}
