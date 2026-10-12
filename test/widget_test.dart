import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tests/core/app_state.dart';
import 'package:flutter_tests/core/l10n.dart';
import 'package:flutter_tests/core/theme.dart';
import 'package:flutter_tests/data/models.dart';
import 'package:flutter_tests/widgets/question_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _named(int id, String uz, [Map<String, dynamic>? extra]) => {
      'id': id,
      'name_uz_uz': uz,
      'name_uz_crl': '',
      'name_ru_ru': 'ru $uz',
      'name_en_us': 'en $uz',
      ...?extra,
    };

TopicRef _ref(int topicId) => TopicRef(
      group: Group.fromJson(_named(1, '5-sinf', {'number': 5})),
      book: Book.fromJson(_named(2, 'Adabiyot', {'group_id': 1})),
      topic: Topic.fromJson(_named(topicId, 'Mavzu $topicId', {'number': 1})),
    );

void main() {
  group('models', () {
    test('LocalizedText falls back to Uzbek when a language is empty', () {
      final t = Topic.fromJson(_named(3, 'Hikmat'));
      expect(t.name.of(AppLang.uz), 'Hikmat');
      expect(t.name.of(AppLang.uzCrl), 'Hikmat');
      expect(t.name.of(AppLang.ru), 'ru Hikmat');
    });

    test('TopicRef and QuizData survive a JSON round trip', () {
      final ref = _ref(7);
      final back = TopicRef.fromJson(jsonDecode(jsonEncode(ref.toJson())));
      expect(back.topic.id, 7);
      expect(back.book.name.of(AppLang.en), 'en Adabiyot');

      final quiz = QuizData(questions: [
        Question.fromJson(_named(10, 'Savol', {'number': 1, 'image': null}))
      ], answers: {
        10: [Answer.fromJson(_named(100, 'Javob', {'right': true}))]
      });
      final q2 = QuizData.fromJson(jsonDecode(jsonEncode(quiz.toJson())));
      expect(q2.questions.single.image, '');
      expect(q2.answers[10]!.single.right, isTrue);
    });
  });

  group('AppState', () {
    test('migrates legacy answers without duplicating them', () async {
      SharedPreferences.setMockInitialValues({
        'selected_answers': jsonEncode([
          {'topicId': 1, 'questionId': 11, 'answerId': 5, 'right': true, 'time': 15},
          {'topicId': 1, 'questionId': 11, 'answerId': 5, 'right': true, 'time': 15},
          {'topicId': 1, 'questionId': 12, 'answerId': 6, 'right': false, 'time': 15},
        ]),
      });
      final s = await AppState.load();
      s.setTopicTotal(1, 4);
      final p = s.progressOf(1);
      expect(p.answered, 2);
      expect(p.correct, 1);
      expect(p.completed, isFalse);

      // Reloading must not double the answers (old app bug).
      final again = await AppState.load();
      expect(again.progressOf(1).answered, 2);
    });

    test('records answers once, tracks streak and completion', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await AppState.load();
      s.setTopicTotal(9, 2);
      s.recordAnswer(9, 1, 10, true);
      s.recordAnswer(9, 1, 11, false); // second tap is ignored
      s.recordAnswer(9, 2, 20, false);
      expect(s.progressOf(9).completed, isTrue);
      expect(s.answersFor(9)[1]!.right, isTrue);
      expect(s.answeredToday, 2);
      expect(s.currentStreak, 1);
      expect(s.accuracy, 50);
      expect(s.completedTopics, 1);

      s.resetTopic(9);
      expect(s.progressOf(9).started, isFalse);
    });

    test('favorites toggle and persist', () async {
      SharedPreferences.setMockInitialValues({});
      final s = await AppState.load();
      s.toggleFavorite(_ref(5));
      expect((await AppState.load()).isFavorite(5), isTrue);
      AppState.instance.toggleFavorite(_ref(5));
      expect(AppState.instance.favorites, isEmpty);
    });
  });

  test('every translation has all four languages', () {
    for (final key in translationKeys) {
      for (final lang in AppLang.values) {
        expect(translate(lang, key), isNotEmpty, reason: '$key/$lang');
      }
    }
    expect(translate(AppLang.en, 'question_of', {'n': '2', 'total': '9'}),
        'Question 2 of 9');
  });

  testWidgets('practice question reveals the correct answer after a pick',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppState.load();
    final q = Question.fromJson(_named(1, 'Poytaxt qaysi?'));
    final options = [
      Answer.fromJson(_named(1, 'Samarqand')),
      Answer.fromJson(_named(2, 'Toshkent', {'right': true})),
    ];
    int? picked;

    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(Brightness.light),
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => QuestionView(
            question: q,
            options: options,
            pickedId: picked,
            reveal: true,
            onPick: (a) => setState(() => picked = a.id),
          ),
        ),
      ),
    ));

    expect(find.text('Poytaxt qaysi?'), findsOneWidget);
    await tester.tap(find.text('Samarqand'));
    await tester.pumpAndSettle();

    expect(picked, 1);
    expect(find.byIcon(Icons.cancel_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.text(translate(AppLang.uz, 'feedback_wrong', {'letter': 'B'})),
        findsOneWidget);
  });
}
