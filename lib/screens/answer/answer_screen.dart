import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/question.dart';
import 'package:flutter_tests/screens/answer/components/body.dart';

class AnswerScreen extends StatelessWidget {
  final Question question;

  const AnswerScreen({super.key, required this.question});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        question: question,
      ),
    );
  }
}
