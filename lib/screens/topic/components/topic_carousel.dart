import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/models/topic.dart';
import 'package:flutter_tests/screens/topic/components/topic_card.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class TopicCarousel extends StatefulWidget {
  final Book book;

  const TopicCarousel({super.key, required this.book});
  @override
  _TopicCaruselState createState() => _TopicCaruselState(book);
}

class _TopicCaruselState extends State<TopicCarousel> {
  final Book book;
  late PageController _pageController;
  int initalPage = 1;
  List<Topic> topics = [];
  var loading = false;

  _TopicCaruselState(this.book);

  Future<Null> getData() async {
    setState(() {
      loading = true;
    });

    final responseData = await http.get(Uri.parse(
        "http://complexprogrammer.uz/GetTopics?book_id=${book.id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          topics.add(Topic.fromJson(i));
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
          itemCount: topics.length,
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
            child: TopicCard(
              topic: topics[index],
            ),
          ),
        );
      },
    );
  }
}
