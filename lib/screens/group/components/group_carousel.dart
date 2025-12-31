import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/group/components/group_card.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class GroupCarousel extends StatefulWidget {
  const GroupCarousel({super.key});

  @override
  _GroupCaruselState createState() => _GroupCaruselState();
}

class _GroupCaruselState extends State<GroupCarousel>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _shimmerController;
  int initalPage = 1;
  List<Group> groups = [];
  var loading = false;

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    final responseData =
        await http.get(Uri.parse("$baseUrl/tests/GetGroups/?type_id=2"));
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
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? _buildShimmerLoading()
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
            child: AspectRatio(
              aspectRatio: 1.05,
              child: PageView.builder(
                scrollBehavior: AppScrollBehavior(),
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

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kDefaultPadding),
      child: AspectRatio(
        aspectRatio: 1.05,
        child: Center(
          child: AnimatedBuilder(
            animation: _shimmerController,
            builder: (context, child) {
              return Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: kDefaultPadding * 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(kCardBorderRadius),
                  gradient: LinearGradient(
                    begin: Alignment(-1.0 + 2 * _shimmerController.value, -0.3),
                    end: Alignment(0.0 + 2 * _shimmerController.value, 0.3),
                    colors: [
                      kShimmerBaseColor,
                      kShimmerHighlightColor,
                      kShimmerBaseColor,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: const [kCardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(kCardBorderRadius),
                          ),
                          color: kShimmerBaseColor.withOpacity(0.5),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.image_outlined,
                            size: 48,
                            color: kTextLightColor.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(kCardBorderRadius),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: kShimmerBaseColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 12,
                            width: 120,
                            decoration: BoxDecoration(
                              color: kShimmerBaseColor.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
