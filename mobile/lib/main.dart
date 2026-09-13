import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/providers/auth_provider.dart';
import 'app/screens/auth/auth_screen.dart';
import 'app/screens/shell/app_shell.dart';
import 'app/theme/app_colors.dart';
import 'app/theme/app_theme.dart';
import 'app/widgets/studio_splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.ink,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const LumenApp());
}

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..bootstrap(),
      child: MaterialApp(
        title: 'Lumen Studio',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.isBootstrapping) {
      return const StudioSplash();
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      child: auth.isLoggedIn
          ? const AppShell(key: ValueKey('home'))
          : const AuthScreen(key: ValueKey('auth')),
    );
  }
}
