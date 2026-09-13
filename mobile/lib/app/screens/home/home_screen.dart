import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/studio_demo_data.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_card.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final upcoming = StudioDemoData.sessions.take(3).toList();

    return SafeArea(
      child: Column(
        children: [
          StudioAppBar(
            title: user?.displayStudioName ?? 'Lumen',
            subtitle: 'Studio desk',
            actions: [
              Semantics(
                button: true,
                label: 'Open profile',
                child: IconButton(
                  tooltip: 'Profile',
                  onPressed: () {
                    Navigator.of(context).push(
                      PageRouteBuilder<void>(
                        transitionDuration: const Duration(milliseconds: 280),
                        pageBuilder: (_, _, _) => const ProfileScreen(),
                        transitionsBuilder: (_, animation, _, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  icon: ProfileAvatar(logoUrl: user?.logoUrl, size: 40),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                Text(
                  'Welcome back, ${user?.displayOwner ?? 'there'}',
                  style: GoogleFonts.playfairDisplay(
                    color: AppColors.paper,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Sessions, invoices, and clients sit together on one desk.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Sessions',
                        value: '4',
                        hint: 'This month',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Due',
                        value: '1',
                        hint: 'Open invoice',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _StatTile(
                        label: 'Clients',
                        value: '4',
                        hint: 'Active',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Text(
                  'Upcoming shoots',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.paper,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ...upcoming.map(
                  (session) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: StudioCard(
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppColors.aqua.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              color: AppColors.aqua,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.title,
                                  style: const TextStyle(
                                    color: AppColors.paper,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${session.clientName} · ${session.location}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            DateFormat('d MMM').format(session.startsAt),
                            style: const TextStyle(
                              color: AppColors.aqua,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.hint,
  });

  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return StudioCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              color: AppColors.aqua,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.paper)),
          Text(
            hint,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
