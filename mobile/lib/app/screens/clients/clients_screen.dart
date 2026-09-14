import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/client.dart';
import '../../models/studio_event.dart';
import '../../providers/events_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_app_bar.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_card.dart';
import '../../widgets/studio_text_field.dart';
import 'client_details_screen.dart';

enum ClientFilter {
  all,
  upcoming,
  active,
  past,
  paymentDue;

  String get label {
    switch (this) {
      case ClientFilter.all:
        return 'All';
      case ClientFilter.upcoming:
        return 'Upcoming';
      case ClientFilter.active:
        return 'Active';
      case ClientFilter.past:
        return 'Past';
      case ClientFilter.paymentDue:
        return 'Payment Due';
    }
  }
}

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  ClientFilter _activeFilter = ClientFilter.all;

  static final _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EventsProvider>();
    final allClients = provider.clients;

    final query = _searchController.text.trim().toLowerCase();

    // Filter clients based on search query and filter chip
    final filteredClients = allClients.where((client) {
      final clientEvents =
          provider.getEventsForClient(client.id, clientName: client.name);

      // Search matching: name, phone, email, and event names
      final matchesSearch = query.isEmpty ||
          client.name.toLowerCase().contains(query) ||
          client.phone.toLowerCase().contains(query) ||
          client.email.toLowerCase().contains(query) ||
          clientEvents.any((e) =>
              e.title.toLowerCase().contains(query) ||
              e.eventType.toLowerCase().contains(query));

      if (!matchesSearch) return false;

      // Filter chip matching
      switch (_activeFilter) {
        case ClientFilter.all:
          return true;
        case ClientFilter.upcoming:
          return clientEvents.any((e) =>
              e.status == EventStatus.upcoming &&
              !e.startsAt.isBefore(DateTime.now().subtract(const Duration(days: 1))));
        case ClientFilter.active:
          return clientEvents.any((e) => e.status == EventStatus.inProgress);
        case ClientFilter.past:
          return clientEvents.isNotEmpty &&
              clientEvents.every((e) =>
                  e.status == EventStatus.completed ||
                  e.startsAt.isBefore(DateTime.now().subtract(const Duration(days: 1))));
        case ClientFilter.paymentDue:
          return clientEvents.any((e) =>
              e.remainingAmount > 0 || e.status == EventStatus.paymentDue);
      }
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          StudioAppBar(
            title: 'Clients',
            subtitle: '${allClients.length} registered profiles',
            actions: [
              IconButton(
                tooltip: 'Add Client',
                icon: const Icon(Icons.person_add_alt_1_rounded,
                    color: AppColors.aqua, size: 22),
                onPressed: () => _showAddClientSheet(context),
              ),
            ],
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.navy.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.slate.withValues(alpha: 0.35),
                ),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppColors.paper, fontSize: 14),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search by client, phone, email, or event...',
                  hintStyle: TextStyle(
                    color: AppColors.muted.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.aqua, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear,
                              color: AppColors.muted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ClientFilter.values.map((filter) {
                final isSelected = _activeFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8, bottom: 8),
                  child: FilterChip(
                    label: Text(filter.label),
                    selected: isSelected,
                    selectedColor: AppColors.aqua,
                    backgroundColor: AppColors.navy.withValues(alpha: 0.6),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.ink : AppColors.paper,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.aqua
                          : AppColors.slate.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _activeFilter = filter);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Client List
          Expanded(
            child: filteredClients.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.person_search_rounded,
                              size: 48,
                              color: AppColors.muted.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text(
                            'No clients found',
                            style: GoogleFonts.playfairDisplay(
                              color: AppColors.paper,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try modifying your search or filters.',
                            style: TextStyle(
                                color: AppColors.muted, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: filteredClients.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final client = filteredClients[index];
                      final events = provider.getEventsForClient(client.id,
                          clientName: client.name);
                      final totalValue = provider.getClientTotalValue(client.id,
                          clientName: client.name);
                      final totalRemaining = provider.getClientTotalRemaining(
                          client.id,
                          clientName: client.name);
                      final hasRemaining = totalRemaining > 0;

                      return StudioCard(
                        padding: const EdgeInsets.all(16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ClientDetailsScreen(
                                      clientId: client.id),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 22,
                                      backgroundColor: AppColors.aqua
                                          .withValues(alpha: 0.16),
                                      child: Text(
                                        client.name.isNotEmpty
                                            ? client.name.characters.first
                                                .toUpperCase()
                                            : 'C',
                                        style: const TextStyle(
                                          color: AppColors.aqua,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            client.name,
                                            style: const TextStyle(
                                              color: AppColors.paper,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            client.phone.isNotEmpty
                                                ? client.phone
                                                : (client.email.isNotEmpty
                                                    ? client.email
                                                    : 'No contact details'),
                                            style: const TextStyle(
                                              color: AppColors.muted,
                                              fontSize: 12,
                                            ),
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
                                const SizedBox(height: 12),
                                const Divider(
                                    color: Color(0x18FFFFFF), height: 1),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Icon(Icons.event_note_outlined,
                                              size: 13,
                                              color: AppColors.aqua
                                                  .withValues(alpha: 0.8)),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              '${events.length} ${events.length == 1 ? 'Event' : 'Events'}'
                                              '${events.isNotEmpty ? ' · ${_currency.format(totalValue)}' : ''}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: AppColors.paper,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (hasRemaining)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8B86D)
                                              .withValues(alpha: 0.16),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: const Color(0xFFE8B86D)
                                                .withValues(alpha: 0.4),
                                          ),
                                        ),
                                        child: Text(
                                          '${_currency.format(totalRemaining)} Due',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Color(0xFFE8B86D),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.aqua
                                              .withValues(alpha: 0.14),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'All Paid',
                                          style: TextStyle(
                                            color: AppColors.aqua,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddClientSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final notesController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.navy,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Client Profile',
                      style: GoogleFonts.playfairDisplay(
                        color: AppColors.paper,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.muted),
                      onPressed: () => Navigator.of(sheetContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StudioTextField(
                  label: 'Full Name *',
                  hint: 'e.g. Aanya Sharma',
                  controller: nameController,
                ),
                const SizedBox(height: 14),
                StudioTextField(
                  label: 'Phone Number',
                  hint: 'e.g. +91 98765 43210',
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),
                StudioTextField(
                  label: 'Email Address',
                  hint: 'e.g. aanya@example.com',
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                StudioTextField(
                  label: 'Address / Location',
                  hint: 'e.g. Flat 402, Lotus Residency',
                  controller: addressController,
                ),
                const SizedBox(height: 14),
                StudioTextField(
                  label: 'Notes & Preferences',
                  hint: 'Special lighting, themes, delivery requests...',
                  controller: notesController,
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                StudioButton(
                  label: 'Create Client',
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      final newClient = Client(
                        id: 'cli-${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        email: emailController.text.trim(),
                        address: addressController.text.trim(),
                        notes: notesController.text.trim(),
                        createdAt: DateTime.now(),
                      );

                      context.read<EventsProvider>().addClient(newClient);
                      Navigator.of(sheetContext).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Client "${newClient.name}" created.'),
                          backgroundColor: AppColors.navy,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
