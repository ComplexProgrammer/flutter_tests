import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/book/components/book_card.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class BookCarousel extends StatefulWidget {
  final Group group;

  const BookCarousel({super.key, required this.group});
  @override
  _BookCaruselState createState() => _BookCaruselState(group);
}

class _BookCaruselState extends State<BookCarousel> {
  final Group group;
  late PageController _pageController;
  int initalPage = 1;
  List<Book> books = [];
  var loading = false;

  _BookCaruselState(this.group);

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    final responseData = await http.get(Uri.parse(
        "http://complexprogrammer.uz/GetBooks?group_id=${group.id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          books.add(Book.fromJson(i));
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
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
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
                itemCount: books.length,
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
            child: BookCard(
              book: books[index],
              group: group,
            ),
          ),
        );
      },
    );
  }
}
