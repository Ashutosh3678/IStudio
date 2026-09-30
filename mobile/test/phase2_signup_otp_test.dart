import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumen_studio/app/providers/auth_provider.dart';
import 'package:lumen_studio/app/screens/auth/signup_form.dart';
import 'package:lumen_studio/app/screens/auth/signup_otp_sheet.dart';
import 'package:provider/provider.dart';

void main() {
  group('Phase 2: Signup Email OTP Verification Tests', () {
    testWidgets('SignupForm renders all registration fields', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => AuthProvider(),
              child: SignupForm(
                isLoading: false,
                onSubmit: ({
                  required String username,
                  required String email,
                  required String password,
                  String? phone,
                }) async {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email address'), findsOneWidget);
      expect(find.text('Create password'), findsOneWidget);
      expect(find.text('Confirm password'), findsOneWidget);
      expect(find.text('Verify Email & Create Account'), findsOneWidget);
    });

    testWidgets('SignupOtpSheet renders email address and verification controls',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider(
              create: (_) => AuthProvider(),
              child: const SignupOtpSheet(
                username: 'alice_studio',
                email: 'alice@example.com',
                password: 'SecretPassword123',
              ),
            ),
          ),
        ),
      );

      expect(find.text('Verify Your Email'), findsOneWidget);
      expect(find.text('Code sent to alice@example.com'), findsOneWidget);
      expect(find.text('Confirm & Activate Account'), findsOneWidget);
    });
  });
}
