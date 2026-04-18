import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

typedef HttpRequestHandler =
    FutureOr<http.StreamedResponse> Function(http.BaseRequest request);

class QueuedHttpClient extends http.BaseClient {
  QueuedHttpClient([List<HttpRequestHandler>? initialHandlers]) {
    if (initialHandlers != null) {
      _handlers.addAll(initialHandlers);
    }
  }

  final List<HttpRequestHandler> _handlers = <HttpRequestHandler>[];
  final List<http.BaseRequest> requests = <http.BaseRequest>[];

  void enqueue(HttpRequestHandler handler) {
    _handlers.add(handler);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    if (_handlers.isEmpty) {
      throw StateError('No queued handler for ${request.method} ${request.url}');
    }
    final HttpRequestHandler handler = _handlers.removeAt(0);
    return Future<http.StreamedResponse>.value(handler(request));
  }
}

http.StreamedResponse streamedJsonResponse(
  int statusCode,
  Object? body, {
  Map<String, String>? headers,
}) {
  final String text = body == null ? '' : jsonEncode(body);
  return streamedTextResponse(
    statusCode,
    text,
    headers: <String, String>{
      'content-type': 'application/json',
      ...?headers,
    },
  );
}

http.StreamedResponse streamedTextResponse(
  int statusCode,
  String body, {
  Map<String, String>? headers,
}) {
  final List<int> bytes = utf8.encode(body);
  return http.StreamedResponse(
    Stream<List<int>>.fromIterable(<List<int>>[bytes]),
    statusCode,
    headers: headers ?? const <String, String>{},
    contentLength: bytes.length,
  );
}

http.StreamedResponse streamedBytesResponse(
  int statusCode,
  List<int> bytes, {
  Map<String, String>? headers,
  int? contentLength,
}) {
  return http.StreamedResponse(
    Stream<List<int>>.fromIterable(<List<int>>[bytes]),
    statusCode,
    headers: headers ?? const <String, String>{},
    contentLength: contentLength ?? bytes.length,
  );
}

Future<Map<String, dynamic>> decodeJsonRequest(http.BaseRequest request) async {
  if (request is! http.Request) {
    throw StateError('Expected http.Request but got ${request.runtimeType}');
  }
  if (request.body.isEmpty) {
    return <String, dynamic>{};
  }
  final dynamic decoded = jsonDecode(request.body);
  if (decoded is Map<String, dynamic>) {
    return decoded;
  }
  throw StateError('Expected JSON object body');
}
