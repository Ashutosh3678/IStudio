import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumen_studio/app/models/user.dart';
import 'package:lumen_studio/app/providers/auth_provider.dart';
import 'package:lumen_studio/app/screens/onboarding/app_features_showcase_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('AppFeaturesShowcaseScreen Tests', () {
    testWidgets('renders all initial elements: step indicator, skip button, Studio Dashboard',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: AppFeaturesShowcaseScreen(
            isStandalone: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check step pill
      expect(find.text('1 of 8'), findsOneWidget);
      // Check skip button
      expect(find.text('Skip Tour'), findsOneWidget);
      // Check feature 1 title
      expect(find.text('Studio Dashboard'), findsOneWidget);
      expect(find.text('Your business at a glance.'), findsOneWidget);
      // Check next button
      expect(find.text('Next Feature'), findsOneWidget);
    });

    testWidgets('navigating next advances through all 8 features and finishes with Enter Your Studio',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        MaterialApp(
          home: AppFeaturesShowcaseScreen(
            isStandalone: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Slide 1: Studio Dashboard
      expect(find.text('1 of 8'), findsOneWidget);
      expect(find.text('Studio Dashboard'), findsOneWidget);

      // Slide 2: Event & Calendar Management
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();
      expect(find.text('2 of 8'), findsOneWidget);
      expect(find.text('Event & Calendar Management'), findsOneWidget);

      // Slide 3: Client Management
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();
      expect(find.text('3 of 8'), findsOneWidget);
      expect(find.text('Client Management'), findsOneWidget);

      // Slide 4: Payments, Invoices & Receipts
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();
      expect(find.text('4 of 8'), findsOneWidget);
      expect(find.text('Payments, Invoices & Receipts'), findsOneWidget);

      // Slide 5: Expense & Earnings Tracking
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();
      expect(find.text('5 of 8'), findsOneWidget);
      expect(find.text('Expense & Earnings Tracking'), findsOneWidget);

      // Slide 6: Work Progress & Deliverables
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();
      expect(find.text('6 of 8'), findsOneWidget);
      expect(find.text('Work Progress & Deliverables'), findsOneWidget);

      // Slide 7: Nearby Photographer Discovery
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();
      expect(find.text('7 of 8'), findsOneWidget);
      expect(find.text('Nearby Photographer Discovery'), findsOneWidget);

      // Slide 8: Studio Profile & Customization
      await tester.tap(find.text('Next Feature'));
      await tester.pumpAndSettle();
      expect(find.text('8 of 8'), findsOneWidget);
      expect(find.text('Studio Profile & Customization'), findsOneWidget);
      expect(find.text('Enter Your Studio'), findsOneWidget);
    });

    testWidgets('tapping Skip Tour triggers completion callback',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AppFeaturesShowcaseScreen(
            isStandalone: true,
            onComplete: () {
              completed = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Skip Tour'));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('auth provider integration: completeFeatureTour writes to SharedPreferences',
        (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final authProvider = AuthProvider();

      const testUser = User(
        id: 'usr_test_888',
        username: 'test_studio',
        phone: '9876543210',
      );
      authProvider.setUserForTesting(testUser, 'token_xyz', false);

      expect(authProvider.hasSeenFeatureTour, isFalse);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: authProvider,
          child: MaterialApp(
            home: const AppFeaturesShowcaseScreen(
              isStandalone: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Skip Tour in non-standalone mode
      await tester.tap(find.text('Skip Tour'));
      await tester.pumpAndSettle();

      expect(authProvider.hasSeenFeatureTour, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('has_seen_features_tour_usr_test_888'), isTrue);
    });
  });
}
