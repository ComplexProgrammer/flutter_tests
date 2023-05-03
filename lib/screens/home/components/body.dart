import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/home/components/categories.dart';
import 'package:flutter_tests/screens/home/components/genre.dart';
import 'package:flutter_tests/screens/home/components/group_card.dart';
import 'package:http/http.dart' as http;

class Body extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Categorylist(),
        Genres(),
        GroupCarusel(),
      ],
    );
  }
}

class GroupCarusel extends StatefulWidget {
  @override
  _GroupCaruselState createState() => _GroupCaruselState();
}

class _GroupCaruselState extends State<GroupCarusel> {
  late PageController _pageController;
  int initalPage = 1;
  List<Group> groups = [];
  var loading = false;

  Future<Null> getData() async {
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
    _pageController = PageController();
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
          itemCount: groups.length,
          itemBuilder: (context, index) => GroupCard(
            group: groups[index],
          ),
        ),
      ),
    );
  }
}
