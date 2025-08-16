import 'package:dio/dio.dart';

class ApiClientException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final Object? originalException;
  final StackTrace? stackTrace;

  ApiClientException({
    required this.message,
    this.statusCode,
    this.data,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() =>
      'ApiClientException(statusCode: $statusCode, message: $message, data: $data)';
}

/// A simple API client wrapper around Dio.
///
/// - Holds a single Dio instance
/// - Exposes one method per API call (to be implemented later)
/// - Central place for interceptors, base options, headers, etc.
class ApiClient {
  final Dio dio;

  ApiClient({Dio? dio, String? baseUrl})
    : dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl ?? '')) {
    // You can add interceptors here (logging, auth, retry, etc.)
    // this.dio.interceptors.add(LogInterceptor(responseBody: true));
  }

  ApiClientException _mapDioError(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final base = switch (e.type) {
      DioExceptionType.connectionTimeout => 'Connection timed out',
      DioExceptionType.sendTimeout => 'Send timed out',
      DioExceptionType.receiveTimeout => 'Receive timed out',
      DioExceptionType.badResponse => 'Request failed with status code $status',
      DioExceptionType.cancel => 'Request was cancelled',
      DioExceptionType.connectionError => 'Connection error',
      DioExceptionType.badCertificate => 'Bad certificate',
      DioExceptionType.unknown => e.message ?? 'Unknown network error',
    };
    return ApiClientException(
      message: base,
      statusCode: status,
      data: data,
      originalException: e,
      stackTrace: e.stackTrace,
    );
  }

  // Centralized try/catch for Dio calls
  Future<T> _guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e, st) {
      throw ApiClientException(
        message: 'Unexpected error',
        originalException: e,
        stackTrace: st,
      );
    }
  }

  // Health check or root endpoint
  Future<Response<dynamic>> ping() => _guard(() => dio.get('/ping'));

  // Fetch quiz questions (placeholder)
  Future<Response<dynamic>> fetchQuizQuestions() =>
      _guard(() => dio.get('/quiz/questions'));

  // Submit quiz result (placeholder)
  Future<Response<dynamic>> submitQuizResult(Map<String, dynamic> payload) =>
      _guard(() => dio.post('/quiz/submit', data: payload));

  // Translate phrase (placeholder)
  Future<Response<dynamic>> translatePhrase({
    required String text,
    required String from,
    required String to,
  }) => _guard(
    () => dio.post('/translate', data: {'text': text, 'from': from, 'to': to}),
  );

  // Get phrase book entries (placeholder)
  Future<Response<dynamic>> fetchPhraseBook() =>
      _guard(() => dio.get('/phrasebook'));
}
