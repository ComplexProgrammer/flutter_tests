import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/book/components/body.dart';

class BookScreen extends StatelessWidget {
  final Group group;

  const BookScreen({super.key, required this.group});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        group: group,
      ),
    );
  }
}
