import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:job_interview_quiz_app/screens/homescreen.dart';
import 'package:job_interview_quiz_app/screens/quiz_screen.dart';
import 'package:job_interview_quiz_app/screens/success_Screen.dart';

class Approutes {
  static const String homeRoute = '/home';
  static const String quizScreen = '/quizScreen';
  static const String resultScreen = '/resultScreen';

  static List<GetPage> routes = [
    GetPage(name: homeRoute, page: () => HomeScreen()),
    GetPage(name: quizScreen, page: () => QuizScreen()),
    GetPage(name: resultScreen, page: () => SuccessScreen()),
  ];
}
