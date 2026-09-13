import 'package:flutter/material.dart';

import '../screens/auth/auth_screen.dart';
import '../screens/home/home_screen.dart';

class AppRoutes {
  const AppRoutes._();

  static const String auth = '/';
  static const String home = '/home';
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.auth:
        return _fade(const AuthScreen(), settings);
      case AppRoutes.home:
        return _fade(const HomeScreen(), settings);
      default:
        return _fade(const AuthScreen(), settings);
    }
  }

  static PageRouteBuilder<void> _fade(Widget page, RouteSettings settings) {
    return PageRouteBuilder<void>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
    );
  }
}
