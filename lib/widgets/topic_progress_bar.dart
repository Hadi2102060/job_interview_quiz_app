import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Labelled linear progress used by Result screen performance breakdown.
class TopicProgressBar extends StatelessWidget {
  final String topic;
  final double value; // 0..1
  final Color color;

  const TopicProgressBar({
    super.key,
    required this.topic,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (value * 100).round();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(topic, style: AppText.body(14, weight: FontWeight.w500)),
              Text('$percent%', style: AppText.body(14, weight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: AppColors.border,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}