import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../core/services/local_storage_service.dart';
import '../../core/theme.dart';
import '../../routes/appRoutes.dart';
import '../../state/app_state.dart';
import '../../widgets/particle_background.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

const _items = [
  OnboardingItem(
    title: 'Practice With Real Questions',
    description:
        'Curated multi-domain question banks across Flutter, Dart, React, Node, Python, SQL, and HR rounds.',
    icon: Icons.quiz_rounded,
    color: Color(0xFF6C63FF),
  ),
  OnboardingItem(
    title: 'Track Your Growth',
    description:
        'Detailed analytics show your accuracy, streaks, and topic mastery — keep improving every day.',
    icon: Icons.insights_rounded,
    color: Color(0xFFFF9F43),
  ),
  OnboardingItem(
    title: 'Earn Achievements',
    description:
        'Unlock badges, climb the leaderboard, and prepare confidently for your dream interview.',
    icon: Icons.emoji_events_rounded,
    color: Color(0xFF26C6DA),
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _index = 0;

  void _next() {
    if (_index < _items.length - 1) {
      _pageController.nextPage(duration: AppDuration.medium, curve: Curves.easeInOut);
    } else {
      _finish();
    }
  }

  void _finish() {
    // 1) Mirror flag into AppState for in-memory consumers.
    final state = context.read<AppState>();
    state.completeOnboarding();
    // 2) Persist via the auth-local storage so the splash bootstrap
    //    correctly skips the onboarding route next launch.
    Get.find<LocalStorageService>().setOnboardingCompleted(true);
    // 3) Route to the phone OTP entry — this is the first real auth step.
    Get.offAllNamed(AppRoutes.phoneRoute);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.splash),
            child: const ParticleBackground(color: Colors.white24),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: AppText.body(14, weight: FontWeight.w600, color: Colors.white70),
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _index = i),
                    itemCount: _items.length,
                    itemBuilder: (context, i) => _OnboardingPage(item: _items[i]),
                  ),
                ),
                _Dots(count: _items.length, index: _index),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                      ),
                      onPressed: _next,
                      child: Text(
                        _index == _items.length - 1 ? 'Get Started' : 'Next',
                        style: AppText.headline(16, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  const _OnboardingPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 90),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: AppText.headline(24, weight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: AppText.body(15, color: Colors.white70).copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;
  const _Dots({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final selected = i == index;
        return AnimatedContainer(
          duration: AppDuration.fast,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: selected ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}