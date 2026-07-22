import 'package:flutter/material.dart';

import '../core/category_data.dart';
import '../core/theme.dart';

/// Horizontal scrolling category card shown on the Home dashboard.
class CategoryCard extends StatelessWidget {
  final CategoryMeta category;
  final double accuracy;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.accuracy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(category.icon, color: category.color, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                category.title,
                style: AppText.headline(15, weight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '${category.questionCount} Qs',
                style: AppText.body(12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(accuracy * 100).round()}%',
                  style: AppText.body(12, weight: FontWeight.bold, color: category.color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}