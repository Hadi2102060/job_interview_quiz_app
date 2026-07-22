import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:job_interview_quiz_app/routes/appRoutes.dart';
import 'package:lottie/lottie.dart';
import 'package:job_interview_quiz_app/services/auth_service.dart';
import 'package:job_interview_quiz_app/widgets/gradient_button.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = Get.find<AuthService>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Timer _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();

    // Start timer for resend button
    _startTimer();

    // Check verification status periodically
    _checkVerificationStatus();
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _checkVerificationStatus() async {
    // Check every 3 seconds
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      bool isVerified = await _authService.checkEmailVerification();
      if (isVerified) {
        timer.cancel();
        Get.offAllNamed(AppRoutes.verificationSuccess);
      }
    });
  }

  Future<void> _resendVerificationEmail() async {
    if (_canResend) {
      await _authService.resendVerificationEmail();
      setState(() {
        _secondsRemaining = 60;
        _canResend = false;
      });
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade700,
              Colors.deepPurple.shade400,
              Colors.purple.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animation
                    Lottie.asset(
                      'assets/LoginLeady.json',
                      width: 200,
                      height: 200,
                      repeat: true,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Verify Your Email',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),

                    const SizedBox(height: 12),

                    Text(
                      'We have sent a verification link to your email address.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _authService.getCurrentUser()?.email ?? '',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 350.ms),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 28,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please check your email and click on the verification link to activate your account.',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms),

                    const SizedBox(height: 30),

                    // Resend Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _canResend
                              ? _resendVerificationEmail
                              : null,
                          child: Text(
                            _canResend
                                ? 'Resend Email'
                                : 'Resend in ${_secondsRemaining}s',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _canResend
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.5),
                              decoration: _canResend
                                  ? TextDecoration.underline
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 500.ms),

                    const SizedBox(height: 16),

                    // Check Status Button
                    Obx(
                      () => GradientButton(
                        onPressed: _authService.isLoading.value
                            ? null
                            : () async {
                                HapticFeedback.mediumImpact();
                                bool isVerified = await _authService
                                    .checkEmailVerification();
                                if (isVerified) {
                                  Get.offAllNamed(
                                    AppRoutes.verificationSuccess,
                                  );
                                } else {
                                  Get.snackbar(
                                    'Not Verified',
                                    'Please verify your email first',
                                    backgroundColor: Colors.orange,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                        text: 'I\'ve Verified My Email',
                        isLoading: _authService.isLoading.value,
                        gradient: LinearGradient(
                          colors: [Colors.white, Colors.white.withValues(alpha: 0.8)],
                        ),
                        textColor: Colors.deepPurple.shade700,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 600.ms),

                    const SizedBox(height: 16),

                    // Logout Button
                    TextButton.icon(
                      onPressed: () {
                        _authService.signOut();
                      },
                      icon: Icon(
                        Icons.logout,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 20,
                      ),
                      label: Text(
                        'Sign Out',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 700.ms),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
