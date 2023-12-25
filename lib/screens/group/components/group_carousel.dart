import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/group/components/group_card.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class GroupCarousel extends StatefulWidget {
  @override
  _GroupCaruselState createState() => _GroupCaruselState();
}

class _GroupCaruselState extends State<GroupCarousel> {
  late PageController _pageController;
  int initalPage = 1;
  List<Group> groups = [];
  var loading = false;

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    final responseData =
        await http.get(Uri.parse("http://complexprogrammer.uz/GetGroups/"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          groups.add(Group.fromJson(i));
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
                onPageChanged: (value) {
                  setState(() {
                    initalPage = value;
                  });
                },
                controller: _pageController,
                physics: const ClampingScrollPhysics(),
                itemCount: groups.length,
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
            child: GroupCard(
              group: groups[index],
            ),
          ),
        );
      },
    );
  }
}
