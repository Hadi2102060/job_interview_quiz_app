import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:job_interview_quiz_app/models/question_model.dart';
import 'package:job_interview_quiz_app/routes/appRoutes.dart';
import '../data/question_repository.dart';
import '../widgets/answer_card.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  final QuestionRepository _repository = QuestionRepository();
  late List<Question> _questions;
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  int _score = 0;
  bool _isAnswerChecked = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _questions = _repository.getQuestions();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(begin: Offset(0.3, 0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _checkAnswerAndProceed() {
    if (_selectedAnswerIndex == null) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select an answer"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isAnswerChecked = true;
    });

    HapticFeedback.mediumImpact();

    // Check if answer is correct
    bool isCorrect =
        _selectedAnswerIndex == _questions[_currentIndex].correctAnswerIndex;
    if (isCorrect) {
      setState(() {
        _score++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text("Congratulations! Correct Answer"),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 800),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.cancel, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Wrong Answer! Correct: ${_questions[_currentIndex].options[_questions[_currentIndex].correctAnswerIndex]}",
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _resetQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _isAnswerChecked = false;

      _animationController.reset();
      _animationController.forward();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.refresh, color: Colors.white),
            SizedBox(width: 10),
            Text("Quiz restarted! Good luck! "),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _goToNextQuestion() {
    if (!_isAnswerChecked) {
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please answer the question first"),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade700,
        ),
      );
      return;
    }

    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswerChecked = false;
      });
      _animationController.reset();
      _animationController.forward();
    } else {
      Get.toNamed(
        AppRoutes.resultScreen,
        arguments: {
          'score': _score,
          'total': _questions.length,
          'onRestart': _resetQuiz,
          'onExit': () {
            Get.offAllNamed(AppRoutes.homeRoute);
          },
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Question currentQuestion = _questions[_currentIndex];
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Job Interview Quiz",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 18),
                SizedBox(width: 4),
                Text(
                  "$_score",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Question ${_currentIndex + 1} of ${_questions.length}",
                    style: GoogleFonts.poppins(
                      color: Colors.blue.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / _questions.length,
                    backgroundColor: Colors.grey.shade200,
                    color: Colors.blue.shade400,
                    minHeight: 8,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  currentQuestion.questionText,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 32),
                Expanded(
                  child: ListView.builder(
                    itemCount: currentQuestion.options.length,
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: AnswerCard(
                          text: currentQuestion.options[index],
                          isSelected: _selectedAnswerIndex == index,
                          isCorrect:
                              _isAnswerChecked &&
                              index == currentQuestion.correctAnswerIndex,
                          isWrong:
                              _isAnswerChecked &&
                              _selectedAnswerIndex == index &&
                              index != currentQuestion.correctAnswerIndex,
                          onTap: _isAnswerChecked
                              ? null
                              : () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _selectedAnswerIndex = index;
                                    _checkAnswerAndProceed();
                                  });
                                },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16),
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: _isAnswerChecked ? _goToNextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: _isAnswerChecked ? 0 : 5,
                    ),
                    child: Text(
                      _currentIndex + 1 == _questions.length
                          ? "Finish Quiz"
                          : "Next Question",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
