import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../routes/smooth_page_route.dart';
import '../../theme/app_colors.dart';
import '../../utils/launcher_utils.dart';
import '../../widgets/studio_card.dart';
import 'legal_content.dart';

export 'legal_content.dart' show LegalDocument;

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.document});

  final LegalDocument document;

  static Future<void> open(BuildContext context, LegalDocument document) {
    return Navigator.of(
      context,
    ).push(SmoothPageRoute(builder: (_) => LegalScreen(document: document)));
  }

  @override
  Widget build(BuildContext context) {
    final title = LegalContent.title(document);
    final sections = LegalContent.sections(document);
    final textMain = context.textMain;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 6, 16, 4),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Back',
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: textMain,
                          size: 20,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            color: textMain,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    children: [
                      _Hero(document: document),
                      const SizedBox(height: 16),
                      for (var i = 0; i < sections.length; i++) ...[
                        _SectionCard(index: i + 1, section: sections[i]),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 4),
                      _ContactCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final isPrivacy = document == LegalDocument.privacy;

    return StudioCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isPrivacy ? Icons.privacy_tip_outlined : Icons.gavel_rounded,
                  color: accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LegalContent.title(document),
                      style: GoogleFonts.playfairDisplay(
                        color: context.textMain,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Last updated ${LegalContent.lastUpdated}',
                      style: TextStyle(color: context.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            LegalContent.intro(document),
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 13.5,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.index, required this.section});

  final int index;
  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    final bodyStyle = TextStyle(
      color: context.textSecondary,
      fontSize: 13.5,
      height: 1.55,
    );

    return StudioCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$index',
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  section.title,
                  style: TextStyle(
                    color: context.textMain,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (section.body != null) ...[
            const SizedBox(height: 10),
            Text(section.body!, style: bodyStyle),
          ],
          if (section.points.isNotEmpty) ...[
            const SizedBox(height: 8),
            for (final point in section.points)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 7, right: 10, left: 2),
                      decoration: BoxDecoration(
                        color: accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(child: Text(point, style: bodyStyle)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final accent = context.accentColor;
    return StudioCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      onTap: () => LauncherUtils.sendEmail(context, LegalContent.contactEmail),
      child: Row(
        children: [
          Icon(Icons.mail_outline_rounded, color: accent, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Questions? Get in touch',
                  style: TextStyle(
                    color: context.textMain,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  LegalContent.contactEmail,
                  style: TextStyle(color: accent, fontSize: 12.5),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: context.textMuted),
        ],
      ),
    );
  }
}
