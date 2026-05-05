import 'auth_session.dart';

abstract class AuthTokenStore {
  Future<void> setBearerToken(String bearerToken);
}

class AuthSessionTokenStore implements AuthTokenStore {
  const AuthSessionTokenStore();

  @override
  Future<void> setBearerToken(String bearerToken) {
    return AuthSession.instance.setTokens(bearerToken: bearerToken);
  }
}
