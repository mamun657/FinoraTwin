import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_storage.dart';

final apiClientProvider = Provider<ApiClient>(
  (ref) => throw UnimplementedError('Override in main()'),
);

class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  final int statusCode;
  final String code;
  final String message;
  final dynamic details;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isClient => statusCode >= 400 && statusCode < 500;
  bool get isServer => statusCode >= 500;

  @override
  String toString() => '[$statusCode/$code] $message';
}

class ApiClient {
  ApiClient({
    required String baseUrl,
    required AuthStorage authStorage,
    Dio? dio,
  }) : _authStorage = authStorage,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 12),
               receiveTimeout: const Duration(seconds: 30),
               sendTimeout: const Duration(seconds: 30),
               headers: {
                 'Content-Type': 'application/json',
                 'Accept': 'application/json',
               },
               validateStatus: (s) => s != null && s < 500,
             ),
           ) {
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
  }

  final AuthStorage _authStorage;
  final Dio _dio;

  String get baseUrl => _dio.options.baseUrl;

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _authStorage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onResponse: (response, handler) async {
        if (response.statusCode == 401) {
          await _authStorage.clear();
        }
        handler.next(response);
      },
    );
  }

  Interceptor _loggingInterceptor() {
    return LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
      error: true,
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) async {
    return _send(() => _dio.get(path, queryParameters: query));
  }

  Future<dynamic> post(String path, {Object? body}) async {
    return _send(() => _dio.post(path, data: body));
  }

  Future<dynamic> put(String path, {Object? body}) async {
    return _send(() => _dio.put(path, data: body));
  }

  Future<dynamic> delete(String path) async {
    return _send(() => _dio.delete(path));
  }

  Future<dynamic> _send(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await _withRetry(request);
      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300) {
        return response.data;
      }
      throw _mapError(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    } on SocketException catch (e) {
      throw ApiException(
        statusCode: 0,
        code: 'network_unreachable',
        message: 'Cannot reach the server. Check your connection.',
        details: e.message,
      );
    } on TimeoutException catch (_) {
      throw ApiException(
        statusCode: 0,
        code: 'timeout',
        message: 'The server took too long to respond.',
      );
    } on FormatException catch (e) {
      throw ApiException(
        statusCode: 0,
        code: 'invalid_response',
        message: 'Server returned an unexpected response.',
        details: e.message,
      );
    }
  }

  Future<Response<dynamic>> _withRetry(
    Future<Response<dynamic>> Function() request,
  ) async {
    Response<dynamic>? last;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        last = await request();
        return last;
      } on DioException catch (e) {
        final retriable =
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.receiveTimeout;
        if (!retriable || attempt == 1) rethrow;
        await Future<void>.delayed(const Duration(milliseconds: 600));
      }
    }
    return last!;
  }

  ApiException _mapError(Response<dynamic> response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      final code = (body['code'] as String?) ?? 'error';
      // ASP.NET ValidationProblemDetails has shape:
      // { type, title, status, errors: { fieldName: ["msg1", "msg2"] } }
      // Surface the real validation message instead of a generic one.
      String message =
          (body['message'] as String?) ?? (body['title'] as String?) ?? '';
      if (message.isEmpty) {
        final errors = body['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final parts = <String>[];
          for (final entry in errors.entries) {
            final list = entry.value;
            if (list is List && list.isNotEmpty) {
              parts.add('${entry.key}: ${list.first}');
            } else if (list is String) {
              parts.add('${entry.key}: $list');
            }
          }
          if (parts.isNotEmpty) {
            message = parts.join('\n');
          }
        }
      }
      message = message.isEmpty ? 'Request failed. Try again.' : message;
      return ApiException(
        statusCode: response.statusCode ?? 0,
        code: code,
        message: message,
        details: body['details'] ?? body['errors'],
      );
    }
    return ApiException(
      statusCode: response.statusCode ?? 0,
      code: 'unknown',
      message: 'Request failed. Try again.',
    );
  }

  ApiException _mapDioError(DioException e) {
    if (e.response != null) return _mapError(e.response!);
    return ApiException(
      statusCode: 0,
      code: 'network_error',
      message: e.message ?? 'Network error.',
    );
  }
}

String jsonEncodePretty(Object value) =>
    const JsonEncoder.withIndent('  ').convert(value);
