import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_logo.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              children: [
                const StudioLogo(compact: true),
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.plum.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.merlot.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Welcome, ${user?.username ?? 'guest'}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          color: AppColors.ivory,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Your studio space is ready. Galleries, bookings, and client sessions will live here next.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.blush,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        user?.phone ?? '',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.blossom,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                StudioButton(
                  label: 'Sign out',
                  onPressed: () => context.read<AuthProvider>().logout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
