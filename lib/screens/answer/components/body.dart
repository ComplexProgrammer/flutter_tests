import 'dart:convert';
import 'dart:ffi';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/answer.dart';
import 'package:flutter_tests/models/question.dart';
import 'package:flutter_tests/screens/answer/components/backdrop.dart';
import 'package:http/http.dart' as http;

class Body extends StatelessWidget {
  final Question question;

  const Body({super.key, required this.question});
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Backdrop(size: size, question: question),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: MyStatefulWidget(
              question: question,
            ),
            // child: Column(
            //   children: [
            //     Text(
            //       question.name_uz_uz,
            //       style: Theme.of(context).textTheme.headline5,
            //     ),
            //   ],
            // ),
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
  final Question question;
  const MyStatefulWidget({super.key, required this.question});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState(question);
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final Question question;
  late PageController _pageController;
  int initalPage = 1;
  List<Answer> answers = [];
  var loading = false;
  Answer? selectedRadio;

  _MyStatefulWidgetState(this.question);

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    final responseData = await http.get(Uri.parse(
        "http://complexprogrammer.uz/GetAnswers?question_id=${question.id.toString()}"));
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

  setSelectedRadio(val) {
    setState(() {
      selectedRadio = val;
    });
  }

  int currentPage = 1;
  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: <Widget>[
              for (Answer i in answers)
                RadioListTile<Answer>(
                  title: Text(i.name_uz_uz),
                  value: i,
                  groupValue: selectedRadio,
                  onChanged: (value) {
                    print(value!.name_uz_uz);
                    setState(() {
                      i = value;
                      setSelectedRadio(value);
                    });
                  },
                ),
              Pagination(
                paginateButtonStyles: PaginateButtonStyles(
                  backgroundColor: Colors.pink,
                  activeBackgroundColor: Colors.green,
                  activeTextStyle: const TextStyle(color: Colors.red),
                ),
                prevButtonStyles: PaginateSkipButton(
                  buttonBackgroundColor: Colors.orange,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
                nextButtonStyles: PaginateSkipButton(
                  buttonBackgroundColor: Colors.purple,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                onPageChange: (number) {
                  setState(() {
                    currentPage = number;
                  });
                },
                useGroup: false,
                totalPage: 10,
                show: 1,
                currentPage: currentPage,
              ),
              // RadioListTile<SingingCharacter>(
              //   title: const Text('Thomas Jefferson'),
              //   value: SingingCharacter.jefferson,
              //   groupValue: _character,
              //   onChanged: (SingingCharacter? value) {
              //     setState(() {
              //       _character = value;
              //     });
              //   },
              // ),
            ],
          );
  }
}
