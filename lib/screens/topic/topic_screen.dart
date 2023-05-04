import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/screens/topic/components/body.dart';

class TopicScreen extends StatelessWidget {
  final Book book;

  const TopicScreen({super.key, required this.book});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        book: book,
      ),
    );
  }
}
