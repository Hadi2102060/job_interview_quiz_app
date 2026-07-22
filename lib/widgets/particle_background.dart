import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lightweight animated particle layer used on splash/onboarding.
/// Renders ~30 floating particles with random position/opacity.
class ParticleBackground extends StatefulWidget {
  final int count;
  final Color color;
  const ParticleBackground({
    super.key,
    this.count = 30,
    this.color = Colors.white,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final math.Random _rng = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _particles = List.generate(widget.count, (_) => _Particle.random(_rng));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: _ParticlePainter(
            particles: _particles,
            progress: _controller.value,
            color: widget.color,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Particle {
  double x;
  double y;
  double radius;
  double speed;
  double opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
  });

  factory _Particle.random(math.Random rng) => _Particle(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        radius: 1 + rng.nextDouble() * 3,
        speed: 0.1 + rng.nextDouble() * 0.4,
        opacity: 0.2 + rng.nextDouble() * 0.6,
      );
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final dy = (progress * p.speed) % 1.0;
      final y = ((p.y + dy) % 1.0) * size.height;
      final x = p.x * size.width;
      paint.color = color.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(x, y), p.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}