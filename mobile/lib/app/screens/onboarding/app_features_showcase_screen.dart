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
        'Access important studio actions and countdowns',
        'See event information, progress, and quick statistics',
        'Send Bills with QR and navigate quickly to calendar & clients',
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
        'Monthly calendar view of all bookings so you never miss a shoot',
        'Create and edit events with dates, times, and venues',
        'Track Upcoming, In Progress, Completed, and Cancelled statuses',
        'Monitor monthly earnings, income, and profit at a glance',
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
        'Store names, phone numbers, email addresses, and shoot history',
        'Link clients directly to their scheduled events and packages',
        'Find clients quickly using instant search and status filter chips',
        'Access payment details and reach clients instantly via Call & WhatsApp',
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
        'Record advance and subsequent payments with payment modes',
        'Track pending client settlements and attach transaction proofs',
        'Create professional invoices and send shareable receipts to WhatsApp',
        'View complete payment history associated with every event',
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
        'Record event-related expenses and freelance vendor payouts',
        'Track event value and total advance amounts received',
        'Calculate outstanding amounts and net studio profit automatically',
        'Review comprehensive monthly earnings and balance sheets',
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
        'Track workflow progress percentage from capture to album printing',
        'Unlock stages automatically based on shoot execution dates',
        'Add custom work items and monitor deadlines in real time',
        'Review completed deliverables before final client handover',
      ],
      mockupType: _MockupType.deliverables,
    ),
    _FeatureItem(
      badge: '7. CREW DISCOVERY',
      title: 'Nearby Photographer Discovery',
      subtitle: 'Connect with local photographers for collaboration.',
      accentColor: Color(0xFFF59E0B), // Warm amber
      icon: Icons.person_search_rounded,
      benefits: [
        'Search for photographers by location, distance, and specialties',
        'Filter crew using 12 official photography & videography categories',
        'View verified profiles, portfolios, and contact options',
        'Call, chat on WhatsApp, and share event shoot briefs with a tap',
      ],
      mockupType: _MockupType.photographers,
    ),
    _FeatureItem(
      badge: '8. STUDIO PROFILE',
      title: 'Studio Profile & Customization',
      subtitle: 'Make your studio look professional.',
      accentColor: Color(0xFFEC4899), // Pink / Rose
      icon: Icons.storefront_rounded,
      benefits: [
        'Showcase your studio name, owner, and verified username',
        'Display contact numbers, email, city, and address details',
        'Connect Instagram, YouTube, and website portfolio links',
        'Switch between Dark and Light themes with seamless personalization',
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
                physics: const PageScrollPhysics(parent: BouncingScrollPhysics()),
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
      physics: const ClampingScrollPhysics(),
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
            padding: const EdgeInsets.all(15),
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

  // 1. Studio Dashboard Mockup (Models Home Screen Upcoming Shoot card & Send Bills with QR banner)
  Widget _buildDashboardMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "Upcoming Shoot" header row with count badge & link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  'Upcoming Shoot',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textMain,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    '2',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF38BDF8),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF38BDF8)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Upcoming Shoot Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: context.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: item.accentColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        'R',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: item.accentColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rahul & Riya',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textMain,
                          ),
                        ),
                        Text(
                          'Sai Prakash · Hyderabad',
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF818CF8).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🚨 ', style: TextStyle(fontSize: 10)),
                        Text(
                          '15h left',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF818CF8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Date Capsule
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: context.isDark ? 0.04 : 0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.cardBorder.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_month_outlined, size: 13, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '12 Oct 2026 · Monday · Grand Ballroom',
                        style: TextStyle(fontSize: 11, color: textMuted),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: 0.25,
                  minHeight: 4,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(item.accentColor),
                ),
              ),
              const SizedBox(height: 8),

              // Bottom due & view action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '₹23,000 due',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF38BDF8),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        'View Details',
                        style: TextStyle(fontSize: 11.5, color: textMuted),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right_rounded, size: 14, color: textMuted),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Send Bills with QR Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF818CF8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Bills with QR',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Fast & easy receipts to WhatsApp',
                      style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 15),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Event & Calendar Management Mockup (Models Calendar month view & booked sessions)
  Widget _buildEventsMockup(BuildContext context, _FeatureItem item) {
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
                  'Calendar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textMain,
                  ),
                ),
                Text(
                  'Booked sessions',
                  style: TextStyle(fontSize: 11, color: textMuted),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF38BDF8)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add_rounded, size: 15, color: Color(0xFF38BDF8)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Mini Month Calendar Card
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chevron_left_rounded, size: 16, color: textMuted),
                  const SizedBox(width: 8),
                  Text(
                    'October 2026',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: textMain,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right_rounded, size: 16, color: textMuted),
                ],
              ),
              const SizedBox(height: 8),

              // Weekday labels
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CalendarDayLabel('S'),
                  _CalendarDayLabel('M'),
                  _CalendarDayLabel('T'),
                  _CalendarDayLabel('W'),
                  _CalendarDayLabel('T'),
                  _CalendarDayLabel('F'),
                  _CalendarDayLabel('S'),
                ],
              ),
              const SizedBox(height: 6),

              // Dates row with shoot dates highlighted
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const _CalendarDateCell(text: '1', hasShoot: false),
                  _CalendarDateCell(text: '2', hasShoot: true, color: const Color(0xFF38BDF8)),
                  const _CalendarDateCell(text: '3', hasShoot: false),
                  const _CalendarDateCell(text: '4', hasShoot: false),
                  _CalendarDateCell(text: '5', hasShoot: true, color: const Color(0xFF38BDF8)),
                  const _CalendarDateCell(text: '6', hasShoot: false),
                  const _CalendarDateCell(text: '7', hasShoot: false),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Upcoming event',
                    style: TextStyle(fontSize: 10.5, color: textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Monthly Earnings bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_graph_rounded, size: 16, color: Color(0xFF38BDF8)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Earnings',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: textMain,
                      ),
                    ),
                    Text(
                      'Income, expenses & profit for October',
                      style: TextStyle(fontSize: 10, color: textMuted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: textMuted),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Client Management Mockup (Faithfully models Client Card & Directory)
  Widget _buildClientsMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter pills row
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: item.accentColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                'All Clients (14)',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: item.accentColor,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.innerBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.cardBorder),
              ),
              child: Text(
                'Pending Due (4)',
                style: TextStyle(fontSize: 10.5, color: textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Authentic Client Card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                    child: Text(
                      'P',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Priya Sharma',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: textMain,
                          ),
                        ),
                        Text(
                          '+91 98765 43210 · Hyderabad',
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '₹30,000 Due',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  Icon(Icons.event_outlined, size: 13, color: textMuted),
                  const SizedBox(width: 5),
                  Text(
                    'Wedding Ceremony · 2 Events linked',
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone_rounded, size: 13, color: Color(0xFF10B981)),
                          SizedBox(width: 5),
                          Text(
                            'Call',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.35)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_rounded, size: 13, color: Color(0xFF25D366)),
                          SizedBox(width: 5),
                          Text(
                            'WhatsApp',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF25D366),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 4. Payments, Invoices & Receipts Mockup (Faithfully models Screenshot 2 Payment Details)
  Widget _buildInvoicesMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Details',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: textMain,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
              ),
              child: Text(
                'PARTIALLY PAID',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // 3 Financial metrics boxes
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: context.innerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.cardBorder),
                ),
                child: Column(
                  children: [
                    Text('Total', style: TextStyle(fontSize: 10, color: textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '₹50,000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: textMain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    Text('Received', style: TextStyle(fontSize: 10, color: textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '₹20,000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.25)),
                ),
                child: Column(
                  children: [
                    Text('Due', style: TextStyle(fontSize: 10, color: textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '₹30,000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Advance payment transaction entry
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 10),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advance Received',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: textMain,
                      ),
                    ),
                    Text(
                      '10 Oct 2026 · Online UPI Transfer',
                      style: TextStyle(fontSize: 9.5, color: textMuted),
                    ),
                  ],
                ),
              ),
              Text(
                '+₹20,000',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Share receipt button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF25D366).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.share_rounded, size: 13, color: Color(0xFF25D366)),
              const SizedBox(width: 6),
              Text(
                'Send Bill & QR to WhatsApp',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF25D366),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 5. Expense & Earnings Tracking Mockup (Faithfully models Screenshot 2 Event Expenses)
  Widget _buildExpensesMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Event Expenses & Profit',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: textMain,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '76% Margin',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Revenue vs Expenses row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.innerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Revenue', style: TextStyle(fontSize: 10, color: textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '₹50,000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: context.innerBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: context.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Expenses', style: TextStyle(fontSize: 10, color: textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      '₹12,000',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
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

        // Breakdown items
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.cardBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Drone Operator', style: TextStyle(fontSize: 11, color: textMain)),
                  Text('₹8,000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textMuted)),
                ],
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Travel & Assistant', style: TextStyle(fontSize: 11, color: textMain)),
                  Text('₹4,000', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: textMuted)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Net profit result banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.trending_up_rounded, size: 15, color: Color(0xFF10B981)),
                  SizedBox(width: 6),
                  Text('Calculated Net Profit', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                ],
              ),
              Text(
                '₹38,000',
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

  // 6. Work Progress & Deliverables Mockup (Faithfully models Screenshot 2 Work Progress)
  Widget _buildDeliverablesMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Work Progress',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: textMain,
              ),
            ),
            Text(
              '1/5 · 20% Complete',
              style: TextStyle(fontSize: 11, color: item.accentColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: 0.20,
            minHeight: 5,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation<Color>(item.accentColor),
          ),
        ),
        const SizedBox(height: 10),

        // Deliverables stages list
        _buildStageRow('Shoot Execution', 'Completed on schedule', true),
        const SizedBox(height: 5),
        _buildStageRow('Raw Footage Culling', 'In Progress · 420 raw files', false, isInProgress: true),
        const SizedBox(height: 5),
        _buildStageRow('Color Grading & Teaser', 'Locked until raw selected', false),
        const SizedBox(height: 5),
        _buildStageRow('Final Album & 4K Drive', 'Delivery date 20 Oct 2026', false),
      ],
    );
  }

  Widget _buildStageRow(String stage, String sub, bool isDone, {bool isInProgress = false}) {
    Color iconColor = Colors.grey;
    IconData iconData = Icons.lock_outline_rounded;
    if (isDone) {
      iconColor = const Color(0xFF10B981);
      iconData = Icons.check_circle_rounded;
    } else if (isInProgress) {
      iconColor = const Color(0xFFA855F7);
      iconData = Icons.play_circle_fill_rounded;
    }

    return Row(
      children: [
        Icon(iconData, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stage,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: (isDone || isInProgress) ? FontWeight.w600 : FontWeight.w400,
                  color: (isDone || isInProgress) ? null : Colors.grey,
                ),
              ),
              Text(
                sub,
                style: const TextStyle(fontSize: 9.5, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 7. Nearby Photographer Discovery Mockup (Faithfully models Screenshots 6 & 7)
  Widget _buildPhotographersMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Location search bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: context.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF06B6D4)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Search crew in Banjara Hills...',
                  style: TextStyle(fontSize: 11, color: textMuted),
                ),
              ),
              Icon(Icons.tune_rounded, size: 14, color: textMuted),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Category filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCrewCategoryChip('All Categories', isSelected: true),
              const SizedBox(width: 5),
              _buildCrewCategoryChip('Traditional Photographer'),
              const SizedBox(width: 5),
              _buildCrewCategoryChip('Candid Photographer'),
              const SizedBox(width: 5),
              _buildCrewCategoryChip('Cinematic Videographer'),
              const SizedBox(width: 5),
              _buildCrewCategoryChip('Drones'),
            ],
          ),
        ),
        const SizedBox(height: 9),

        // Photographer Result Card
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.innerBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: item.accentColor.withValues(alpha: 0.2),
                    child: Text(
                      'K',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: item.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Karthik Studios',
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: textMain,
                          ),
                        ),
                        Text(
                          '📍 3.2 km away · Banjara Hills',
                          style: TextStyle(fontSize: 10, color: textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_rounded, size: 11, color: Color(0xFF25D366)),
                        SizedBox(width: 4),
                        Text(
                          'Connect',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF25D366),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 4,
                children: [
                  _buildSubCategoryBadge('Candid Photographer'),
                  _buildSubCategoryBadge('Cinematic Videographer'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCrewCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF06B6D4).withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF06B6D4) : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? const Color(0xFF06B6D4) : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSubCategoryBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, color: Colors.grey),
      ),
    );
  }

  // 8. Studio Profile & Customization Mockup (Faithfully models Screenshot 3 Studio Profile)
  Widget _buildProfileMockup(BuildContext context, _FeatureItem item) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: item.accentColor.withValues(alpha: 0.2),
              child: Text(
                'Y',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: item.accentColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yuva Studio',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: textMain,
                    ),
                  ),
                  Text(
                    'Venkey · @bunty · Hyderabad',
                    style: TextStyle(fontSize: 11, color: textMuted),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: item.accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: item.accentColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.palette_outlined, size: 12, color: item.accentColor),
                  const SizedBox(width: 4),
                  Text(
                    'Themes',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: item.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        Text(
          'Specialized Services & Crew Categories',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: textMuted,
          ),
        ),
        const SizedBox(height: 6),

        Wrap(
          spacing: 6,
          runSpacing: 5,
          children: [
            _buildProfileTag('Traditional Photographer'),
            _buildProfileTag('Candid Photographer'),
            _buildProfileTag('Cinematic Videographer'),
            _buildProfileTag('LED Screens'),
            _buildProfileTag('Drones'),
          ],
        ),
        const SizedBox(height: 10),

        // Quick feature badges
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildProfileFeaturePill(Icons.qr_code_rounded, 'QR Billing'),
            _buildProfileFeaturePill(Icons.description_outlined, 'Custom Invoices'),
            _buildProfileFeaturePill(Icons.share_outlined, 'WhatsApp Ready'),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileFeaturePill(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFFEC4899)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 9.5, color: Colors.grey, fontWeight: FontWeight.w500),
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

class _CalendarDayLabel extends StatelessWidget {
  const _CalendarDayLabel(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: context.textMuted,
          ),
        ),
      ),
    );
  }
}

class _CalendarDateCell extends StatelessWidget {
  const _CalendarDateCell({
    required this.text,
    required this.hasShoot,
    this.color,
  });

  final String text;
  final bool hasShoot;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: hasShoot ? (color ?? const Color(0xFF38BDF8)).withValues(alpha: 0.18) : Colors.transparent,
        shape: BoxShape.circle,
        border: hasShoot ? Border.all(color: color ?? const Color(0xFF38BDF8), width: 1.2) : null,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: hasShoot ? FontWeight.w700 : FontWeight.w500,
            color: hasShoot ? (color ?? const Color(0xFF38BDF8)) : context.textMain,
          ),
        ),
      ),
    );
  }
}

