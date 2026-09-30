import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_text_field.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  final bool isLoading;
  final Future<void> Function({
    required String username,
    required String email,
    required String password,
    String? phone,
  })
  onSubmit;

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  Timer? _debounceTimer;
  bool _isCheckingUsername = false;
  bool? _isUsernameAvailable;

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameController.removeListener(_onUsernameChanged);
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    final text = _usernameController.text.trim();
    _debounceTimer?.cancel();

    if (text.length < 3) {
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = null;
        });
      }
      return;
    }

    setState(() {
      _isCheckingUsername = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 450), () async {
      final auth = context.read<AuthProvider>();
      final available = await auth.checkUsername(text);
      if (mounted && _usernameController.text.trim() == text) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = available;
        });
      }
    });
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      return;
    }

    if (_isUsernameAvailable == false) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a different username.')),
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match.')),
      );
      return;
    }

    await widget.onSubmit(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phone: null,
    );
  }

  Widget? _buildUsernameSuffix() {
    if (_isCheckingUsername) {
      return const Padding(
        padding: EdgeInsets.all(14),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF38BDF8)),
          ),
        ),
      );
    }
    if (_isUsernameAvailable == true) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 20,
        ),
      );
    }
    if (_isUsernameAvailable == false) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Icon(
          Icons.cancel_rounded,
          color: Color(0xFFEF4444),
          size: 20,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StudioTextField(
              label: 'Username',
              hint: 'Choose a unique username',
              controller: _usernameController,
              prefixIcon: Icons.person_outline_rounded,
              suffixIcon: _buildUsernameSuffix(),
              autofillHints: const [AutofillHints.username],
              validator: (val) {
                final base = Validators.username(val);
                if (base != null) return base;
                if (_isUsernameAvailable == false) {
                  return 'Username is already taken';
                }
                return null;
              },
            ),
            if (_isUsernameAvailable == true) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const SizedBox(width: 6),
                  const Icon(Icons.check_circle_outline,
                      size: 13, color: Color(0xFF10B981)),
                  const SizedBox(width: 5),
                  Text(
                    'Username is available!',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF34D399),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            StudioTextField(
              label: 'Email address',
              hint: 'name@example.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.mail_outline_rounded,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
            ),
            const SizedBox(height: 16),
            StudioTextField(
              label: 'Create password',
              hint: 'At least 8 characters',
              controller: _passwordController,
              obscureText: true,
              prefixIcon: Icons.lock_outline_rounded,
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) => Validators.password(value, isNew: true),
            ),
            const SizedBox(height: 16),
            StudioTextField(
              label: 'Confirm password',
              hint: 'Re-enter your password',
              controller: _confirmController,
              obscureText: true,
              prefixIcon: Icons.lock_outline_rounded,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              validator: (value) =>
                  Validators.confirmPassword(value, _passwordController.text),
              onFieldSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),
            StudioButton(
              label: 'Verify Email & Create Account',
              showArrow: true,
              isLoading: widget.isLoading,
              onPressed: widget.isLoading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}
