import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../widgets/auth_background.dart';
import '../calendar/calendar_screen.dart';
import '../clients/clients_screen.dart';
import '../home/home_screen.dart';
import '../invoice/invoice_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    CalendarScreen(),
    InvoiceScreen(),
    ClientsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(index: _index, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          backgroundColor: AppColors.navy.withValues(alpha: 0.96),
          onDestinationSelected: (value) => setState(() => _index = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Invoice',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Clients',
            ),
          ],
        ),
      ),
    );
  }
}
