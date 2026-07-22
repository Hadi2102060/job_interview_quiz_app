// We use `BlocProvider` and `context.read` from flutter_bloc, but its
// `Transition` class (event-based) collides with `get`'s route transition
// helpers. Hide the colliding symbol so the route names below resolve
// to GetX's `Transition` correctly.
import 'package:flutter_bloc/flutter_bloc.dart' hide Transition;
import 'package:get/get.dart';

import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/pages/otp_screen.dart';
import '../features/auth/presentation/pages/phone_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/auth/verification_success_screen.dart';
import '../screens/homescreen.dart';
import '../screens/interview_tips_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/quiz_screen.dart';
import '../screens/root_shell.dart';
import '../screens/saved_quizzes_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/success_Screen.dart';

class AppRoutes {
  static const String splashRoute = '/splash';
  static const String onboardingRoute = '/onboarding';
  static const String rootRoute = '/root';
  static const String authRoute = '/auth';
  static const String phoneRoute = '/phone';
  static const String otpRoute = '/otp';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String emailVerification = '/email-verification';
  static const String verificationSuccess = '/verification-success';
  static const String homeRoute = '/home';
  static const String savedQuizzesRoute = '/saved-quizzes';
  static const String interviewTipsRoute = '/interview-tips';
  static const String settingsRoute = '/settings';
  static const String quizScreen = '/quiz-screen';
  static const String resultScreen = '/result-screen';

  static List<GetPage> routes = [
    GetPage(name: splashRoute, page: () => const SplashScreen()),
    GetPage(name: onboardingRoute, page: () => const OnboardingScreen()),
    GetPage(
      name: phoneRoute,
      page: () => BlocProvider<AuthCubit>(
        create: (_) => Get.find<AuthCubitFactory>().create(),
        child: const PhoneScreen(),
      ),
    ),
    GetPage(
      name: otpRoute,
      page: () {
        final args = (Get.arguments as Map<String, dynamic>?) ?? const {};
        return BlocProvider<AuthCubit>(
          create: (_) => Get.find<AuthCubitFactory>().create(),
          child: OtpScreen(
            phone: (args['phone'] as String?) ?? '',
            referenceNo: (args['referenceNo'] as String?) ?? '',
          ),
        );
      },
      transition: Transition.rightToLeft,
    ),
    GetPage(name: rootRoute, page: () => const RootShell()),

    // Legacy email/password screens — kept for backward compatibility.
    GetPage(name: loginRoute, page: () => LoginScreen()),
    GetPage(name: signupRoute, page: () => SignupScreen()),
    GetPage(
        name: forgotPasswordRoute, page: () => ForgotPasswordScreen()),
    GetPage(
        name: emailVerification, page: () => EmailVerificationScreen()),
    GetPage(
        name: verificationSuccess,
        page: () => VerificationSuccessScreen()),

    // App Routes
    GetPage(name: homeRoute, page: () => const HomeScreen()),
    GetPage(
      name: savedQuizzesRoute,
      page: () => const SavedQuizzesScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: interviewTipsRoute,
      page: () => const InterviewTipsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: settingsRoute,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(name: quizScreen, page: () => const QuizScreen()),
    GetPage(name: resultScreen, page: () => const SuccessScreen()),
  ];
}

/// Factory the auth pages use to obtain an [AuthCubit] from GetX's DI.
///
/// The application registers a single instance of this in [Get.put] inside
/// `main.dart`; each phone / OTP route then calls [create] to mint a fresh
/// cubit per route entry.
class AuthCubitFactory {
  AuthCubitFactory(this._factory);
  final AuthCubit Function() _factory;
  AuthCubit create() => _factory();
}
