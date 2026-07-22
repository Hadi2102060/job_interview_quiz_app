import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:job_interview_quiz_app/features/auth/presentation/pages/otp_screen.dart';
import 'package:job_interview_quiz_app/screens/homescreen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme.dart';
import '../../../../core/utils/phone_validator.dart';
import '../../../../routes/appRoutes.dart';
import '../../../../widgets/gradient_button.dart';
import '../cubit/auth_cubit.dart';

/// First screen after onboarding. The user picks a Bangladeshi mobile
/// number that BDApps will subscribe.
/// 
const String _baseUrl = "https://bdapps.flicksize.com/QuizForge/api/";
bool _isSupportedRobiAirtelNumber(String phone) {
  return RegExp(r'^01(?:6|8)\d{8}$').hasMatch(phone);
}
class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<bool> _checkAlreadySubscribed(String phone) async {
    try {
      final response = await http
          .post(
            Uri.parse('${_baseUrl}check_subscription.php'),
            body: {'user_mobile': phone},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        return false;
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      final status =
          decoded['subscriptionStatus']?.toString().trim().toUpperCase() ?? '';
      final isSubscribed = status == 'REGISTERED';

      return isSubscribed;
    } catch (e) {
      return false;
    }
  }

  Future<void> _onContinue() async {
     final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      _showError('মোবাইল নম্বর দাও');
      return;
    }
    if (!_isSupportedRobiAirtelNumber(phone)) {
      _showError('সঠিক Robi/Airtel নম্বর দাও');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Check if already subscribed
      final isSubscribed = await _checkAlreadySubscribed(phone);

      if (isSubscribed) {
        _showSuccess('স্বাগতম! লগইন হচ্ছে...');
        await Future.delayed(const Duration(milliseconds: 800));

        try {
          await _saveAndGoHome(phone);
        } catch (e) {
          if (mounted) {
            _showError('লগইন করতে সমস্যা হয়েছে। আবার চেষ্টা করুন।');
            setState(() => _isLoading = false);
          }
        }
        return;
      }

      // Send OTP request
      final otpResponse = await http
          .post(
            Uri.parse('${_baseUrl}send_otp.php'),
            body: {'user_mobile': phone},
          )
          .timeout(const Duration(seconds: 15));

      final otpData = jsonDecode(otpResponse.body);
      if (otpData is! Map<String, dynamic>) {
        _showError('সার্ভার থেকে ভুল তথ্য এসেছে');
        return;
      }

      final success = otpData['success'] == true;
      final referenceNo = otpData['referenceNo']?.toString().trim() ?? '';
      final message = otpData['message']?.toString() ?? '';
      final statusDetail = otpData['statusDetail']?.toString() ?? '';
      final statusCode = otpData['statusCode']?.toString().trim() ?? '';

      if (success && referenceNo.isNotEmpty) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                OtpScreen(phone: phone, referenceNo: referenceNo),
          ),
        );
      } else if (statusCode == 'E1351' ||
          message.toLowerCase().contains('already registered')) {
        // User is already registered but check_subscription returned false
        // This can happen due to BDApps server inconsistency
        _showSuccess('ইতিমধ্যে রেজিস্টার করা! লগইন হচ্ছে...');
        await Future.delayed(const Duration(milliseconds: 800));

        try {
          await _saveAndGoHome(phone);
        } catch (e) {
          if (mounted) {
            _showError(
              'লগইন করতে সমস্যা হয়েছে। কিছুক্ষণ পর আবার চেষ্টা করুন।',
            );
            setState(() => _isLoading = false);
          }
        }
      } else {
        final errorMsg = message.isNotEmpty
            ? message
            : (statusDetail.isNotEmpty ? statusDetail : 'OTP পাঠানো যায়নি');
        _showError(errorMsg);
      }
    } catch (e) {
      _showError('নেটওয়ার্ক সমস্যা হয়েছে: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  Future<void> _saveAndGoHome(String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userPhone', phone);
    if (!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder:  (_) => const HomeScreen()));
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                Center(
                    child: Lottie.asset(
                          'assets/LoginLeady.json',
                          width: 200,
                          height: 200,
                          repeat: true,
                        ),
                      ),
              const Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(height: 20),
              Text(
                'স্বাগতম',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text('Robi/Airtel নম্বর দিন', textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'মোবাইল নম্বর',
                  hintText: '018********',
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : FilledButton(
                      onPressed: _onContinue,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0B6B3A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ভেরিফিকেশন কোড পাঠান',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
        
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'এই অ্যাপটি রবি/এয়ারটেল ব্যবহারকারীদের জন্য দৈনিক ৪ টাকা (ভ্যাট + এসডি + এসসি সহ) চার্জ করে।',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ),
        
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

