import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum QuizMode { practice, exam }

class AnswerRecord {
  final int answerId;
  final bool right;
  const AnswerRecord(this.answerId, this.right);

  factory AnswerRecord.fromJson(Map<String, dynamic> j) =>
      AnswerRecord(j['a'] as int, j['r'] == true);
  Map<String, dynamic> toJson() => {'a': answerId, 'r': right};
}

class ResultRecord {
  final TopicRef ref;
  final QuizMode mode;
  final int correct;
  final int wrong;
  final int total;
  final int seconds;
  final DateTime date;

  const ResultRecord({
    required this.ref,
    required this.mode,
    required this.correct,
    required this.wrong,
    required this.total,
    required this.seconds,
    required this.date,
  });

  int get skipped => total - correct - wrong;
  int get percent => total == 0 ? 0 : (correct * 100 / total).round();

  factory ResultRecord.fromJson(Map<String, dynamic> j) => ResultRecord(
        ref: TopicRef.fromJson(Map<String, dynamic>.from(j['ref'])),
        mode: QuizMode.values.byName(j['mode']),
        correct: j['correct'],
        wrong: j['wrong'],
        total: j['total'],
        seconds: j['seconds'],
        date: DateTime.parse(j['date']),
      );

  Map<String, dynamic> toJson() => {
        'ref': ref.toJson(),
        'mode': mode.name,
        'correct': correct,
        'wrong': wrong,
        'total': total,
        'seconds': seconds,
        'date': date.toIso8601String(),
      };
}

class TopicProgress {
  final int answered;
  final int correct;

  /// Number of questions in the topic, or 0 if the topic was never opened.
  final int total;
  const TopicProgress(this.answered, this.correct, this.total);

  bool get started => answered > 0;
  bool get completed => total > 0 && answered >= total;
  double get fraction => total == 0 ? 0 : (answered / total).clamp(0, 1);
  int get percent => answered == 0 ? 0 : (correct * 100 / answered).round();
}

class Achievement {
  final String id;
  final IconData icon;
  final bool unlocked;
  const Achievement(this.id, this.icon, this.unlocked);
}

String dayKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// App-wide settings and learning progress, persisted in SharedPreferences.
class AppState extends ChangeNotifier {
  static late AppState instance;

  final SharedPreferences _prefs;
  AppState._(this._prefs);

  SharedPreferences get prefs => _prefs;

  // ---------- settings ----------
  ThemeMode themeMode = ThemeMode.system;
  AppLang lang = AppLang.uz;
  bool sound = true;
  bool haptics = true;
  bool autoNext = true;
  bool shuffleAnswers = false;
  bool reminders = true;
  double textScale = 1.0;
  bool onboardingSeen = false;

  // ---------- progress ----------
  final Map<int, Map<int, AnswerRecord>> _answers = {};
  final Map<int, int> _topicTotals = {};
  final LinkedHashMap<int, TopicRef> _favorites = LinkedHashMap();
  final List<ResultRecord> _history = [];
  final Map<String, int> _daily = {};
  TopicRef? lastSession;

  static Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final s = AppState._(prefs);
    s._load();
    instance = s;
    return s;
  }

  void _load() {
    final p = _prefs;
    themeMode = ThemeMode.values[p.getInt('s.theme') ?? 0];
    lang = AppLang.values[p.getInt('s.lang') ?? 0];
    sound = p.getBool('s.sound') ?? true;
    haptics = p.getBool('s.haptics') ?? true;
    autoNext = p.getBool('s.autoNext') ?? true;
    shuffleAnswers = p.getBool('s.shuffle') ?? false;
    reminders = p.getBool('s.reminders') ?? true;
    textScale = p.getDouble('s.textScale') ?? 1.0;
    onboardingSeen = p.getBool('s.onboarding') ?? false;

    _readJson('p.answers', (Map j) {
      j.forEach((topic, map) {
        _answers[int.parse(topic)] = (map as Map).map((q, r) => MapEntry(
            int.parse(q), AnswerRecord.fromJson(Map<String, dynamic>.from(r))));
      });
    });
    _readJson('p.totals', (Map j) {
      j.forEach((k, v) => _topicTotals[int.parse(k)] = v as int);
    });
    _readJson('p.favorites', (List j) {
      for (final e in j) {
        final ref = TopicRef.fromJson(Map<String, dynamic>.from(e));
        _favorites[ref.topic.id] = ref;
      }
    });
    _readJson('p.history', (List j) {
      _history.addAll(
          j.map((e) => ResultRecord.fromJson(Map<String, dynamic>.from(e))));
    });
    _readJson('p.daily', (Map j) {
      j.forEach((k, v) => _daily[k] = v as int);
    });
    _readJson('p.last', (Map j) {
      lastSession = TopicRef.fromJson(Map<String, dynamic>.from(j));
    });
    _migrateLegacyAnswers();
  }

  void _readJson<T>(String key, void Function(T) apply) {
    final s = _prefs.getString(key);
    if (s == null) return;
    try {
      apply(jsonDecode(s) as T);
    } catch (e) {
      debugPrint('AppState: cannot read $key: $e');
    }
  }

  /// Older versions stored a flat list under `selected_answers`.
  void _migrateLegacyAnswers() {
    final legacy = _prefs.getString('selected_answers');
    if (legacy == null) return;
    try {
      for (final e in jsonDecode(legacy) as List) {
        final topic = e['topicId'] as int;
        _answers.putIfAbsent(topic, () => {})[e['questionId'] as int] =
            AnswerRecord(e['answerId'] as int, e['right'] == true);
      }
      _saveAnswers();
    } catch (_) {}
    _prefs.remove('selected_answers');
  }

  void _saveAnswers() => _prefs.setString(
      'p.answers',
      jsonEncode(_answers.map((t, m) => MapEntry(t.toString(),
          m.map((q, r) => MapEntry(q.toString(), r.toJson()))))));

  // ---------- settings setters ----------
  void setThemeMode(ThemeMode v) {
    themeMode = v;
    _prefs.setInt('s.theme', v.index);
    notifyListeners();
  }

  void setLang(AppLang v) {
    lang = v;
    _prefs.setInt('s.lang', v.index);
    notifyListeners();
  }

  void setSound(bool v) {
    sound = v;
    _prefs.setBool('s.sound', v);
    notifyListeners();
  }

  void setHaptics(bool v) {
    haptics = v;
    _prefs.setBool('s.haptics', v);
    notifyListeners();
  }

  void setAutoNext(bool v) {
    autoNext = v;
    _prefs.setBool('s.autoNext', v);
    notifyListeners();
  }

  void setShuffle(bool v) {
    shuffleAnswers = v;
    _prefs.setBool('s.shuffle', v);
    notifyListeners();
  }

  void setReminders(bool v) {
    reminders = v;
    _prefs.setBool('s.reminders', v);
    notifyListeners();
  }

  void setTextScale(double v) {
    textScale = v;
    _prefs.setDouble('s.textScale', v);
    notifyListeners();
  }

  void setOnboardingSeen() {
    onboardingSeen = true;
    _prefs.setBool('s.onboarding', true);
  }

  // ---------- practice progress ----------
  Map<int, AnswerRecord> answersFor(int topicId) =>
      Map.unmodifiable(_answers[topicId] ?? const {});

  void recordAnswer(int topicId, int questionId, int answerId, bool right) {
    final map = _answers.putIfAbsent(topicId, () => {});
    if (map.containsKey(questionId)) return;
    map[questionId] = AnswerRecord(answerId, right);
    _saveAnswers();
    _bumpDaily(1);
    notifyListeners();
  }

  void resetTopic(int topicId) {
    _answers.remove(topicId);
    _saveAnswers();
    notifyListeners();
  }

  void setTopicTotal(int topicId, int total) {
    if (_topicTotals[topicId] == total) return;
    _topicTotals[topicId] = total;
    _prefs.setString('p.totals',
        jsonEncode(_topicTotals.map((k, v) => MapEntry(k.toString(), v))));
    notifyListeners();
  }

  TopicProgress progressOf(int topicId) {
    final map = _answers[topicId] ?? const {};
    final correct = map.values.where((r) => r.right).length;
    return TopicProgress(map.length, correct, _topicTotals[topicId] ?? 0);
  }

  void setLastSession(TopicRef ref) {
    lastSession = ref;
    _prefs.setString('p.last', jsonEncode(ref.toJson()));
    notifyListeners();
  }

  void clearLastSession() {
    lastSession = null;
    _prefs.remove('p.last');
    notifyListeners();
  }

  // ---------- favorites ----------
  List<TopicRef> get favorites => _favorites.values.toList().reversed.toList();
  bool isFavorite(int topicId) => _favorites.containsKey(topicId);

  void toggleFavorite(TopicRef ref) {
    if (_favorites.remove(ref.topic.id) == null) {
      _favorites[ref.topic.id] = ref;
    }
    _prefs.setString('p.favorites',
        jsonEncode(_favorites.values.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  // ---------- history & stats ----------
  List<ResultRecord> get history => List.unmodifiable(_history.reversed);

  void addResult(ResultRecord r, {int answeredOutsidePractice = 0}) {
    _history.add(r);
    if (_history.length > 300) _history.removeAt(0);
    _prefs.setString(
        'p.history', jsonEncode(_history.map((e) => e.toJson()).toList()));
    if (answeredOutsidePractice > 0) _bumpDaily(answeredOutsidePractice);
    notifyListeners();
  }

  void _bumpDaily(int n) {
    final k = dayKey(DateTime.now());
    _daily[k] = (_daily[k] ?? 0) + n;
    _prefs.setString('p.daily', jsonEncode(_daily));
  }

  int answeredOn(DateTime day) => _daily[dayKey(day)] ?? 0;
  int get answeredToday => answeredOn(DateTime.now());
  int get totalAnswered => _daily.values.fold(0, (a, b) => a + b);

  int get totalCorrect =>
      _answers.values.expand((m) => m.values).where((r) => r.right).length +
      _history
          .where((r) => r.mode == QuizMode.exam)
          .fold(0, (a, r) => a + r.correct);

  int get totalChecked =>
      _answers.values.fold(0, (a, m) => a + m.length) +
      _history
          .where((r) => r.mode == QuizMode.exam)
          .fold(0, (a, r) => a + r.correct + r.wrong);

  int get accuracy =>
      totalChecked == 0 ? 0 : (totalCorrect * 100 / totalChecked).round();

  int get completedTopics => _answers.entries
      .where((e) =>
          (_topicTotals[e.key] ?? 0) > 0 &&
          e.value.length >= _topicTotals[e.key]!)
      .length;

  /// Consecutive days (ending today, or yesterday if nothing yet today)
  /// with at least one answered question.
  int get currentStreak {
    var day = DateTime.now();
    if (answeredOn(day) == 0) day = day.subtract(const Duration(days: 1));
    var streak = 0;
    while (answeredOn(day) > 0) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestStreak {
    final days = _daily.entries
        .where((e) => e.value > 0)
        .map((e) => DateTime.parse(e.key))
        .toList()
      ..sort();
    var best = 0, run = 0;
    DateTime? prev;
    for (final d in days) {
      run = (prev != null && d.difference(prev).inDays == 1) ? run + 1 : 1;
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  List<Achievement> get achievements => [
        Achievement('ach_first', Icons.flag_rounded, _history.isNotEmpty),
        Achievement('ach_perfect', Icons.workspace_premium_rounded,
            _history.any((r) => r.total >= 5 && r.percent == 100)),
        Achievement('ach_streak3', Icons.local_fire_department_rounded,
            bestStreak >= 3),
        Achievement('ach_streak7', Icons.whatshot_rounded, bestStreak >= 7),
        Achievement(
            'ach_q100', Icons.military_tech_rounded, totalAnswered >= 100),
        Achievement('ach_q500', Icons.emoji_events_rounded, totalAnswered >= 500),
        Achievement('ach_exam', Icons.verified_rounded,
            _history.any((r) => r.mode == QuizMode.exam && r.percent >= 80)),
        Achievement(
            'ach_topics10', Icons.auto_stories_rounded, completedTopics >= 10),
      ];

  Future<void> resetAllProgress() async {
    _answers.clear();
    _topicTotals.clear();
    _history.clear();
    _daily.clear();
    _favorites.clear();
    lastSession = null;
    for (final k in ['p.answers', 'p.totals', 'p.history', 'p.daily', 'p.favorites', 'p.last']) {
      await _prefs.remove(k);
    }
    notifyListeners();
  }
}
