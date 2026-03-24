class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.body, this.errorCode});

  final String message;
  final int? statusCode;
  final String? body;
  final String? errorCode;

  @override
  String toString() {
    final code = statusCode == null ? '' : ' ($statusCode)';
    final structured = errorCode == null ? '' : ' [$errorCode]';
    return '$message$code$structured';
  }
}
