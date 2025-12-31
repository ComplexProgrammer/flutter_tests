import 'dart:async';
import 'dart:convert';
// import 'dart:html';
import 'package:collection/collection.dart';
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
import 'package:flutter_tests/screens/ads/banner.dart';
import 'package:flutter_tests/screens/question/components/CustomRadio.dart';
import 'package:flutter_tests/screens/question/components/backdrop.dart';
import 'package:flutter_tests/screens/question/components/time.dart';
import 'package:flutter_tests/screens/topic/topic_screen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../models/group.dart';
import '../question_screen.dart';
import 'body.dart';

int togri_javoblar_soni = 0;
int notogri_javoblar_soni = 0;
int all_question = 0;
int time = 900;
int minutes = 15;
final seconds = 0;

class selected_answer {
  int topicId;
  int questionId;
  int answerId;
  bool right;
  int time;
  selected_answer({
    required this.topicId,
    required this.questionId,
    required this.answerId,
    required this.right,
    required this.time,
  });
  Map toJson() => {
        'topicId': topicId,
        'questionId': questionId,
        'answerId': answerId,
        'right': right,
        'time': time,
      };
}

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
List<selected_answer> selectedAnswers = [];

class Body extends StatelessWidget {
  final Topic topic;
  final Book book;
  final Group group;
  // final int tjs;
  // final int njs;

  const Body({
    super.key,
    required this.topic,
    required this.book,
    required this.group,
    // required this.tjs,
    // required this.njs
  });
  @override
  Widget build(BuildContext context) {
    // togri_javoblar_soni = tjs;
    // notogri_javoblar_soni = njs;
    Timer? countdownTimer;
    Duration myDuration = Duration(minutes: minutes, seconds: seconds);
    bool isPaused = false;

    // prefs.setStringList('javoblar', <String>[]);
    // prefs.setString('javoblar', '');

    Size size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Backdrop(size: size, topic: topic),
          MyBannerAdWidget(),
          // Time(minutes: minutes, seconds: seconds),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding / 10),
            child: MyStatefulWidget(topic: topic, book: book, group: group),
          ),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding / 10),
            child: ElevatedButton(
              onPressed: () {
                isPaused = true;
                _showDialog(context, topic, book, group, isPaused);
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

void _showDialog(
    BuildContext context, Topic topic, Book book, Group group, bool isPaused) {
  int belgilanmagan_savollar =
      all_question - togri_javoblar_soni - notogri_javoblar_soni;

  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: kBackgroundColor,
      title: const Text(
        'Test Natijalari',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: kTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      icon: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kPrimaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.analytics, color: kPrimaryColor, size: 32),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildResultItem(
              'To`g`ri javoblar', togri_javoblar_soni.toString(), Colors.green),
          _buildResultItem('Noto`g`ri javoblar',
              notogri_javoblar_soni.toString(), Colors.red),
          if (belgilanmagan_savollar > 0)
            _buildResultItem('Belgilanmagan', belgilanmagan_savollar.toString(),
                Colors.grey),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TopicScreen(book: book, group: group)),
            ),
            icon: const Icon(Icons.topic),
            label: const Text('Mavzularga qaytish'),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => nextTopic(context, topic, book, group, true),
            icon: const Icon(Icons.refresh),
            label: const Text('Qayta boshlash'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yopish'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildResultItem(String label, String value, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: kTextLightColor)),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 18)),
      ],
    ),
  );
}

void nextTopic(BuildContext context, Topic topic, Book book, Group group,
    bool refresh) async {
  final SharedPreferences prefs = await _prefs;
  if (refresh && selectedAnswers.isNotEmpty) {
    selectedAnswers = selectedAnswers
        .where((element) => element.topicId != topic.id)
        .toList();
    prefs.setString('selected_answers', jsonEncode(selectedAnswers));
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => QuestionScreen(
        topic: topic,
        book: book,
        group: group,
      ),
    ),
  );
}

void checkJavoblar(SharedPreferences prefs) async {
  // prefs.setStringList("javoblar", []);
  // prefs.setString('selected_answers', '[]');
  // final SharedPreferences prefs = await _prefs;
  final String selected_answers = prefs.getString('selected_answers') ?? '[]';
  print(selected_answers);
  var tagsJson = jsonDecode(selected_answers);
  List? tags = tagsJson != null ? List.from(tagsJson) : null;
  for (var element in tags!) {
    selectedAnswers.add(selected_answer(
        topicId: element["topicId"],
        questionId: element["questionId"],
        answerId: element["answerId"],
        right: element["right"],
        time: element["time"]));
  }
}

class MyStatefulWidget extends StatefulWidget {
  final Topic topic;
  final Book book;
  final Group group;
  const MyStatefulWidget(
      {super.key,
      required this.topic,
      required this.book,
      required this.group});

  @override
  State<MyStatefulWidget> createState() =>
      _MyStatefulWidgetState(topic, book, group);
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _selected_answer;

  Future<void> setAnswer(Answer answer) async {
    selected_answer selectedAnswer = new selected_answer(
        topicId: this.topic.id,
        questionId: this.question.id,
        answerId: answer.id,
        right: answer.right,
        time: minutes);
    String json = jsonEncode(selectedAnswer);
    final SharedPreferences prefs = await _prefs;
    setState(() {
      if (selectedAnswers.isEmpty) {
        selectedAnswers.add(selectedAnswer);
      } else {
        // ignore: unrelated_type_equality_checks, unrelated_type_equality_checks
        if (selectedAnswers.firstWhereOrNull(
                (element) => element.questionId == selectedAnswer.questionId) ==
            null) {
          selectedAnswers.add(selectedAnswer);
        }
      }
      _selected_answer = prefs
          .setString('selected_answers', jsonEncode(selectedAnswers))
          .then((bool success) {
        return selectedAnswers.toString();
      });
    });
  }

  final player = AudioPlayer();
  final Topic topic;
  final Book book;
  final Group group;
  late PageController _pageController;
  int initalPage = 1;
  int questionNumber = 0;
  Question question = Question(
    id: 0,
    name_en_us: '',
    name_ru_ru: '',
    name_uz_crl: '',
    name_uz_uz: '',
    image: '',
    number: 0,
    selectedAnswer: null,
  );
  List<Question> questions = [];
  List<Answer> answers = [];
  List<RadioModel> sampleData = [];
  var loading = false;
  Answer? selectedRadio;
  _MyStatefulWidgetState(this.topic, this.book, this.group);

  Future<void> getData() async {
    final SharedPreferences prefs = await _prefs;
    checkJavoblar(prefs);
    setState(() {
      loading = true;
    });
    questions = [];
    final responseData = await http.get(Uri.parse(
        "$baseUrl/tests/GetQuestions?topic_id=${topic.id.toString()}"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);
      setState(() {
        int number = 0;
        int togri_javob_soni = 0;
        int notogri_javob_soni = 0;
        Question question = this.question;
        List<Question> questions = this.questions;
        //List<selected_answer> selectedAnswers = this.selectedAnswers;
        for (Map<String, dynamic> i in data) {
          question.selectedAnswer = null;
          if (selectedAnswers.firstWhereOrNull(
                  (element) => element.questionId == Question.fromJson(i).id) !=
              null) {
            question.selectedAnswer = selectedAnswers.firstWhere(
                (element) => element.questionId == Question.fromJson(i).id);
          }
          if (question.selectedAnswer != null) {
            i["selectedAnswer"] = question.selectedAnswer;
          }
          questions.add(Question.fromJson(i));
        }
        if (questions.isNotEmpty) {
          all_question = questions.length;
          questions.sort((a, b) {
            return a.number - b.number;
          });
          for (var element in questions) {
            if (element.number > number &&
                number == element.number - 1 &&
                element.selectedAnswer?.answerId != null) {
              number = element.number;
            }
            if (element.selectedAnswer != null) {
              if (element.selectedAnswer!.right) {
                togri_javob_soni = togri_javob_soni + 1;
              } else {
                notogri_javob_soni = notogri_javob_soni + 1;
              }
            }
          }
          if (selectedAnswers
                  .where((element) => element.topicId == topic.id)
                  .length ==
              questions.length) {
            _showDialog(context, topic, book, group, true);
          } else {
            questionNumber = number + 1;
          }
          if (questionNumber == 0) {
            questionNumber = 1;
          }
          togri_javoblar_soni = togri_javob_soni;
          notogri_javoblar_soni = notogri_javob_soni;
          setData(questionNumber);
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
  int belgilanmagan = 0;
  bool _enabled = true;
  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return Column(
        children: [
          if (!loading && all_question > 0)
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
              onPageChange: (number) async {
                try {
                  //player.play(UrlSource('$baseUrl/static/sounds/click.mp3'));
                  await player.play(AssetSource('raw/click.mp3'));
                } on Exception catch (_) {
                  print('sound play error');
                }
                setData(number);
                if (question.selectedAnswer == null) {
                  _enabled = true;
                } else {
                  _enabled = false;
                }
                setState(() {
                  currentPage = number;
                });
              },
              useGroup: false,
              totalPage: all_question,
              show: 2,
              currentPage: currentPage,
            ),
          Text(
            question.name_uz_uz.toString(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          ListView.builder(
            shrinkWrap: true,
            itemCount: sampleData.length,
            padding: EdgeInsets.all(1.0),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                highlightColor: Colors.yellow.withOpacity(0.3),
                splashColor: Colors.red.withOpacity(0.8),
                focusColor: Colors.green.withOpacity(0.0),
                hoverColor: Colors.blue.withOpacity(0.8),
                onTap: _enabled
                    ? () async {
                        _enabled = false;
                        try {
                          if (sampleData[index].answer.right) {
                            togri_javoblar_soni = togri_javoblar_soni + 1;
                            player.play(
                              await AssetSource('raw/right.mp3'),
                            );
                          } else {
                            notogri_javoblar_soni++;
                            player.play(
                              await AssetSource('raw/wrong.mp3'),
                            );
                          }
                        } on Exception catch (_) {
                          print('sound play error');
                        }

                        setState(() {
                          for (var element in sampleData) {
                            element.answer.right
                                ? element.correctAnswer = true
                                : element.correctAnswer = false;
                          }
                          for (var element in sampleData) {
                            element.isSelected = false;
                          }
                          sampleData[index].isSelected = true;
                          setAnswer(sampleData[index].answer);
                        });
                      }
                    : null,
                child: RadioItem(sampleData[index]),
              );
            },
          ),
        ],
      );
    }
  }

  void setData(int questionNumber) {
    question = questions.firstWhere((it) => it.number == questionNumber);
    currentPage = question.number;
    loadAswers(question.id.toString());
    if (selectedAnswers
            .firstWhereOrNull((element) => element.questionId == question.id) !=
        null) {
      question.selectedAnswer = selectedAnswers
          .firstWhere((element) => element.questionId == question.id);
    }
  }

  Future<void> loadAswers(String questionId) async {
    answers = [];
    sampleData = [];
    final responseData = await http
        .get(Uri.parse("$baseUrl/GetAnswers?question_id=$questionId"));
    if (responseData.statusCode == 200) {
      final data = jsonDecode(responseData.body);

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
          if (index == 5) buttonText = 'E';
          if (index == 6) buttonText = 'F';
          if (index == 7) buttonText = 'G';
          if (index == 8) buttonText = 'H';
          if (index == 9) buttonText = 'J';
          if (index == 10) buttonText = 'K';
          sampleData.add(RadioModel(question, i, false, false, buttonText));
        }
      });
    }
  }
}
