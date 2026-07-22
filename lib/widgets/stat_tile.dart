import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Small icon + value + label cell used in the home stats card and profile.
class StatTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color valueColor;
  final double iconSize;

  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor = Colors.white70,
    this.valueColor = Colors.white,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            const SizedBox(width: 6),
            Text(
              value,
              style: AppText.headline(20, weight: FontWeight.bold, color: valueColor),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppText.body(12, color: iconColor),
        ),
      ],
    );
  }
}