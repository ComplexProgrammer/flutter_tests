import 'package:flutter/material.dart';
import 'package:flutter_tests/models/group.dart';
import 'package:flutter_tests/screens/details/components/body.dart';

class DetailsScreen extends StatelessWidget {
  final Group group;

  const DetailsScreen({super.key, required this.group});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Body(
        group: group,
      ),
    );
  }
}
