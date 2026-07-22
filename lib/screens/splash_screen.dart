import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme.dart';
import '../features/auth/domain/usecases/auth_usecases.dart';
import '../routes/appRoutes.dart';
import '../widgets/particle_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotate;
  late final Animation<double> _fade;
  late final Animation<double> _progress;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _rotate = Tween<double>(begin: -0.08, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0)),
    );
    _progress = Tween<double>(begin: 0.0, end: 0.72).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
    _navTimer = Timer(const Duration(milliseconds: 3000), _navigate);
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    // Bootstrap decision:
    //   !onboardingCompleted → onboardingRoute
    //   onboarding done + logged in        → rootRoute
    //   onboarding done + not logged in    → phoneRoute
    final decision = Get.find<BootstrapDecision>();
    final target = await decision.resolve();

    final String next;
    switch (target) {
      case BootstrapTarget.onboarding:
        next = AppRoutes.onboardingRoute;
        break;
      case BootstrapTarget.home:
        next = AppRoutes.rootRoute;
        break;
      case BootstrapTarget.phone:
        next = AppRoutes.phoneRoute;
        break;
    }

    if (!mounted) return;
    // Use GetX so any deep links / push stacks from the splash also clear.
    Get.offAllNamed(next);
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.splash),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ParticleBackground(),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _fade,
                        child: Transform.rotate(
                          angle: _rotate.value,
                          child: Transform.scale(
                            scale: _scale.value,
                            child: _LogoMark(),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FadeTransition(
                        opacity: _fade,
                        child: Text(
                          'CareerCraft Pro',
                          style: AppText.headline(28,
                              weight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 6),
                      FadeTransition(
                        opacity: _fade,
                        child: Text(
                          'Ace Your Next Interview',
                          style: AppText.body(14, color: Colors.white70),
                        ),
                      ),
                      const SizedBox(height: 60),
                      _LoadingIndicator(progress: _progress.value),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 2),
      ),
      child: const Center(
        child: Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 60),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  final double progress;
  const _LoadingIndicator({required this.progress});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).round()}%',
            style: AppText.body(12, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}