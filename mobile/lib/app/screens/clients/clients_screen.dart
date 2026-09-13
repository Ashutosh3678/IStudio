import 'package:flutter/material.dart';

import '../../data/studio_demo_data.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_card.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clients = StudioDemoData.clients;

    return SafeArea(
      child: Column(
        children: [
          const StudioAppBar(
            title: 'Clients',
            subtitle: 'People you shoot with',
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: clients.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final client = clients[index];
                return StudioCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.aqua.withValues(alpha: 0.16),
                        child: Text(
                          client.$1.characters.first,
                          style: const TextStyle(
                            color: AppColors.aqua,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.$1,
                              style: const TextStyle(
                                color: AppColors.paper,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              client.$2,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.muted,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
