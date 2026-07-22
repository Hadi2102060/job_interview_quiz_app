import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Reusable gradient header used at the top of Home, Stats, Leaderboard,
/// Profile. Pure StatelessWidget so callers can wrap it with PreferredSize.
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final List<Widget>? actions;

  const GradientAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(120);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.header,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: MediaQuery.of(context).padding.top + AppSpacing.md,
        bottom: AppSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppText.headline(20, weight: FontWeight.bold, color: Colors.white),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: AppText.body(13, color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
              ...?actions,
            ],
          ),
        ],
      ),
    );
  }
}