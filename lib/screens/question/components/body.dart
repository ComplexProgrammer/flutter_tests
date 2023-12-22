import 'dart:async';
import 'dart:convert';
// import 'dart:html';

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
import 'package:flutter_tests/screens/question/components/CustomRadio.dart';
import 'package:flutter_tests/screens/question/components/backdrop.dart';
import 'package:flutter_tests/screens/topic/topic_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/group.dart';
import '../question_screen.dart';

int togri_javoblar_soni = 0;
int notogri_javoblar_soni = 0;
int all_question = 0;

class Body extends StatelessWidget {
  final Topic topic;
  final Book book;
  final Group group;
  final int tjs;
  final int njs;

  const Body(
      {super.key,
      required this.topic,
      required this.book,
      required this.group,
      required this.tjs,
      required this.njs});
  @override
  Widget build(BuildContext context) {
    togri_javoblar_soni = tjs;
    notogri_javoblar_soni = njs;
    final minutes = 15;
    final seconds = 0;
    Timer? countdownTimer;
    Duration myDuration = Duration(minutes: minutes, seconds: seconds);
    bool isPaused = false;

    // final SharedPreferences prefs =
    //     SharedPreferences.getInstance() as SharedPreferences;
    // prefs.setStringList('javoblar', <String>['Earth', 'Moon', 'Sun']);
    // prefs.setString('javoblar', '');

    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Backdrop(size: size, topic: topic),
          TweenAnimationBuilder<Duration>(
              duration: Duration(
                minutes: minutes,
                seconds: seconds,
              ),
              tween: Tween(
                  begin: Duration(
                    minutes: minutes,
                    seconds: seconds,
                  ),
                  end: Duration.zero),
              onEnd: () {
                print('Timer ended');
              },
              builder: (BuildContext context, Duration value, Widget? child) {
                final minutes = value.inMinutes;
                final seconds = value.inSeconds % 60;
                var sec =
                    seconds.toString().length == 1 ? '0$seconds' : '$seconds';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Text(
                    '$minutes:$sec',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 30),
                  ),
                );
              }),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding / 10),
            child: MyStatefulWidget(topic: topic
                // togri_javoblar_soni: togri_javoblar_soni,
                // notogri_javoblar_soni: notogri_javoblar_soni
                ),
          ),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding / 10),
            child: ElevatedButton(
              onPressed: () {
                isPaused = true;
                showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) => AlertDialog(
                    insetPadding: const EdgeInsets.symmetric(vertical: 150),
                    contentPadding: EdgeInsets.zero,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    backgroundColor: Colors.transparent,
                    title: const Text('Natijalar'),
                    icon: const Icon(Icons.restore_outlined),
                    titlePadding: const EdgeInsets.all(kDefaultPadding / 2),
                    content: Column(
                      children: [
                        Text(
                          'To`g`ri javoblar: ${togri_javoblar_soni}',
                          style: TextStyle(
                            color: Colors.greenAccent,
                          ),
                        ),
                        Text(
                          'Noto`g`ri javoblar: ${notogri_javoblar_soni}',
                          style: TextStyle(
                            color: Colors.redAccent,
                          ),
                        ),
                        Text(
                          'Belgilanmagan savollar:  ${all_question - togri_javoblar_soni - notogri_javoblar_soni}',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
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
                            Navigator.pop(context);
                            isPaused = false;
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
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuestionScreen(
                                topic: topic,
                                book: book,
                                group: group,
                              ),
                            ),
                          ),
                          icon: const Icon(
                            Icons.start,
                            size: 24.0,
                          ),
                          label: const Text('Keyingi biletga o`tish'),
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
  // final int togri_javoblar_soni;
  // final int notogri_javoblar_soni;
  const MyStatefulWidget({
    super.key,
    required this.topic,
    // required this.togri_javoblar_soni,
    // required this.notogri_javoblar_soni,
  });

  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState(
        topic,
        // togri_javoblar_soni,
        // notogri_javoblar_soni,
      );
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  final player = AudioPlayer();
  final Topic topic;
  // late int togri_javoblar_soni;
  // late int notogri_javoblar_soni;
  late PageController _pageController;
  int initalPage = 1;
  List<Question> questions = [];
  List<Answer> answers = [];
  List<RadioModel> sampleData = [];
  var loading = false;
  Answer? selectedRadio;
  _MyStatefulWidgetState(this.topic
      // this.togri_javoblar_soni,
      // this.notogri_javoblar_soni,
      );

  Future<void> getData() async {
    setState(() {
      loading = true;
    });
    questions = [];
    final responseData = await http.get(Uri.parse(
        "http://complexprogrammer.uz/GetQuestions?topic_id=${topic.id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      print(data);
      setState(() {
        for (Map<String, dynamic> i in data) {
          questions.add(Question.fromJson(i));
        }
        if (questions.isNotEmpty) {
          all_question = questions.length;
          loadAswers(Question.fromJson(data[0]));
        }
        loading = false;
      });
    }
    print(questions);
  }

  @override
  void initState() {
    super.initState();
    // sampleData.add(new RadioModel(false, 'A', 'April 18'));
    // sampleData.add(new RadioModel(false, 'B', 'April 17'));
    // sampleData.add(new RadioModel(false, 'C', 'April 16'));
    // sampleData.add(new RadioModel(false, 'D', 'April 15'));
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
  int belgilanmagan = 0;
  bool _enabled = false;
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          if (!loading && questions.isNotEmpty)
            Text(
              questions[currentPage - 1].name_uz_uz.toString(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 24,
              ),
            ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: sampleData.length,
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: _enabled
                    ? () {
                        _enabled = false;
                        print("object" + _enabled.toString());
                        if (sampleData[index].isRight) {
                          togri_javoblar_soni = togri_javoblar_soni + 1;
                          player.play(
                            UrlSource(
                                'https://complexprogrammer.uz/static/sounds/right.mp3'),
                          );
                        } else {
                          notogri_javoblar_soni++;
                          player.play(
                            UrlSource(
                                'https://complexprogrammer.uz/static/sounds/wrong.mp3'),
                          );
                        }
                        setState(() {
                          for (var element in sampleData) {
                            element.isRight
                                ? element.isClick = true
                                : element.isClick = false;
                          }
                          for (var element in sampleData) {
                            element.isSelected = false;
                          }
                          sampleData[index].isSelected = true;
                        });
                      }
                    : null,
                child: RadioItem(sampleData[index]),
              );
            },
          ),
          if (!loading && questions.isNotEmpty)
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
                player.play(UrlSource(
                    'https://complexprogrammer.uz/static/sounds/click.mp3'));
                print(questions[0].number);
                _enabled = true;
                loadAswers(questions.firstWhere((it) => it.number == number));
                setState(() {
                  currentPage = number;
                });
              },
              useGroup: false,
              totalPage: questions.length,
              show: 2,
              currentPage: currentPage,
            ),
        ],
      );
    }
  }

  Future<void> loadAswers(Question question) async {
    print(question.id);
    answers = [];
    sampleData = [];
    final responseData = await http.get(Uri.parse(
        "http://complexprogrammer.uz/GetAnswers?question_id=${question.id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      print(data);
      setState(() {
        for (Map<String, dynamic> i in data) {
          answers.add(Answer.fromJson(i));
        }
        var index = 0;
        String buttonText = '';
        for (Answer i in answers) {
          index++;
          if (index == 1) buttonText = 'A';
          if (index == 2) buttonText = 'B';
          if (index == 3) buttonText = 'C';
          if (index == 4) buttonText = 'D';
          sampleData
              .add(RadioModel(false, i.right, false, buttonText, i.name_uz_uz));
        }
      });
    }
  }
}
