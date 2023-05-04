import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/question.dart';
import 'package:flutter_tests/models/topic.dart';
import 'package:flutter_tests/screens/question/components/question_card.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class QuestionCarousel extends StatefulWidget {
  final Topic topic;

  const QuestionCarousel({super.key, required this.topic});
  @override
  _QuestionCaruselState createState() => _QuestionCaruselState(topic);
}

class _QuestionCaruselState extends State<QuestionCarousel> {
  final Topic topic;
  late PageController _pageController;
  int initalPage = 1;
  List<Question> questions = [];
  var loading = false;

  _QuestionCaruselState(this.topic);

  Future<Null> getData() async {
    setState(() {
      loading = true;
    });

    final responseData = await http.get(Uri.parse(
        "http://complexprogrammer.uz/GetQuestions?topic_id=${topic.id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          questions.add(Question.fromJson(i));
        }
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
    _pageController = PageController(
      viewportFraction: 0.8,
      initialPage: initalPage,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
      child: AspectRatio(
        aspectRatio: 0.85,
        child: PageView.builder(
          onPageChanged: (value) {
            setState(() {
              initalPage = value;
            });
          },
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) => buildGroupSlider(index),
        ),
      ),
    );
  }

  Widget buildGroupSlider(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0, page = 0;
        if (_pageController.position.haveDimensions) {
          value = index - _pageController.page!;
          value = (value * 0.038).clamp(-1, 1);
        }
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          opacity: initalPage == index ? 1 : 0.4,
          child: Transform.rotate(
            angle: math.pi * value,
            child: QuestionCard(
              question: questions[index],
            ),
          ),
        );
      },
    );
  }
}
