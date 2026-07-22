import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../widgets/bottom_nav_shell.dart';
import 'homescreen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'stats_screen.dart';
import 'learn_tab.dart';

/// Root scaffold with 5 persistent tabs:
/// Home / Learn / Stats / Leaderboard / Profile.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    LearnTab(),
    StatsScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: PremiumBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}