import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/studio_button.dart';

/// Interactive App Features Showcase & Onboarding Tour.
///
/// Highlights the 8 core official features of Clients Hub:
/// 1. Studio Dashboard
/// 2. Event & Calendar Management
/// 3. Client Management
/// 4. Payments, Invoices & Receipts
/// 5. Expense & Earnings Tracking
/// 6. Work Progress & Deliverables
/// 7. Nearby Photographer Discovery
/// 8. Studio Profile & Customization
class AppFeaturesShowcaseScreen extends StatefulWidget {
  const AppFeaturesShowcaseScreen({
    super.key,
    this.isStandalone = false,
    this.onComplete,
  });

  /// True if pushed as a route (e.g. from AuthScreen or ProfileScreen)
  /// rather than rendered as the root auth gate.
  final bool isStandalone;
  final VoidCallback? onComplete;

  static Route<void> route({bool isStandalone = true, VoidCallback? onComplete}) {
    return MaterialPageRoute<void>(
      builder: (_) => AppFeaturesShowcaseScreen(
        isStandalone: isStandalone,
        onComplete: onComplete,
      ),
    );
  }

  @override
  State<AppFeaturesShowcaseScreen> createState() => _AppFeaturesShowcaseScreenState();
}

class _AppFeaturesShowcaseScreenState extends State<AppFeaturesShowcaseScreen> {
  late final PageController _pageController;
  int _currentPage = 0;

  static const List<_FeatureItem> _features = [
    _FeatureItem(
      badge: '1. STUDIO DASHBOARD',
      title: 'Studio Dashboard',
      subtitle: 'Your business at a glance.',
      accentColor: Color(0xFF818CF8), // Pastel Periwinkle
      icon: Icons.dashboard_rounded,
      benefits: [
        'View upcoming and past events at a single glance',
        'Access important studio actions and event countdowns',
        'See event information, progress, and quick statistics',
        'Navigate quickly to calendar, invoices, and clients',
      ],
      mockupType: _MockupType.dashboard,
    ),
    _FeatureItem(
      badge: '2. EVENT & CALENDAR',
      title: 'Event & Calendar Management',
      subtitle: 'Keep every shoot organized.',
      accentColor: Color(0xFF38BDF8), // Cyan / Sky
      icon: Icons.calendar_month_rounded,
      benefits: [
        'Create and edit events with dates, times, and venues',
        'Track Upcoming, In Progress, Completed, and Cancelled statuses',
        'View event details and delete events when needed',
        'Find nearby photographers for event collaboration',
      ],
      mockupType: _MockupType.events,
    ),
    _FeatureItem(
      badge: '3. CLIENT MANAGEMENT',
      title: 'Client Management',
      subtitle: 'Keep client information in one place.',
      accentColor: Color(0xFF6366F1), // Radiant Iris
      icon: Icons.people_alt_rounded,
      benefits: [
        'Store names, phone numbers, email addresses, and details',
        'Link clients directly to their scheduled events',
        'Find clients quickly using search and filters',
        'Access payment information and contact clients via Call & WhatsApp',
      ],
      mockupType: _MockupType.clients,
    ),
    _FeatureItem(
      badge: '4. PAYMENTS & INVOICES',
      title: 'Payments, Invoices & Receipts',
      subtitle: 'Track money received and payments due.',
      accentColor: Color(0xFF6EE7B7), // Fresh Pastel Mint
      icon: Icons.receipt_long_rounded,
      benefits: [
        'Record advance and subsequent payments with payment methods',
        'Track outstanding balances and attach payment proofs',
        'Create professional invoices and shareable receipts',
        'View complete payment history associated with each event',
      ],
      mockupType: _MockupType.invoices,
    ),
    _FeatureItem(
      badge: '5. EXPENSE & EARNINGS',
      title: 'Expense & Earnings Tracking',
      subtitle: 'Understand how your studio is performing.',
      accentColor: Color(0xFF10B981), // Emerald
      icon: Icons.trending_up_rounded,
      benefits: [
        'Record event-related expenses and vendor payouts',
        'Track event value and total amounts received',
        'Calculate outstanding amounts and actual net profit',
        'Review monthly event income and expenditure reports',
      ],
      mockupType: _MockupType.expenses,
    ),
    _FeatureItem(
      badge: '6. WORK & DELIVERABLES',
      title: 'Work Progress & Deliverables',
      subtitle: 'Track each shoot from capture to final delivery.',
      accentColor: Color(0xFFA855F7), // Purple
      icon: Icons.checklist_rounded,
      benefits: [
        'Organize tasks into shoot, post-production, and delivery stages',
        'Check off completed tasks in real time',
        'Track progress, deadlines, and pending work',
        'Review completed and outstanding deliverables before handover',
      ],
      mockupType: _MockupType.deliverables,
    ),
    _FeatureItem(
      badge: '7. CREW DISCOVERY',
      title: 'Nearby Photographer Discovery',
      subtitle: 'Connect with photographers for collaboration.',
      accentColor: Color(0xFFF59E0B), // Warm amber
      icon: Icons.person_search_rounded,
      benefits: [
        'Search for photographers by location and services offered',
        'Calculate distances when venue and photographer coordinates exist',
        'View photographer profiles, specialties, and contact options',
        'Call, message through WhatsApp, and share event details instantly',
      ],
      mockupType: _MockupType.photographers,
    ),
    _FeatureItem(
      badge: '8. STUDIO PROFILE',
      title: 'Studio Profile & Customization',
      subtitle: 'Personalize your business presence.',
      accentColor: Color(0xFFEC4899), // Pink / Rose
      icon: Icons.palette_rounded,
      benefits: [
        'Manage studio and owner information with precision',
        'Add studio location and photographer categories',
        'Maintain social media profiles and website links',
        'Upload studio logo and switch between Dark & Light themes',
      ],
      mockupType: _MockupType.profile,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finishTour() {
    HapticFeedback.mediumImpact();
    if (widget.isStandalone) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      } else {
        Navigator.of(context).pop();
      }
    } else {
      context.read<AuthProvider>().completeFeatureTour();
    }
  }

  void _nextPage() {
    HapticFeedback.lightImpact();
    if (_currentPage < _features.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finishTour();
    }
  }

  void _previousPage() {
    HapticFeedback.lightImpact();
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = _features.length;
    final currentItem = _features[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation & Skip Header
            _buildTopBar(context, currentItem),

            // Main Carousel Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: totalPages,
                onPageChanged: (idx) {
                  setState(() => _currentPage = idx);
                },
                itemBuilder: (context, index) {
                  return _buildPageItem(context, _features[index]);
                },
              ),
            ),

            // Bottom Navigation Dock with Indicators & Action Buttons
            _buildBottomDock(context, totalPages, currentItem),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, _FeatureItem item) {
    final textMuted = context.textMuted;
    final isDark = context.isDark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Step Counter Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? item.accentColor.withValues(alpha: 0.14)
                  : item.accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: item.accentColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 13,
                  color: item.accentColor,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_currentPage + 1} of ${_features.length}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: item.accentColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),

          // Prominent "Skip" Button
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _finishTour,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Skip Tour',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: textMuted,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageItem(BuildContext context, _FeatureItem item) {
    final isDark = context.isDark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Glowing Feature Icon Anchor
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  item.accentColor.withValues(alpha: 0.22),
                  item.accentColor.withValues(alpha: 0.06),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: item.accentColor.withValues(alpha: 0.45),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: item.accentColor.withValues(alpha: isDark ? 0.25 : 0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                item.icon,
                size: 32,
                color: item.accentColor,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Category Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: item.accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.badge,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: item.accentColor,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Main Title
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: context.textMain,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),

          // Descriptive Subtitle
          Text(
            item.subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: item.accentColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // Interactive Visual Feature Mockup
          _buildFeatureMockup(context, item),
          const SizedBox(height: 18),

          // Key Value Points
          _buildBenefitsList(context, item),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFeatureMockup(BuildContext context, _FeatureItem item) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: context.cardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.35 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle top-right ambient colored corner glow
          Positioned(
            right: -24,
            top: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: item.accentColor.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _resolveMockupWidget(context, item),
          ),
        ],
      ),
    );
  }

  Widget _resolveMockupWidget(BuildContext context, _FeatureItem item) {
    switch (item.mockupType) {
      case _MockupType.dashboard:
        return _buildDashboardMockup(context, item);
      case _MockupType.events:
        return _buildEventsMockup(context, item);
      case _MockupType.clients:
        return _buildClientsMockup(context, item);
      case _MockupType.invoices:
        return _buildInvoicesMockup(context, item);
      case _MockupType.expenses:
        return _buildExpensesMockup(context, item);
      case _MockupType.deliverables:
        return _buildDeliverablesMockup(context, item);
      case _MockupType.photographers:
        return _buildPhotographersMockup(context, item);
      case _MockupType.profile:
        return _buildProfileMockup(context, item);
    }
  }

  // 1. Studio Dashboard Mockup
  Widget _buildDashboardMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.dashboard_rounded, color: item.accentColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Studio Overview',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textMain,
                    ),
                  ),
                  Text(
                    'Upcoming & past shoots at a glance',
                    style: TextStyle(fontSize: 11.5, color: textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'ACTIVE',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDashStat('Upcoming', '4', item.accentColor),
              _buildDashStat('In Progress', '2', const Color(0xFF38BDF8)),
              _buildDashStat('Completed', '18', const Color(0xFF10B981)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildQuickNavPill(context, '📅 Calendar', Icons.calendar_today_rounded),
            const SizedBox(width: 6),
            _buildQuickNavPill(context, '📄 Invoices', Icons.receipt_rounded),
            const SizedBox(width: 6),
            _buildQuickNavPill(context, '👥 Clients', Icons.person_rounded),
          ],
        ),
      ],
    );
  }

  Widget _buildDashStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickNavPill(BuildContext context, String text, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        decoration: BoxDecoration(
          color: context.innerBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: context.cardBorder),
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.textMain,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  // 2. Event & Calendar Management Mockup
  Widget _buildEventsMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFF43F5E)),
                const SizedBox(width: 6),
                Text(
                  'Wedding: Ananya & Rahul',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: textMain,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: item.accentColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Upcoming',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on_outlined, size: 13, color: textMuted),
            const SizedBox(width: 4),
            Text(
              'Taj Palace, Grand Ballroom • 10:00 AM',
              style: TextStyle(fontSize: 12, color: textMuted),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEventStatusPill('Upcoming', true, item.accentColor),
              _buildEventStatusPill('In Progress', false, Colors.grey),
              _buildEventStatusPill('Completed', false, Colors.grey),
              _buildEventStatusPill('Cancelled', false, Colors.grey),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventStatusPill(String status, bool active, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 10,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? color : Colors.grey,
        ),
      ),
    );
  }

  // 3. Client Management Mockup
  Widget _buildClientsMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: item.accentColor.withValues(alpha: 0.18),
              child: Icon(Icons.person_outline_rounded, color: item.accentColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Priya Sharma',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textMain,
                    ),
                  ),
                  Text(
                    '+91 98765 43210 • priya@email.com',
                    style: TextStyle(fontSize: 11.5, color: textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '2 Events',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.accentColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone_outlined, size: 14, color: Color(0xFF10B981)),
                    SizedBox(width: 6),
                    Text('Direct Call',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, size: 14, color: Color(0xFF25D366)),
                    SizedBox(width: 6),
                    Text('WhatsApp',
                        style: TextStyle(
                            fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF25D366))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 4. Payments, Invoices & Receipts Mockup
  Widget _buildInvoicesMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tax Invoice #INV-2026-08',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: textMain,
                  ),
                ),
                Text(
                  'Client: Priya Sharma',
                  style: TextStyle(fontSize: 11.5, color: textMuted),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
              ),
              child: Text(
                'PARTIALLY PAID',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Bill: ₹75,000', style: TextStyle(color: textMuted, fontSize: 11)),
                  const SizedBox(height: 2),
                  const Text('Advance: ₹35,000',
                      style: TextStyle(
                          color: Color(0xFF10B981), fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Balance Due', style: TextStyle(color: textMuted, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(
                    '₹40,000',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share_rounded, size: 14, color: Color(0xFF25D366)),
                    const SizedBox(width: 6),
                    Text(
                      'Share PDF & Receipts',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF25D366),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 5. Expense & Earnings Tracking Mockup
  Widget _buildExpensesMockup(BuildContext context, _FeatureItem item) {
    final textMuted = context.textMuted;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.innerBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Event Value', style: TextStyle(fontSize: 10.5, color: textMuted)),
                    const SizedBox(height: 3),
                    Text(
                      '₹1,20,000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.innerBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Event Expenses', style: TextStyle(fontSize: 10.5, color: textMuted)),
                    const SizedBox(height: 3),
                    Text(
                      '₹35,000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Calculated Net Profit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(
                '₹85,000',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. Work Progress & Deliverables Mockup
  Widget _buildDeliverablesMockup(BuildContext context, _FeatureItem item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deliverables Pipeline',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.textMain,
              ),
            ),
            Text(
              'Stage 2 of 3 • 66%',
              style: TextStyle(fontSize: 11, color: item.accentColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildStageRow('1. Shoot Capture', 'Raw footage backed up', true),
        const SizedBox(height: 6),
        _buildStageRow('2. Post-Production', 'Color grading & reel edits', true),
        const SizedBox(height: 6),
        _buildStageRow('3. Final Delivery', 'Album print & 4K drive link', false),
      ],
    );
  }

  Widget _buildStageRow(String stage, String sub, bool isDone) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          size: 16,
          color: isDone ? const Color(0xFFA855F7) : Colors.grey,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '$stage: $sub',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
              color: isDone ? null : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  // 7. Nearby Photographer Discovery Mockup
  Widget _buildPhotographersMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nearby Verified Crew',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: textMain,
              ),
            ),
            Text('3.2 km away', style: TextStyle(fontSize: 11, color: item.accentColor)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: item.accentColor.withValues(alpha: 0.2),
              child: Icon(Icons.flight_takeoff_rounded, color: item.accentColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Karthik Films (Drone & Gimbal)',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700, fontSize: 13, color: textMain)),
                  Text('Drone Pilot • Candid Specialist',
                      style: TextStyle(fontSize: 11, color: textMuted)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Connect',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: item.accentColor,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // 8. Studio Profile & Customization Mockup
  Widget _buildProfileMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: item.accentColor.withValues(alpha: 0.18),
              child: Icon(Icons.camera_alt_outlined, color: item.accentColor, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Royal Lens Studio',
                      style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700, fontSize: 13.5, color: textMain)),
                  Text('Rahul Sharma • Mumbai, MH',
                      style: TextStyle(fontSize: 11, color: textMuted)),
                ],
              ),
            ),
            Row(
              children: [
                Icon(Icons.dark_mode_outlined, size: 14, color: item.accentColor),
                const SizedBox(width: 4),
                Text('Themes', style: TextStyle(fontSize: 10.5, color: item.accentColor)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildProfileTag('Wedding'),
            _buildProfileTag('Cinematic Video'),
            _buildProfileTag('Instagram Linked'),
            _buildProfileTag('QR Code Ready'),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEC4899).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFEC4899).withValues(alpha: 0.3)),
      ),
      child: Text(
        tag,
        style: const TextStyle(fontSize: 10, color: Color(0xFFEC4899), fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildBenefitsList(BuildContext context, _FeatureItem item) {
    return Column(
      children: item.benefits.map((benefit) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.accentColor.withValues(alpha: 0.18),
                ),
                child: Icon(
                  Icons.check_rounded,
                  size: 13,
                  color: item.accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  benefit,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: context.textMain,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomDock(BuildContext context, int totalPages, _FeatureItem currentItem) {
    final isLast = _currentPage == totalPages - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row with Back Button, Animated Dot Indicator, and Spacer
          Row(
            children: [
              // Back Button (hidden on first page)
              if (_currentPage > 0)
                IconButton(
                  onPressed: _previousPage,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: context.textMuted,
                  tooltip: 'Previous',
                )
              else
                const SizedBox(width: 48),

              // Expanding Animated Indicator Dots
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalPages, (index) {
                    final isSelected = index == _currentPage;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 360),
                          curve: Curves.easeInOutCubic,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: isSelected ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? currentItem.accentColor
                              : context.textMuted.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),

          // Primary CTA Button
          StudioButton(
            label: isLast ? 'Enter Your Studio' : 'Next Feature',
            icon: isLast ? Icons.rocket_launch_rounded : Icons.arrow_forward_rounded,
            onPressed: _nextPage,
          ),
        ],
      ),
    );
  }
}

enum _MockupType {
  dashboard,
  events,
  clients,
  invoices,
  expenses,
  deliverables,
  photographers,
  profile,
}

class _FeatureItem {
  const _FeatureItem({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.benefits,
    required this.mockupType,
  });

  final String badge;
  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final List<String> benefits;
  final _MockupType mockupType;
}
