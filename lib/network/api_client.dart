import 'dart:math';
import 'package:dio/dio.dart';
import '../models/game_models.dart';
import '../models/phrase_book_item.dart';

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

  // Fetch quiz questions from server and return typed list
  Future<List<Question>> fetchQuizQuestions() => _guard(() async {
    final resp = await dio.post(
      'https://serverpod-api-773078918212.europe-west3.run.app/question',
      data: const {'method': 'getQuestions'},
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = resp.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['result'] is List) {
      list = data['result'] as List<dynamic>;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List<dynamic>;
    } else {
      throw ApiClientException(
        message: 'Unexpected response format',
        statusCode: resp.statusCode,
        data: data,
      );
    }

    final rnd = Random();
    return list
        .map((e) {
          final map = e as Map<String, dynamic>;
          final audioPath =
              (map['audioPath'] ?? map['audio'] ?? map['url'] ?? '') as String;
          final answersRaw =
              (map['answers'] ?? map['options'] ?? map['choices'])
                  as List<dynamic>;
          final answers = answersRaw.map((a) {
            final am = a as Map<String, dynamic>;
            final text =
                (am['text'] ?? am['label'] ?? am['answer'] ?? '') as String;
            final isCorrect =
                (am['isCorrect'] ?? am['correct'] ?? am['is_right'] ?? false)
                    as bool;
            return Answer(text: text, isCorrect: isCorrect);
          }).toList();
          answers.shuffle(rnd);
          return Question(audioPath: audioPath, answers: answers);
        })
        .toList(growable: false);
  });

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

  // Get phrase book entries from server
  Future<List<PhraseBookItem>> fetchPhraseBook() => _guard(() async {
    final resp = await dio.post(
      'https://serverpod-api-773078918212.europe-west3.run.app/soundBites',
      data: const {'method': 'getSoundBites'},
      options: Options(contentType: Headers.jsonContentType),
    );

    final data = resp.data;
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['result'] is List) {
      list = data['result'] as List<dynamic>;
    } else if (data is Map && data['data'] is List) {
      list = data['data'] as List<dynamic>;
    } else {
      throw ApiClientException(
        message: 'Unexpected response format',
        statusCode: resp.statusCode,
        data: data,
      );
    }

    return list
        .map((e) {
          final m = e as Map<String, dynamic>;
          final url = (m['url'] ?? m['fileName'] ?? m['audio'] ?? '') as String;
          final category =
              (m['category'] ?? m['group'] ?? m['type'] ?? 'General') as String;
          final name = (m['name'] ?? m['title'] ?? m['label'] ?? url) as String;
          return PhraseBookItem(url: url, category: category, name: name);
        })
        .toList(growable: false);
  });
}
