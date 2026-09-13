import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lumen_studio/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('shows the Lumen auth screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const LumenApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.textContaining('LUMEN'), findsWidgets);
    expect(find.text('Sign in'), findsWidgets);
  });
}
