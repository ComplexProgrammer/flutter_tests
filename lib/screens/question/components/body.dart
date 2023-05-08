import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/answer.dart';
import 'package:flutter_tests/models/question.dart';
import 'package:flutter_tests/models/topic.dart';
import 'package:flutter_tests/screens/question/components/backdrop.dart';
import 'package:flutter_tests/screens/question/components/question_carousel.dart';
import 'package:http/http.dart' as http;

class Body extends StatelessWidget {
  final Topic topic;

  const Body({super.key, required this.topic});
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Backdrop(size: size, topic: topic),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: MyStatefulWidget(
              topic: topic,
            ),
          ),
          // QuestionCarousel(
          //   topic: topic,
          // ),
        ],
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget {
  final Topic topic;
  const MyStatefulWidget({super.key, required this.topic});

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState(topic);
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final Topic topic;
  late PageController _pageController;
  int initalPage = 1;
  List<Question> questions = [];
  List<Answer> answers = [];
  var loading = false;
  Answer? selectedRadio;

  _MyStatefulWidgetState(this.topic);

  Future<void> getData() async {
    setState(() {
      loading = true;
    });

    final responseData = await http.get(Uri.parse(
        "http://complexprogrammer.uz/GetQuestions?topic_id=${topic.id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          questions.add(Question.fromJson(i));
        }
        loadAswers(1);
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
            children: [
              if (!loading)
                Text(questions[currentPage - 1].name_uz_uz.toString()),
              for (Answer i in answers)
                RadioListTile<Answer>(
                  title: Text("${i.name_uz_uz} ${i.right}"),
                  selectedTileColor: Colors.red,
                  value: i,
                  groupValue: selectedRadio,
                  onChanged: (value) {
                    print(value!.name_uz_uz);
                    setState(() {
                      if (value.right) i = value;
                      setSelectedRadio(value);
                    });
                  },
                ),
              if (!loading)
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
                    loadAswers(number);
                    setState(() {
                      currentPage = number;
                    });
                  },
                  useGroup: false,
                  totalPage: questions.length,
                  show: 1,
                  currentPage: currentPage,
                ),
            ],
          );
  }

  Future<void> loadAswers(int id) async {
    answers = [];
    final responseData = await http.get(Uri.parse(
        "http://complexprogrammer.uz/GetAnswers?question_id=${id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        for (Map<String, dynamic> i in data) {
          answers.add(Answer.fromJson(i));
        }
      });
    }
  }
}
