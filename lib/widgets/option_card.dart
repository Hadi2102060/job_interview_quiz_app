import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Premium replacement for the existing AnswerCard. Adds a letter
/// avatar, large surface and animated reveal after answer.
class OptionCard extends StatelessWidget {
  final String text;
  final int index;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final bool showResult;
  final VoidCallback? onTap;

  const OptionCard({
    super.key,
    required this.text,
    required this.index,
    this.isSelected = false,
    this.isCorrect = false,
    this.isWrong = false,
    this.showResult = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color border;
    Color background;
    Color letterBg;
    Color letterFg;
    Widget? trailing;

    if (showResult && isCorrect) {
      border = AppColors.success;
      background = AppColors.success.withValues(alpha: 0.10);
      letterBg = AppColors.success;
      letterFg = Colors.white;
      trailing = const Icon(Icons.check_circle, color: AppColors.success);
    } else if (showResult && isWrong) {
      border = AppColors.error;
      background = AppColors.error.withValues(alpha: 0.10);
      letterBg = AppColors.error;
      letterFg = Colors.white;
      trailing = const Icon(Icons.cancel, color: AppColors.error);
    } else if (isSelected) {
      border = AppColors.primary;
      background = AppColors.primary.withValues(alpha: 0.08);
      letterBg = AppColors.primary;
      letterFg = Colors.white;
    } else {
      border = AppColors.border;
      background = Colors.white;
      letterBg = AppColors.surface;
      letterFg = AppColors.textSecondary;
    }

    final letter = String.fromCharCode(65 + index);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: AppDuration.fast,
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: border, width: isSelected || showResult ? 2 : 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: letterBg,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      letter,
                      style: AppText.headline(14, weight: FontWeight.bold, color: letterFg),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      text.replaceFirst(RegExp(r'^[A-D]\.\s*'), ''),
                      style: AppText.body(15,
                          weight: isSelected || showResult ? FontWeight.w600 : FontWeight.normal,
                          color: AppColors.textPrimary),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}