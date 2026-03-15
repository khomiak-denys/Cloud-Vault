import 'package:shared_preferences/shared_preferences.dart';

import 'api_config.dart';

class AuthSession {
  AuthSession._();

  static const _bearerTokenKey = 'api_bearer_token';
  static const _appCheckTokenKey = 'api_app_check_token';

  static final AuthSession instance = AuthSession._();

  String? _bearerToken;
  String? _appCheckToken;

  String? get bearerToken {
    if (_bearerToken != null && _bearerToken!.isNotEmpty) return _bearerToken;
    if (ApiConfig.defaultBearerToken.isEmpty) return null;
    return ApiConfig.defaultBearerToken;
  }

  String? get appCheckToken {
    if (_appCheckToken != null && _appCheckToken!.isNotEmpty) {
      return _appCheckToken;
    }
    if (ApiConfig.defaultAppCheckToken.isEmpty) return null;
    return ApiConfig.defaultAppCheckToken;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _bearerToken = prefs.getString(_bearerTokenKey);
    _appCheckToken = prefs.getString(_appCheckTokenKey);
  }

  Future<void> setTokens({String? bearerToken, String? appCheckToken}) async {
    final prefs = await SharedPreferences.getInstance();

    if (bearerToken != null) {
      _bearerToken = bearerToken;
      await prefs.setString(_bearerTokenKey, bearerToken);
    }

    if (appCheckToken != null) {
      _appCheckToken = appCheckToken;
      await prefs.setString(_appCheckTokenKey, appCheckToken);
    }
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _bearerToken = null;
    _appCheckToken = null;
    await prefs.remove(_bearerTokenKey);
    await prefs.remove(_appCheckTokenKey);
  }
}
