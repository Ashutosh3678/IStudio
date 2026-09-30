import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/pin_particle_field.dart';
import '../../widgets/studio_button.dart';

class SignupOtpSheet extends StatefulWidget {
  const SignupOtpSheet({
    super.key,
    required this.username,
    required this.email,
    required this.password,
    this.phone,
    this.initialCooldown = 60,
    this.initialDebugOtp,
  });

  final String username;
  final String email;
  final String password;
  final String? phone;
  final int initialCooldown;
  final String? initialDebugOtp;

  static Future<bool?> show(
    BuildContext context, {
    required String username,
    required String email,
    required String password,
    String? phone,
    int initialCooldown = 60,
    String? initialDebugOtp,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SignupOtpSheet(
        username: username,
        email: email,
        password: password,
        phone: phone,
        initialCooldown: initialCooldown,
        initialDebugOtp: initialDebugOtp,
      ),
    );
  }

  @override
  State<SignupOtpSheet> createState() => _SignupOtpSheetState();
}

class _SignupOtpSheetState extends State<SignupOtpSheet> {
  final GlobalKey<PinParticleFieldState> _pinFieldKey =
      GlobalKey<PinParticleFieldState>();
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  int _cooldownSeconds = 60;
  Timer? _cooldownTimer;
  bool _isLoading = false;
  String? _errorMessage;
  String? _debugOtp;

  @override
  void initState() {
    super.initState();
    _debugOtp = widget.initialDebugOtp;
    _startCooldown(widget.initialCooldown);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _otpFocusNodes[0].requestFocus();
      if (_debugOtp != null && _debugOtp!.isNotEmpty && mounted) {
        _pinFieldKey.currentState?.setDigitsWithCascade(_debugOtp!);
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _otpFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startCooldown([int seconds = 60]) {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _handleResend() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      final res = await auth.sendSignupEmailOtp(
        username: widget.username,
        email: widget.email,
      );
      final cd = (res['cooldownSeconds'] as num?)?.toInt() ?? 60;
      final debugOtp = res['debugOtp'] as String?;
      _startCooldown(cd);

      if (debugOtp != null && debugOtp.isNotEmpty) {
        setState(() => _debugOtp = debugOtp);
        _pinFieldKey.currentState?.setDigitsWithCascade(debugOtp);
      }
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (_) {
      setState(() =>
          _errorMessage = 'Unable to resend code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleVerify() async {
    FocusScope.of(context).unfocus();
    final otp = _otpControllers.map((c) => c.text.trim()).join();
    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the complete 6-digit code.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    final success = await auth.verifySignupEmailAndLogin(
      username: widget.username,
      email: widget.email,
      password: widget.password,
      otp: otp,
      phone: widget.phone,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.of(context).pop(true);
      } else {
        setState(() =>
            _errorMessage = auth.errorMessage ?? 'Unable to complete verification.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: bottomInset + 24,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.ink : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: isDark ? AppColors.glassBorderDark : AppColors.lightBorder,
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.sky.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    color: AppColors.sky, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify Your Email',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.lightTextMain,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Code sent to ${widget.email}',
                      style: TextStyle(
                        color: isDark ? AppColors.muted : AppColors.lightTextMuted,
                        fontSize: 12.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Error Banner
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.redAccent.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Debug OTP Banner (fallback when SMTP is not configured)
          if (_debugOtp != null && _debugOtp!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.sky.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.sky.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.key_rounded, color: AppColors.sky, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Verification Code: $_debugOtp',
                      style: const TextStyle(
                        color: AppColors.sky,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      _pinFieldKey.currentState?.setDigitsWithCascade(_debugOtp!);
                    },
                    child: const Text(
                      'Auto-fill',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 6 PIN boxes with particle burst on every pin entry
          PinParticleField(
            key: _pinFieldKey,
            controllers: _otpControllers,
            focusNodes: _otpFocusNodes,
            isDark: isDark,
            onChanged: () {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
            onCompleted: (_) => _handleVerify(),
          ),
          const SizedBox(height: 20),

          // Resend Timer
          Center(
            child: _cooldownSeconds > 0
                ? Text(
                    'Resend code in ${_cooldownSeconds}s',
                    style: TextStyle(
                      color: isDark ? AppColors.muted : AppColors.lightTextMuted,
                      fontSize: 12.5,
                    ),
                  )
                : TextButton.icon(
                    onPressed: _isLoading ? null : _handleResend,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text(
                      'Resend Code',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 20),

          StudioButton(
            label: 'Confirm & Activate Account',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _handleVerify,
          ),
        ],
      ),
    );
  }
}
