import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:job_interview_quiz_app/core/services/local_storage_service.dart';
import 'package:job_interview_quiz_app/core/theme.dart';
import 'package:job_interview_quiz_app/features/auth/data/datasources/bdapps_api_client.dart';
import 'package:job_interview_quiz_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:job_interview_quiz_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:job_interview_quiz_app/features/auth/domain/usecases/auth_usecases.dart';
import 'package:job_interview_quiz_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:job_interview_quiz_app/firebase_options.dart';
import 'package:job_interview_quiz_app/routes/appRoutes.dart';
import 'package:job_interview_quiz_app/services/auth_service.dart';
import 'package:job_interview_quiz_app/state/app_state.dart';
import 'package:provider/provider.dart';

/// Registers GetX singletons used by splash, auth, and profile flows.
Future<void> _initDependencies() async {
  final storage = await LocalStorageService.create();
  Get.put<LocalStorageService>(storage, permanent: true);

  Get.put<BootstrapDecision>(
    BootstrapDecision(storage),
    permanent: true,
  );

  final apiClient = BdappsApiClient();
  Get.put<BdappsApiClient>(apiClient, permanent: true);

  final authRepository = AuthRepositoryImpl(
    apiClient: apiClient,
    storage: storage,
  );
  Get.put<AuthRepository>(authRepository, permanent: true);

  final checkSubscription = CheckSubscriptionUseCase(authRepository);
  final sendOtp = SendOtpUseCase(authRepository);
  final verifyOtp = VerifyOtpUseCase(authRepository);
  final logout = LogoutUseCase(authRepository);

  Get.put<CheckSubscriptionUseCase>(checkSubscription, permanent: true);
  Get.put<SendOtpUseCase>(sendOtp, permanent: true);
  Get.put<VerifyOtpUseCase>(verifyOtp, permanent: true);
  Get.put<LogoutUseCase>(logout, permanent: true);

  Get.put<AuthCubitFactory>(
    AuthCubitFactory(
      () => AuthCubit(
        checkSubscription: checkSubscription,
        sendOtp: sendOtp,
        verifyOtp: verifyOtp,
        logout: logout,
      ),
    ),
    permanent: true,
  );

  // Legacy email/password screens — lazy so splash bootstrap is not interrupted.
  Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  await _initDependencies();

  final appState = AppState();
  await appState.load();

  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  final AppState appState;
  const MyApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>.value(value: appState),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SkillCheck ',
        theme: buildAppTheme(),
        initialRoute: AppRoutes.splashRoute,
        getPages: AppRoutes.routes,
        defaultTransition: Transition.fadeIn,
      ),
    );
  }
}