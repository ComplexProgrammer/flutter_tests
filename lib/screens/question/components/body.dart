import 'dart:convert';

import 'package:animations/animations.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagination/flutter_pagination.dart';
import 'package:flutter_pagination/widgets/button_styles.dart';
import 'package:flutter_tests/constants.dart';
import 'package:flutter_tests/models/answer.dart';
import 'package:flutter_tests/models/book.dart';
import 'package:flutter_tests/models/question.dart';
import 'package:flutter_tests/models/topic.dart';
import 'package:flutter_tests/screens/question/components/backdrop.dart';
import 'package:flutter_tests/screens/topic/topic_screen.dart';
import 'package:http/http.dart' as http;

import '../../../models/group.dart';

class Body extends StatelessWidget {
  final Topic topic;
  final Book book;
  final Group group;

  const Body(
      {super.key,
      required this.topic,
      required this.book,
      required this.group});
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
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => AlertDialog(
                    insetPadding: const EdgeInsets.symmetric(vertical: 150),
                    contentPadding: EdgeInsets.zero,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    // backgroundColor: Colors.transparent,
                    title: const Text('Natijalar'),
                    icon: const Icon(Icons.restore_outlined),
                    titlePadding: const EdgeInsets.all(kDefaultPadding / 2),
                    content: Column(
                      children: [
                        const Text(
                          'To`g`ri javoblar: ',
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                        const Text(
                          'Noto`g`ri javoblar: ',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                        const Text(
                          'Belgilanmagan savollar: ',
                          style: TextStyle(color: Colors.grey),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TopicScreen(
                                book: book,
                                group: group,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.topic,
                            size: 24.0,
                          ),
                          label: const Text('Mavzular'), // <-- Text
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            debugPrint('ElevatedButton Clicked');
                            // Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.start,
                            size: 24.0,
                          ),
                          label: const Text('Davom etish'),
                          style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder()),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            debugPrint('ElevatedButton Clicked');
                          },
                          icon: const Icon(
                            Icons.start,
                            size: 24.0,
                          ),
                          label: const Text('Davom etish 2'),
                        ),
                      ],
                    ),
                    // content: const Image(
                    //   image: NetworkImage(
                    //       'https://complexprogrammer.uz/static/img/school_tests_bg.png'),
                    // ),
                    // actions: [
                    //   TextButton(
                    //     child: const Text('close'),
                    //     onPressed: () => Navigator.pop(context),
                    //   ),
                    //   // TextButton(
                    //   //   child: const Text('OK'),
                    //   //   onPressed: () {
                    //   //     Navigator.push(
                    //   //       context,
                    //   //       MaterialPageRoute(
                    //   //         builder: (context) => TopicScreen(book: book),
                    //   //       ),
                    //   //     );
                    //   //   },
                    //   // ),
                    // ],
                  ),
                );
              },
              child: const Text('Yakunlash'),
            ),
          )
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
                    // final player = AudioPlayer();
                    // player.play(UrlSource(
                    //     'https://complexprogrammer.uz/static/sounds/right.mp3'));
                    // _audioCache.play('right.mp3');
                    AudioCache player = AudioCache();
                    // player.play('right.mp3');
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
                    // backgroundColor: Colors.pink,
                    activeBackgroundColor: Colors.redAccent,
                    activeTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                  prevButtonStyles: PaginateSkipButton(
                    // buttonBackgroundColor: Colors.orange,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  nextButtonStyles: PaginateSkipButton(
                    // buttonBackgroundColor: Colors.purple,
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
