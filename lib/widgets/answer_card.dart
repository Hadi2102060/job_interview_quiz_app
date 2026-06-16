import 'package:flutter/material.dart';

class AnswerCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback? onTap;

  const AnswerCard({
    super.key,
    required this.text,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color getBgColor() {
      if (isCorrect) return Colors.green.shade50;
      if (isWrong) return Colors.red.shade50;
      if (isSelected) return Colors.blue.shade50;
      return Colors.white;
    }

    Color getBorderColor() {
      if (isCorrect) return Colors.green;
      if (isWrong) return Colors.red;
      if (isSelected) return Colors.blue;
      return Colors.grey.shade300;
    }

    IconData? getLeadingIcon() {
      if (isCorrect) return Icons.check_circle;
      if (isWrong) return Icons.cancel;
      if (isSelected) return Icons.radio_button_checked;
      return Icons.radio_button_unchecked;
    }

    Color getIconColor() {
      if (isCorrect) return Colors.green;
      if (isWrong) return Colors.red;
      if (isSelected) return Colors.blue;
      return Colors.grey;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: getBgColor(),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: getBorderColor(),
            width: isSelected || isCorrect || isWrong ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(getLeadingIcon(), color: getIconColor(), size: 22),
            SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: (isSelected || isCorrect || isWrong)
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
            ),
            if (isCorrect)
              Icon(Icons.emoji_emotions, color: Colors.green, size: 24),
            if (isWrong)
              Icon(Icons.sentiment_dissatisfied, color: Colors.red, size: 24),
          ],
        ),
      ),
    );
  }
}
