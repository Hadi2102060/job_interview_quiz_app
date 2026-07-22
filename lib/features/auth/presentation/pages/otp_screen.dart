import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme.dart';
import '../../../../routes/appRoutes.dart';
import '../../../../widgets/gradient_button.dart';
import '../cubit/auth_cubit.dart';

/// OTP screen — verifies the code the user received via the BDApps USSD
/// flow or on-screen message.
class OtpScreen extends StatefulWidget {
  final String phone;
  final String referenceNo;
  const OtpScreen({
    super.key,
    required this.phone,
    required this.referenceNo,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  bool _resendCooldown = false;
  Timer? _cooldownTimer;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNodes.first.requestFocus();
    });
  }

  void _startCooldown() {
    setState(() {
      _remainingSeconds = 30;
      _resendCooldown = true;
    });
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _resendCooldown = false;
          t.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otp => _controllers.map((c) => c.text).join();

  Future<void> _onVerify() async {
    if (_otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    final cubit = context.read<AuthCubit>();
    final err = await cubit.submitOtp(
      phoneNumber: widget.phone,
      referenceNo: widget.referenceNo,
      otp: _otp,
    );
    if (!mounted) return;
    if (err == null && cubit.state.session != null) {
      Get.offAllNamed(AppRoutes.homeRoute);
      return;
    }
    if (err != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ));
      for (var c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
    }
  }

  Future<void> _onResend() async {
    if (_resendCooldown) return;
    final cubit = context.read<AuthCubit>();
    final err = await cubit.requestOtp(widget.phone);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(err),
          backgroundColor: AppColors.error,
        ));
      return;
    }
    // Update referenceNo from the freshly issued request.
    final newRef = cubit.state.lastOtpRequest?.referenceNo;
    if (newRef != null && newRef.isNotEmpty) {
      // Re-create the screen with the new referenceNo via arguments swap.
      // We use Get.offNamed to swap arguments.
      Get.offNamed(
        AppRoutes.otpRoute,
        arguments: {
          'phone': widget.phone,
          'referenceNo': newRef,
        },
      );
    }
    _startCooldown();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-submit when the final box is filled.
    if (index == 5 && value.isNotEmpty && _otp.length == 6) {
      _onVerify();
    }
    context.read<AuthCubit>().clearError();
  }

  @override
  Widget build(BuildContext context) {
    final phone = widget.phone;
    final prettyPhone =
        phone.length == 11 ? phone.replaceFirstMapped(
          RegExp(r'(\d{3})(\d{4})(\d+)'),
          (m) => '${m[1]}-${m[2]}-${m[3]}',
        ) : phone;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.splash),
        child: SafeArea(
          child: BlocConsumer<AuthCubit, AuthState>(
            listenWhen: (prev, curr) =>
                prev.errorMessage != curr.errorMessage &&
                curr.errorMessage != null,
            listener: (context, state) {
              final msg = state.errorMessage;
              if (msg == null) return;
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                  content: Text(msg),
                  backgroundColor: AppColors.error,
                ));
            },
            builder: (context, state) {
              final isBusy = state.isVerifyingOtp;
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xl,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: isBusy
                            ? null
                            : () => Get.back(),
                        icon: const Icon(Icons.arrow_back,
                            color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(Icons.sms_rounded,
                            color: Colors.white, size: 40),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Verify your number',
                        style: AppText.headline(22,
                            weight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text.rich(
                        TextSpan(
                          text:
                              'Enter the 6-digit code we sent to\n',
                          style: AppText.body(14, color: Colors.white70),
                          children: [
                            TextSpan(
                              text: '+880 $prettyPhone',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(6, (i) {
                          return SizedBox(
                            width: 48,
                            child: TextFormField(
                              controller: _controllers[i],
                              focusNode: _focusNodes[i],
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 1,
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        vertical: 14),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color:
                                        Colors.white.withValues(alpha: 0.3),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                fillColor:
                                    Colors.white.withValues(alpha: 0.08),
                                filled: true,
                              ),
                              onChanged: (v) => _onChanged(v, i),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      GradientButton(
                        onPressed: isBusy ? null : _onVerify,
                        text: 'Verify',
                        isLoading: isBusy,
                        gradient: const LinearGradient(
                          colors: [Colors.white, Color(0xFFE0E0FF)],
                        ),
                        textColor: AppColors.primary,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Center(
                        child: TextButton(
                          onPressed:
                              _resendCooldown ? null : _onResend,
                          child: Text(
                            _resendCooldown
                                ? 'Resend code in ${_remainingSeconds}s'
                                : 'Resend code',
                            style: GoogleFonts.poppins(
                              color: _resendCooldown
                                  ? Colors.white38
                                  : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Center(
                        child: Text(
                          'Wrong number?',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: isBusy
                              ? null
                              : () => Get.offAllNamed(
                                    AppRoutes.phoneRoute,
                                  ),
                          child: Text(
                            'Change phone number',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
