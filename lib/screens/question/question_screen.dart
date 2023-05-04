import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/topic.dart';
import 'package:flutter_tests/screens/question/components/body.dart';

class QuestionScreen extends StatelessWidget {
  final Topic topic;

  const QuestionScreen({super.key, required this.topic});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        topic: topic,
      ),
    );
  }
}
