import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/auth_mode_toggle.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/google_sign_in_button.dart';
import '../../widgets/studio_logo.dart';
import 'login_form.dart';
import 'set_password_sheet.dart';
import 'signup_form.dart';
import 'signup_otp_sheet.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logo;
  late final Animation<double> _toggle;
  late final Animation<double> _card;
  bool _isLogin = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logo = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    );
    _toggle = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.65, curve: Curves.easeOutCubic),
    );
    _card = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(String identifier, String password) async {
    final auth = context.read<AuthProvider>();
    final success = await auth.login(identifier: identifier, password: password);
    if (!success && mounted) {
      _showError(auth.errorMessage);
    }
  }

  Future<void> _handleSignup({
    required String username,
    required String email,
    required String password,
    String? phone,
  }) async {
    final auth = context.read<AuthProvider>();
    try {
      final res = await auth.sendSignupEmailOtp(
        username: username,
        email: email,
      );
      if (!mounted) return;
      final cd = (res['cooldownSeconds'] as num?)?.toInt() ?? 60;
      final debugOtp = res['debugOtp'] as String?;
      await SignupOtpSheet.show(
        context,
        username: username,
        email: email,
        password: password,
        phone: phone,
        initialCooldown: cd,
        initialDebugOtp: debugOtp,
      );
    } on ApiException catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError('Unable to send verification code. Please try again.');
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.signInWithGoogle();
    if (success && mounted) {
      if (auth.user?.needsPasswordSetup == true) {
        await SetPasswordSheet.show(context);
      }
    } else if (!success && mounted && auth.errorMessage != null) {
      _showError(auth.errorMessage);
    }
  }

  void _showError(String? message) {
    if (message == null || !mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxHeight < 760;
              final maxWidth = constraints.maxWidth > 600 ? 460.0 : 520.0;
              final width = math.min(constraints.maxWidth, maxWidth);
              return Align(
                alignment: compact ? Alignment.topCenter : Alignment.center,
                child: SizedBox(
                  width: width,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth > 600 ? 32 : 22,
                      vertical: compact ? 12 : 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FadeSlideIn(
                          animation: _logo,
                          child: StudioLogo(compact: compact),
                        ),
                        SizedBox(height: compact ? 16 : 28),
                        FadeSlideIn(
                          animation: _toggle,
                          child: AuthModeToggle(
                            isLogin: _isLogin,
                            onChanged: (value) {
                              if (_isLogin == value) return;
                              setState(() => _isLogin = value);
                              context.read<AuthProvider>().clearError();
                            },
                          ),
                        ),
                        SizedBox(height: compact ? 14 : 22),
                        FadeSlideIn(
                          animation: _card,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _AuthCard(
                                isLogin: _isLogin,
                                isLoading: isLoading,
                                onLogin: _handleLogin,
                                onSignup: _handleSignup,
                                onGoogleSignIn: _handleGoogleSignIn,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard({
    required this.isLogin,
    required this.isLoading,
    required this.onLogin,
    required this.onSignup,
    required this.onGoogleSignIn,
  });

  final bool isLogin;
  final bool isLoading;
  final Future<void> Function(String identifier, String password) onLogin;
  final Future<void> Function({
    required String username,
    required String email,
    required String password,
    String? phone,
  })
  onSignup;
  final VoidCallback onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0C1322).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    isLogin ? 'Welcome ' : 'Create ',
                    style: GoogleFonts.playfairDisplay(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [
                        Color(0xFF93C5FD),
                        Color(0xFFA78BFA),
                        Color(0xFFC084FC),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      isLogin ? 'back' : 'account',
                      style: GoogleFonts.alexBrush(
                        color: Colors.white,
                        fontSize: isLogin ? 44 : 38,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isLogin
                    ? 'Sign in to your Clients Hub account\nand continue your creative journey.'
                    : 'Join Clients Hub and start managing\nyour studio creative journey.',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF94A3B8),
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final authError = auth.errorMessage;
              if (authError == null || authError.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFEF4444), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        authError,
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => auth.clearError(),
                      child: const Icon(Icons.close_rounded,
                          color: Color(0xFFEF4444), size: 16),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(
            width: double.infinity,
            child: AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (currentChild, previousChildren) {
                  return Stack(
                    alignment: Alignment.topCenter,
                    children: <Widget>[...previousChildren, ?currentChild],
                  );
                },
                child: SizedBox(
                  width: double.infinity,
                  child: isLogin
                      ? LoginForm(
                          key: const ValueKey('login-form'),
                          isLoading: isLoading,
                          onSubmit: onLogin,
                        )
                      : SignupForm(
                          key: const ValueKey('signup-form'),
                          isLoading: isLoading,
                          onSubmit: onSignup,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  thickness: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: context.textMuted,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  thickness: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GoogleSignInButton(
            isLoading: isLoading,
            label: isLogin ? 'Sign in with Google' : 'Sign up with Google',
            onPressed: isLoading ? null : onGoogleSignIn,
          ),
        ],
      ),
    ),
  ),
);
  }
}
