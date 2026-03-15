class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000/v1',
  );

  static const String defaultBearerToken = String.fromEnvironment(
    'API_BEARER_TOKEN',
    defaultValue: '',
  );

  static const String defaultAppCheckToken = String.fromEnvironment(
    'API_APP_CHECK_TOKEN',
    defaultValue: '',
  );
}
