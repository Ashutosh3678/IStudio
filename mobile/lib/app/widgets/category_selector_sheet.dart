import '../providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';
import '../utils/photographer_categories.dart';
import 'studio_button.dart';
import 'studio_text_field.dart';

class CategorySelectorSheet extends StatefulWidget {
  const CategorySelectorSheet({
    super.key,
    required this.selected,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.isEmbedded = false,
  });

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;
  final String? title;
  final String? subtitle;
  final bool isEmbedded;

  static Future<List<String>?> show(
    BuildContext context, {
    required List<String> initial,
    String? title,
    String? subtitle,
  }) {
    List<String> current = List<String>.from(initial);
    return showModalBottomSheet<List<String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: ctx.cardBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(
              color: ctx.cardBorder,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: CategorySelectorSheet(
            selected: current,
            title: title,
            subtitle: subtitle,
            onChanged: (updated) => current = updated,
          ),
        );
      },
    );
  }

  @override
  State<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends State<CategorySelectorSheet> {
  late final Set<String> _selected;
  bool _otherSelected = false;
  final TextEditingController _customCategoryController = TextEditingController();

  List<String> get _standardCategories => [
        ...PhotographerCategories.primaryRoles,
        ...PhotographerCategories.operatorRoles,
      ];

  @override
  void initState() {
    super.initState();
    _selected = Set<String>.from(widget.selected);

    // Check if initial selection contains custom items not in standard roles
    final customItems = _selected.where((c) => !_standardCategories.contains(c)).toList();
    if (customItems.isNotEmpty || _selected.contains(PhotographerCategories.otherCategory)) {
      _otherSelected = true;
      final customName = customItems.isNotEmpty
          ? (customItems.first == PhotographerCategories.otherCategory ? '' : customItems.first)
          : '';
      _customCategoryController.text = customName;
    }
  }

  @override
  void dispose() {
    _customCategoryController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final list = _computeResultList();
    widget.onChanged(list);
  }

  List<String> _computeResultList() {
    final result = <String>[];
    for (final item in _selected) {
      if (_standardCategories.contains(item)) {
        result.add(item);
      }
    }
    if (_otherSelected) {
      final custom = _customCategoryController.text.trim();
      if (custom.isNotEmpty) {
        result.add(custom);
      } else {
        result.add(PhotographerCategories.otherCategory);
      }
    }
    return result;
  }

  void _toggleStandard(String category) {
    setState(() {
      if (_selected.contains(category)) {
        _selected.remove(category);
      } else {
        _selected.add(category);
      }
    });
    _notifyChange();
  }

  void _toggleOther() {
    setState(() {
      _otherSelected = !_otherSelected;
      if (!_otherSelected) {
        _selected.removeWhere((c) => !_standardCategories.contains(c));
        _selected.remove(PhotographerCategories.otherCategory);
      } else {
        final custom = _customCategoryController.text.trim();
        _selected.add(custom.isNotEmpty ? custom : PhotographerCategories.otherCategory);
      }
    });
    _notifyChange();
  }

  void _onCustomCategoryChanged(String val) {
    setState(() {
      _selected.removeWhere((c) => !_standardCategories.contains(c));
      _selected.remove(PhotographerCategories.otherCategory);
      final trimmed = val.trim();
      if (_otherSelected) {
        _selected.add(trimmed.isNotEmpty ? trimmed : PhotographerCategories.otherCategory);
      }
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final l10n = AppLocalizations.of(context);
    final titleText = widget.title ?? l10n.photographerRolesAndCategories;
    final subtitleText = widget.subtitle ?? l10n.chooseMultipleRoles;

    final resultCount = _computeResultList().length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(widget.isEmbedded ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.isEmbedded) ...[
            Center(
              child: Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleText,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l10n.cancel,
                  icon: Icon(Icons.close_rounded, color: context.textMuted),
                  onPressed: () => Navigator.of(context).pop(_computeResultList()),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          // Selected count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: isDark ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.sky.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 16,
                  color: AppColors.sky,
                ),
                const SizedBox(width: 6),
                Text(
                  '$resultCount ${l10n.selected} (${l10n.multipleAllowed})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.sky,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Primary Roles
          _buildSectionHeader(l10n.primaryRoles, Icons.camera_alt_outlined),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PhotographerCategories.primaryRoles
                .map((role) => _buildChip(role, isSelected: _selected.contains(role), onSelected: () => _toggleStandard(role)))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Operators
          _buildSectionHeader(l10n.operators, Icons.video_camera_back_outlined),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PhotographerCategories.operatorRoles
                .map((role) => _buildChip(role, isSelected: _selected.contains(role), onSelected: () => _toggleStandard(role)))
                .toList(),
          ),
          const SizedBox(height: 20),

          // Other option section
          _buildSectionHeader(l10n.other, Icons.add_circle_outline_rounded),
          const SizedBox(height: 10),
          _buildChip(
            PhotographerCategories.otherCategory,
            isSelected: _otherSelected,
            onSelected: _toggleOther,
            customAccentColor: const Color(0xFF8B5CF6),
          ),

          // Placeholder / input field if 'Other' is selected
          if (_otherSelected) ...[
            const SizedBox(height: 14),
            StudioTextField(
              label: l10n.specifyCustomCategory,
              hint: l10n.specifyCategoryHint,
              controller: _customCategoryController,
              prefixIcon: Icons.edit_note_rounded,
              onChanged: _onCustomCategoryChanged,
            ),
          ],

          if (!widget.isEmbedded) ...[
            const SizedBox(height: 24),
            StudioButton(
              label: '${l10n.done} ($resultCount ${l10n.selected})',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.of(context).pop(_computeResultList()),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.textMuted),
        const SizedBox(width: 6),
        Text(
          context.tr(title),
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.textMuted,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildChip(
    String label, {
    required bool isSelected,
    required VoidCallback onSelected,
    Color? customAccentColor,
  }) {
    final isDark = context.isDark;
    final activeColor = customAccentColor ?? AppColors.sky;

    return FilterChip(
      selected: isSelected,
      showCheckmark: true,
      checkmarkColor: Colors.white,
      label: Text(
        context.tr(label),
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : context.textMain,
        ),
      ),
      selectedColor: activeColor,
      backgroundColor: isDark ? const Color(0xFF1E2433) : const Color(0xFFF1F5F9),
      side: BorderSide(
        color: isSelected
            ? activeColor
            : (isDark ? const Color(0xFF2E384D) : const Color(0xFFE2E8F0)),
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
