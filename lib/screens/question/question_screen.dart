import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/models/topic.dart';
import 'package:flutter_tests/screens/question/components/body.dart';

class QuestionScreen extends StatelessWidget {
  final Topic topic;
  final Book book;

  const QuestionScreen({super.key, required this.topic, required this.book});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        topic: topic,
        book: book,
      ),
    );
  }
}
