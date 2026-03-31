import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_vault/api/api_client.dart';
import 'package:http/http.dart' as http;

typedef JsonHandler =
    Map<String, dynamic> Function(
      Map<String, dynamic>? body,
      Map<String, String>? query,
    );
typedef BytesHandler =
    Uint8List Function(
      Map<String, dynamic>? body,
      Map<String, String>? query,
      int maxBytes,
      Duration timeout,
    );
typedef MultipartHandler =
    Map<String, dynamic> Function({
      required Map<String, String> fields,
      required String fileField,
      Uint8List? fileBytes,
      String? filePath,
      Stream<List<int>>? fileStream,
      int? fileLength,
      required String fileName,
      required Duration timeout,
    });

class ApiCall {
  const ApiCall({
    required this.method,
    required this.path,
    this.body,
    this.query,
    this.maxBytes,
    this.timeout,
    this.fields,
    this.fileField,
    this.fileBytes,
    this.filePath,
    this.fileStream,
    this.fileLength,
    this.fileName,
  });

  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final Map<String, String>? query;
  final int? maxBytes;
  final Duration? timeout;
  final Map<String, String>? fields;
  final String? fileField;
  final Uint8List? fileBytes;
  final String? filePath;
  final Stream<List<int>>? fileStream;
  final int? fileLength;
  final String? fileName;
}

class FakeApiClient extends ApiClient {
  FakeApiClient() : super(httpClient: http.Client());

  final Map<String, JsonHandler> getHandlers = <String, JsonHandler>{};
  final Map<String, JsonHandler> postHandlers = <String, JsonHandler>{};
  final Map<String, JsonHandler> deleteHandlers = <String, JsonHandler>{};
  final Map<String, BytesHandler> postBytesHandlers = <String, BytesHandler>{};
  final Map<String, MultipartHandler> multipartHandlers =
      <String, MultipartHandler>{};

  final List<ApiCall> calls = <ApiCall>[];

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    calls.add(ApiCall(method: 'GET', path: path, query: query));
    final handler = getHandlers[path];
    if (handler == null) {
      throw StateError('No GET handler for $path');
    }
    return handler(null, query);
  }

  @override
  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    calls.add(ApiCall(method: 'POST', path: path, body: body, query: query));
    final handler = postHandlers[path];
    if (handler == null) {
      throw StateError('No POST handler for $path');
    }
    return handler(body, query);
  }

  @override
  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, String>? query,
  }) async {
    calls.add(ApiCall(method: 'DELETE', path: path, query: query));
    final handler = deleteHandlers[path];
    if (handler == null) {
      throw StateError('No DELETE handler for $path');
    }
    return handler(null, query);
  }

  @override
  Future<Uint8List> postBytesCapped(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    required int maxBytes,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    calls.add(
      ApiCall(
        method: 'POST_BYTES',
        path: path,
        body: body,
        query: query,
        maxBytes: maxBytes,
        timeout: timeout,
      ),
    );
    final handler = postBytesHandlers[path];
    if (handler == null) {
      throw StateError('No POST_BYTES handler for $path');
    }
    return handler(body, query, maxBytes, timeout);
  }

  @override
  Future<Map<String, dynamic>> postMultipart(
    String path, {
    required Map<String, String> fields,
    required String fileField,
    Uint8List? fileBytes,
    String? filePath,
    Stream<List<int>>? fileStream,
    int? fileLength,
    required String fileName,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    calls.add(
      ApiCall(
        method: 'POST_MULTIPART',
        path: path,
        fields: fields,
        fileField: fileField,
        fileBytes: fileBytes,
        filePath: filePath,
        fileStream: fileStream,
        fileLength: fileLength,
        fileName: fileName,
        timeout: timeout,
      ),
    );
    final handler = multipartHandlers[path];
    if (handler == null) {
      throw StateError('No POST_MULTIPART handler for $path');
    }
    return handler(
      fields: fields,
      fileField: fileField,
      fileBytes: fileBytes,
      filePath: filePath,
      fileStream: fileStream,
      fileLength: fileLength,
      fileName: fileName,
      timeout: timeout,
    );
  }
}
