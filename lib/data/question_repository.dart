import '../models/question_model.dart';

class QuestionRepository {
  List<Question> getQuestions() {
    return [
      Question(
        questionText: "What is Flutter?",
        options: [
          "A database management system",
          "A UI framework by Google",
          "A programming language",
          "An operating system",
        ],
        correctAnswerIndex: 1,
      ),

      Question(
        questionText: "What is the main programming language used in Flutter?",
        options: ["Java", "Kotlin", "Dart", "Swift"],
        correctAnswerIndex: 2,
      ),

      Question(
        questionText: "Which Flutter widget is used for scrolling content?",
        options: ["Container", "Column", "ListView", "Row"],
        correctAnswerIndex: 2,
      ),

      Question(
        questionText: "What does the '?' operator do in Dart null safety?",
        options: [
          "Makes a variable nullable",
          "Makes a variable non-nullable",
          "Checks if two values are equal",
          "Performs type casting",
        ],
        correctAnswerIndex: 0,
      ),

      Question(
        questionText:
            "When should you use a StatefulWidget instead of StatelessWidget?",
        options: [
          "When the UI doesn't change",
          "When the widget needs to rebuild dynamically",
          "For all widgets by default",
          "Only for animations",
        ],
        correctAnswerIndex: 1,
      ),

      Question(
        questionText: "What is the purpose of 'async' and 'await' in Dart?",
        options: [
          "To handle errors",
          "To write asynchronous code",
          "To create classes",
          "To manage memory",
        ],
        correctAnswerIndex: 1,
      ),

      Question(
        questionText: "What is BuildContext in Flutter?",
        options: [
          "A widget tree location reference",
          "A database context",
          "An animation controller",
          "A network request handler",
        ],
        correctAnswerIndex: 0,
      ),

      Question(
        questionText:
            "Which method is called first when an Android Activity is created?",
        options: ["onStart()", "onResume()", "onCreate()", "onPause()"],
        correctAnswerIndex: 2,
      ),

      Question(
        questionText:
            "Which method is called when an iOS ViewController's view is loaded?",
        options: [
          "viewDidLoad()",
          "viewWillAppear()",
          "viewDidAppear()",
          "loadView()",
        ],
        correctAnswerIndex: 0,
      ),

      Question(
        questionText:
            "What is the difference between Future and Stream in Dart?",
        options: [
          "Future returns one value, Stream returns multiple values",
          "Stream returns one value, Future returns multiple values",
          "Both are the same",
          "Future is for errors, Stream is for data",
        ],
        correctAnswerIndex: 0,
      ),
    ];
  }
}
