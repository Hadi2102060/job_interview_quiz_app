class Question {
  final String questionText;
  final List<String> options;
  final int correctAnswerIndex; // 0-based

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswerIndex,
  });
}
