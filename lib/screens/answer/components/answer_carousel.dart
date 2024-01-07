import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/question.dart';
import 'package:flutter_tests/models/answer.dart';
import 'package:flutter_tests/screens/answer/components/answer_card.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class AnswerCarousel extends StatefulWidget {
  final Question question;

  const AnswerCarousel({super.key, required this.question});
  @override
  _AnswerCaruselState createState() => _AnswerCaruselState(question);
}

class _AnswerCaruselState extends State<AnswerCarousel> {
  final Question question;
  late PageController _pageController;
  int initalPage = 1;
  List<Answer> answers = [];
  var loading = false;

  _AnswerCaruselState(this.question);

  Future<Null> getData() async {
    setState(() {
      loading = true;
    });

    final responseData = await http.get(
        Uri.parse("$baseUrl/GetAnswers?question_id=${question.id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          answers.add(Answer.fromJson(i));
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
          scrollBehavior: AppScrollBehavior(),
          onPageChanged: (value) {
            setState(() {
              initalPage = value;
            });
          },
          controller: _pageController,
          physics: const ClampingScrollPhysics(),
          itemCount: answers.length,
          itemBuilder: (context, index) => buildGroupSlider(index),
        ),
      ),
    );
  }

  Widget buildGroupSlider(int index) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 0;
        if (_pageController.position.haveDimensions) {
          value = index - _pageController.page!;
          value = (value * 0.038).clamp(-1, 1);
        }
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 350),
          opacity: initalPage == index ? 1 : 0.4,
          child: Transform.rotate(
            angle: math.pi * value,
            child: AnswerCard(
              answer: answers[index],
            ),
          ),
        );
      },
    );
  }
}
