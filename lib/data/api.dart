import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum ApiError { network, timeout, server, empty }

class ApiException implements Exception {
  final ApiError error;
  const ApiException(this.error);

  /// l10n key describing the error.
  String get messageKey => switch (error) {
        ApiError.network => 'err_network',
        ApiError.timeout => 'err_timeout',
        ApiError.server => 'err_server',
        ApiError.empty => 'err_empty',
      };

  @override
  String toString() => 'ApiException($error)';
}

class ApiResult<T> {
  final T data;

  /// True when the network failed and the data came from the offline cache.
  final bool fromCache;

  const ApiResult(this.data, {this.fromCache = false});
}

/// Thin client for the test server with an offline cache in SharedPreferences.
class Api {
  static final http.Client _client = http.Client();
  static const _timeout = Duration(seconds: 12);
  static const _quizCacheTtl = Duration(days: 3);
  static late SharedPreferences _prefs;

  static void init(SharedPreferences prefs) => _prefs = prefs;

  static Future<ApiResult<List<Group>>> groups() =>
      _list('tests/GetGroups/?type_id=2', Group.fromJson);

  static Future<ApiResult<List<Book>>> books(int groupId) =>
      _list('tests/GetBooks/?group_id=$groupId', Book.fromJson);

  static Future<ApiResult<List<Topic>>> topics(int bookId) async {
    final res = await _list('tests/GetTopics/?book_id=$bookId', Topic.fromJson);
    res.data.sort((a, b) => a.number.compareTo(b.number));
    return res;
  }

  /// Loads all questions of a topic together with all their answers, so the
  /// quiz works without further requests (and offline next time).
  static Future<ApiResult<QuizData>> quiz(int topicId,
      {bool forceRefresh = false}) async {
    final key = 'cache:quiz:$topicId';
    final cached = _readCache(key);
    QuizData? cachedQuiz;
    if (cached != null) {
      try {
        cachedQuiz = QuizData.fromJson(Map<String, dynamic>.from(cached['data']));
      } catch (_) {
        cachedQuiz = null;
      }
    }
    final savedAt = DateTime.fromMillisecondsSinceEpoch(
        (cached?['savedAt'] as int?) ?? 0);
    if (!forceRefresh &&
        cachedQuiz != null &&
        cachedQuiz.questions.isNotEmpty &&
        DateTime.now().difference(savedAt) < _quizCacheTtl) {
      return ApiResult(cachedQuiz);
    }

    try {
      final raw = await _getJson('tests/GetQuestions/?topic_id=$topicId');
      final questions = (raw as List)
          .map((e) => Question.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => a.number.compareTo(b.number));
      if (questions.isEmpty) throw const ApiException(ApiError.empty);

      final answers = <int, List<Answer>>{};
      // Limited parallelism keeps the server and slow connections happy.
      const batch = 6;
      for (var i = 0; i < questions.length; i += batch) {
        final chunk = questions.skip(i).take(batch);
        await Future.wait(chunk.map((q) async {
          final list = await _getJson('GetAnswers/?question_id=${q.id}');
          answers[q.id] = (list as List)
              .map((e) => Answer.fromJson(Map<String, dynamic>.from(e)))
              .toList()
            ..sort((a, b) => a.number.compareTo(b.number));
        }));
      }
      final quiz = QuizData(questions: questions, answers: answers);
      _writeCache(key, quiz.toJson());
      return ApiResult(quiz);
    } on ApiException {
      if (cachedQuiz != null) return ApiResult(cachedQuiz, fromCache: true);
      rethrow;
    }
  }

  static Future<ApiResult<List<T>>> _list<T>(
      String path, T Function(Map<String, dynamic>) parse) async {
    final key = 'cache:$path';
    try {
      final raw = await _getJson(path);
      _writeCache(key, raw);
      return ApiResult(_parseList(raw, parse));
    } on ApiException {
      final cached = _readCache(key);
      if (cached != null) {
        return ApiResult(_parseList(cached['data'], parse), fromCache: true);
      }
      rethrow;
    }
  }

  static List<T> _parseList<T>(
          dynamic raw, T Function(Map<String, dynamic>) parse) =>
      (raw as List).map((e) => parse(Map<String, dynamic>.from(e))).toList();

  static Future<dynamic> _getJson(String path) async {
    try {
      final res =
          await _client.get(Uri.parse('$baseUrl/$path')).timeout(_timeout);
      if (res.statusCode != 200) throw const ApiException(ApiError.server);
      return jsonDecode(utf8.decode(res.bodyBytes));
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException(ApiError.timeout);
    } on http.ClientException {
      throw const ApiException(ApiError.network);
    } on FormatException {
      throw const ApiException(ApiError.server);
    } catch (e) {
      debugPrint('Api error on $path: $e');
      throw const ApiException(ApiError.network);
    }
  }

  static Map<String, dynamic>? _readCache(String key) {
    final s = _prefs.getString(key);
    if (s == null) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(s));
    } catch (_) {
      return null;
    }
  }

  static void _writeCache(String key, dynamic data) {
    _prefs.setString(
        key,
        jsonEncode(
            {'savedAt': DateTime.now().millisecondsSinceEpoch, 'data': data}));
  }

  static Future<void> clearCache() async {
    for (final k in _prefs.getKeys().where((k) => k.startsWith('cache:'))) {
      await _prefs.remove(k);
    }
  }
}
