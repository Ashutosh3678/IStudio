import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'auth_background.dart';
import 'studio_logo.dart';

class StudioSplash extends StatelessWidget {
  const StudioSplash({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const StudioLogo(),
              const SizedBox(height: 28),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(context.accentColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
