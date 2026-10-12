import 'package:flutter_tests/core/l10n.dart';

String _str(dynamic v) => v == null ? '' : v.toString().trim();
int _int(dynamic v) => v is int ? v : int.tryParse(_str(v)) ?? 0;

/// Server returns every text in four languages: `<prefix>_uz_uz`,
/// `<prefix>_uz_crl`, `<prefix>_ru_ru`, `<prefix>_en_us`.
class LocalizedText {
  final String uz;
  final String uzCrl;
  final String ru;
  final String en;

  const LocalizedText({
    this.uz = '',
    this.uzCrl = '',
    this.ru = '',
    this.en = '',
  });

  factory LocalizedText.fromJson(Map<String, dynamic> json, String prefix) =>
      LocalizedText(
        uz: _str(json['${prefix}_uz_uz']),
        uzCrl: _str(json['${prefix}_uz_crl']),
        ru: _str(json['${prefix}_ru_ru']),
        en: _str(json['${prefix}_en_us']),
      );

  Map<String, dynamic> toJson(String prefix) => {
        '${prefix}_uz_uz': uz,
        '${prefix}_uz_crl': uzCrl,
        '${prefix}_ru_ru': ru,
        '${prefix}_en_us': en,
      };

  bool get isEmpty => uz.isEmpty && uzCrl.isEmpty && ru.isEmpty && en.isEmpty;

  /// Text in [lang], falling back to Uzbek and then any non-empty variant.
  String of(AppLang lang) {
    final preferred = switch (lang) {
      AppLang.uz => uz,
      AppLang.uzCrl => uzCrl,
      AppLang.ru => ru,
      AppLang.en => en,
    };
    if (preferred.isNotEmpty) return preferred;
    for (final s in [uz, uzCrl, ru, en]) {
      if (s.isNotEmpty) return s;
    }
    return '';
  }
}

class Group {
  final int id;
  final LocalizedText name;
  final int number;
  final String image;

  const Group(
      {required this.id, required this.name, this.number = 0, this.image = ''});

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: _int(json['id']),
        name: LocalizedText.fromJson(json, 'name'),
        number: _int(json['number']),
        image: _str(json['image']),
      );

  Map<String, dynamic> toJson() =>
      {'id': id, ...name.toJson('name'), 'number': number, 'image': image};
}

class Book {
  final int id;
  final LocalizedText name;
  final String image;
  final int groupId;

  const Book(
      {required this.id,
      required this.name,
      this.image = '',
      this.groupId = 0});

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: _int(json['id']),
        name: LocalizedText.fromJson(json, 'name'),
        image: _str(json['image']),
        groupId: _int(json['group_id']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        ...name.toJson('name'),
        'image': image,
        'group_id': groupId,
      };
}

class Topic {
  final int id;
  final LocalizedText name;
  final int number;
  final String image;
  final int bookId;

  const Topic({
    required this.id,
    required this.name,
    this.number = 0,
    this.image = '',
    this.bookId = 0,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: _int(json['id']),
        name: LocalizedText.fromJson(json, 'name'),
        number: _int(json['number']),
        image: _str(json['image']),
        bookId: _int(json['book_id']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        ...name.toJson('name'),
        'number': number,
        'image': image,
        'book_id': bookId,
      };
}

class Question {
  final int id;
  final LocalizedText text;
  final LocalizedText explanation;
  final String image;
  final int number;

  const Question({
    required this.id,
    required this.text,
    this.explanation = const LocalizedText(),
    this.image = '',
    this.number = 0,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: _int(json['id']),
        text: LocalizedText.fromJson(json, 'name'),
        explanation: LocalizedText.fromJson(json, 'explanation'),
        image: _str(json['image']),
        number: _int(json['number']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        ...text.toJson('name'),
        ...explanation.toJson('explanation'),
        'image': image,
        'number': number,
      };
}

class Answer {
  final int id;
  final LocalizedText text;
  final String image;
  final int number;
  final bool right;

  const Answer({
    required this.id,
    required this.text,
    this.image = '',
    this.number = 0,
    this.right = false,
  });

  factory Answer.fromJson(Map<String, dynamic> json) => Answer(
        id: _int(json['id']),
        text: LocalizedText.fromJson(json, 'name'),
        image: _str(json['image']),
        number: _int(json['number']),
        right: json['right'] == true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        ...text.toJson('name'),
        'image': image,
        'number': number,
        'right': right,
      };
}

/// Everything needed to (re)open a topic: the topic plus its book and group.
class TopicRef {
  final Group group;
  final Book book;
  final Topic topic;

  const TopicRef({required this.group, required this.book, required this.topic});

  factory TopicRef.fromJson(Map<String, dynamic> json) => TopicRef(
        group: Group.fromJson(Map<String, dynamic>.from(json['group'])),
        book: Book.fromJson(Map<String, dynamic>.from(json['book'])),
        topic: Topic.fromJson(Map<String, dynamic>.from(json['topic'])),
      );

  Map<String, dynamic> toJson() =>
      {'group': group.toJson(), 'book': book.toJson(), 'topic': topic.toJson()};
}

class QuizData {
  final List<Question> questions;
  final Map<int, List<Answer>> answers;

  const QuizData({required this.questions, required this.answers});

  factory QuizData.fromJson(Map<String, dynamic> json) {
    final questions = (json['questions'] as List)
        .map((e) => Question.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final answers = <int, List<Answer>>{};
    (json['answers'] as Map).forEach((k, v) {
      answers[int.parse(k.toString())] = (v as List)
          .map((e) => Answer.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
    return QuizData(questions: questions, answers: answers);
  }

  Map<String, dynamic> toJson() => {
        'questions': questions.map((q) => q.toJson()).toList(),
        'answers': answers.map(
            (k, v) => MapEntry(k.toString(), v.map((a) => a.toJson()).toList())),
      };
}
