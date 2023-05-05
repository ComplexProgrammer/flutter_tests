import 'package:flutter/material.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/question.dart';
import 'package:flutter_tests/screens/answer/components/backdrop.dart';
import 'package:flutter_tests/screens/answer/components/answer_carousel.dart';

class Body extends StatelessWidget {
  final Question question;

  const Body({super.key, required this.question});
  @override
  Widget build(BuildContext context) {
    // return const Scaffold(
    //   body: MyStatefulWidget(),
    // );
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Backdrop(size: size, question: question),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              children: [
                Text(
                  question.name_uz_uz,
                  style: Theme.of(context).textTheme.headline5,
                ),
              ],
            ),
          ),
          // AnswerCarousel(
          //   question: question,
          // ),
        ],
      ),
    );
  }
}

enum SingingCharacter { lafayette, jefferson }

class MyStatefulWidget extends StatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  SingingCharacter? _character = SingingCharacter.lafayette;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RadioListTile<SingingCharacter>(
          title: const Text('Lafayette'),
          value: SingingCharacter.lafayette,
          groupValue: _character,
          onChanged: (SingingCharacter? value) {
            setState(() {
              _character = value;
            });
          },
        ),
        RadioListTile<SingingCharacter>(
          title: const Text('Thomas Jefferson'),
          value: SingingCharacter.jefferson,
          groupValue: _character,
          onChanged: (SingingCharacter? value) {
            setState(() {
              _character = value;
            });
          },
        ),
      ],
    );
  }
}
