// Basic smoke test for the CareerCraft Pro splash screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:job_interview_quiz_app/screens/splash_screen.dart';
import 'package:job_interview_quiz_app/state/app_state.dart';

void main() {
  testWidgets('Splash screen shows CareerCraft Pro', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>(
        create: (_) => AppState(),
        child: const MaterialApp(home: SplashScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('CareerCraft Pro'), findsOneWidget);
  });
}
