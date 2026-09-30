import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class StudioTextField extends StatefulWidget {
  const StudioTextField({
    super.key,
    required this.label,
    this.hint = '',
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.autofillHints,
    this.inputFormatters,
    this.onFieldSubmitted,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final int? maxLines;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<StudioTextField> createState() => _StudioTextFieldState();
}

class _StudioTextFieldState extends State<StudioTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final isMultiline = !widget.obscureText && (widget.maxLines ?? 1) != 1;
    final keyboardType =
        isMultiline ? TextInputType.multiline : widget.keyboardType;
    final textInputAction =
        isMultiline ? TextInputAction.newline : widget.textInputAction;

    final textMain = context.textMain;
    final textSecondary = context.textSecondary;
    final textMuted = context.textMuted;
    final inputBg = context.inputBg;
    final inputBorder = context.inputBorder;
    final inputFocusBorder = context.inputFocusBorder;

    return LayoutBuilder(
      builder: (context, constraints) {
        Widget? suffix;
        if (widget.obscureText) {
          suffix = IconButton(
            tooltip: _obscured ? 'Show password' : 'Hide password',
            splashRadius: 18,
            onPressed: () => setState(() => _obscured = !_obscured),
            icon: Icon(
              _obscured
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: textSecondary,
              size: 20,
            ),
          );
        } else if (widget.suffixIcon != null) {
          suffix = widget.suffixIcon;
        }

        final field = TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textAlignVertical:
              isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
          validator: widget.validator,
          autofillHints: widget.autofillHints,
          inputFormatters: widget.inputFormatters,
          onFieldSubmitted: widget.onFieldSubmitted,
          style: GoogleFonts.plusJakartaSans(
            color: textMain,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: inputFocusBorder,
          decoration: InputDecoration(
            hintText: widget.hint.isNotEmpty ? widget.hint : null,
            hintStyle: GoogleFonts.plusJakartaSans(
              color: textMuted,
              fontSize: 14.5,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: inputBg,
            isDense: true,
            errorMaxLines: 3,
            errorStyle: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFEF4444),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: EdgeInsets.fromLTRB(
              widget.prefixIcon == null ? 16 : 4,
              16,
              suffix == null ? 16 : 4,
              16,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(
                    widget.prefixIcon,
                    color: textSecondary,
                    size: 21,
                  ),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: inputBorder,
                width: 1.1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: inputBorder,
                width: 1.1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: inputFocusBorder,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 1.5,
              ),
            ),
          ),
        );

        Widget content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.plusJakartaSans(
                color: textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(height: 8),
            field,
          ],
        );

        if (constraints.maxWidth.isFinite) {
          content = SizedBox(width: constraints.maxWidth, child: content);
        }

        return content;
      },
    );
  }
}
