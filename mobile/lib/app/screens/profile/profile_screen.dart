import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/validators.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_card.dart';
import '../../widgets/studio_text_field.dart';
import '../../widgets/change_password_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  bool _isUploadingImage = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studioName;
  late final TextEditingController _ownerName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _about;
  late final TextEditingController _instagram;
  late final TextEditingController _youtube;
  late final TextEditingController _website;
  late final TextEditingController _specialties;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _studioName = TextEditingController(text: user?.studioName ?? '');
    _ownerName = TextEditingController(text: user?.displayOwner ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _city = TextEditingController(text: user?.city ?? '');
    _address = TextEditingController(text: user?.address ?? '');
    _about = TextEditingController(text: user?.about ?? '');
    _instagram = TextEditingController(text: user?.instagram ?? '');
    _youtube = TextEditingController(text: user?.youtube ?? '');
    _website = TextEditingController(text: user?.website ?? '');
    _specialties = TextEditingController(text: user?.specialties ?? '');
  }

  @override
  void dispose() {
    _studioName.dispose();
    _ownerName.dispose();
    _phone.dispose();
    _email.dispose();
    _city.dispose();
    _address.dispose();
    _about.dispose();
    _instagram.dispose();
    _youtube.dispose();
    _website.dispose();
    _specialties.dispose();
    super.dispose();
  }

  void _fillFrom(User? user) {
    if (user == null) return;
    _studioName.text = user.studioName;
    _ownerName.text = user.displayOwner;
    _phone.text = user.phone;
    _email.text = user.email;
    _city.text = user.city;
    _address.text = user.address;
    _about.text = user.about;
    _instagram.text = user.instagram;
    _youtube.text = user.youtube;
    _website.text = user.website;
    _specialties.text = user.specialties;
  }

  Future<void> _showImageSourcePicker() async {
    final user = context.read<AuthProvider>().user;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Profile Photo',
                    style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                          color: sheetContext.textMain,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sheetContext.accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.photo_library_outlined,
                        color: sheetContext.accentColor),
                  ),
                  title: Text('Choose from Gallery',
                      style: TextStyle(color: sheetContext.textMain)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickAndUpload(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sheetContext.accentColor.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.camera_alt_outlined,
                        color: sheetContext.accentColor),
                  ),
                  title: Text('Take a Photo',
                      style: TextStyle(color: sheetContext.textMain)),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _pickAndUpload(ImageSource.camera);
                  },
                ),
                if (user?.logoUrl.isNotEmpty == true)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    title: const Text('Remove Photo',
                        style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.of(sheetContext).pop();
                      _removeProfilePhoto();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickAndUpload(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null) return;

      setState(() => _isUploadingImage = true);

      final bytes = await picked.readAsBytes();
      final filename = picked.name;

      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final success = await auth.uploadLogo(bytes, filename);

      if (!mounted) return;
      setState(() => _isUploadingImage = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Profile image updated successfully.'
                : auth.errorMessage ?? 'Could not upload profile image.',
          ),
          backgroundColor: AppColors.navy,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isUploadingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick or upload image: $e'),
            backgroundColor: AppColors.navy,
          ),
        );
      }
    }
  }

  Future<void> _removeProfilePhoto() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile({'logoUrl': ''});
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Profile photo removed.'
              : auth.errorMessage ?? 'Could not remove photo.',
        ),
        backgroundColor: AppColors.navy,
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.updateProfile({
      'studioName': _studioName.text.trim(),
      'ownerName': _ownerName.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim(),
      'city': _city.text.trim(),
      'address': _address.text.trim(),
      'about': _about.text.trim(),
      'instagram': _instagram.text.trim(),
      'youtube': _youtube.text.trim(),
      'website': _website.text.trim(),
      'specialties': _specialties.text.trim(),
    });
    if (!mounted) return;
    if (success) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved.'),
          backgroundColor: AppColors.navy,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Could not save profile.'),
          backgroundColor: AppColors.navy,
        ),
      );
    }
  }

  Future<void> _openChangePasswordSheet() async {
    final success = await ChangePasswordSheet.show(context);
    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully.'),
          backgroundColor: AppColors.navy,
        ),
      );
    }
  }

  void _showDeleteAccountSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const _DeleteAccountSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final isBusy = auth.isLoading || _isUploadingImage;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Studio Profile',
          style: TextStyle(
            color: context.textMain,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: context.accentColor,
                backgroundColor: context.accentColor.withValues(alpha: 0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              ),
              onPressed: isBusy
                  ? null
                  : () {
                      if (_editing) {
                        _fillFrom(user);
                        setState(() => _editing = false);
                      } else {
                        setState(() => _editing = true);
                      }
                    },
              icon: Icon(_editing ? Icons.close_rounded : Icons.edit_outlined, size: 16),
              label: Text(_editing ? 'Cancel' : 'Edit'),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              // Profile Header Card
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.accentColor.withValues(alpha: 0.35),
                          width: 2.5,
                        ),
                      ),
                      child: ProfileAvatar(logoUrl: user?.logoUrl, size: 104),
                    ),
                    if (_isUploadingImage)
                      Container(
                        width: 112,
                        height: 112,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.ink.withValues(alpha: 0.7),
                        ),
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.sky),
                          ),
                        ),
                      ),
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Semantics(
                        button: true,
                        label: 'Upload studio profile image',
                        child: Material(
                          color: context.accentColor,
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: isBusy ? null : _showImageSourcePicker,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.camera_alt_rounded,
                                size: 17,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                user?.displayStudioName ?? 'Your studio',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: context.textMain,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.displayOwner ?? '',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.textMuted,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              if (_editing) ...[
                _buildForm(isBusy),
              ] else ...[
                // Section 1: Studio Details
                _buildSectionHeader(context, 'Studio Details', Icons.apartment_rounded),
                const SizedBox(height: 8),
                _buildStudioDetailsCard(user),

                const SizedBox(height: 18),
                // Section 2: Online & Social
                _buildSectionHeader(context, 'Social & Portfolio', Icons.share_rounded),
                const SizedBox(height: 8),
                _buildSocialCard(user),

                const SizedBox(height: 18),
                // Section 3: Account Settings
                _buildSectionHeader(context, 'Account Settings', Icons.settings_outlined),
                const SizedBox(height: 8),
                _buildSettingsCard(context),

                const SizedBox(height: 24),
                StudioButton(
                  label: 'Sign out',
                  isSecondary: true,
                  icon: Icons.logout_rounded,
                  onPressed: isBusy
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          context.read<AuthProvider>().logout();
                        },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon, {bool isDanger = false}) {
    final color = isDanger ? const Color(0xFFFF5252) : context.accentColor;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: isDanger ? const Color(0xFFFF5252) : context.textMain,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudioDetailsCard(User? user) {
    return StudioCard(
      child: Column(
        children: [
          _DetailRow(icon: Icons.apartment_outlined, label: 'Studio Name', value: user?.displayStudioName ?? '—'),
          _DetailRow(icon: Icons.person_outline_rounded, label: 'Owner', value: user?.displayOwner ?? '—'),
          _DetailRow(icon: Icons.phone_outlined, label: 'Phone', value: user?.phone ?? '—'),
          _DetailRow(icon: Icons.mail_outline_rounded, label: 'Email', value: _orDash(user?.email)),
          _DetailRow(icon: Icons.location_city_outlined, label: 'City', value: _orDash(user?.city)),
          _DetailRow(icon: Icons.place_outlined, label: 'Address', value: _orDash(user?.address), last: true),
        ],
      ),
    );
  }

  Widget _buildSocialCard(User? user) {
    return StudioCard(
      child: Column(
        children: [
          _DetailRow(icon: Icons.auto_awesome_outlined, label: 'Specialties', value: _orDash(user?.specialties)),
          _DetailRow(icon: Icons.camera_alt_outlined, label: 'Instagram', value: _orDash(user?.instagram)),
          _DetailRow(icon: Icons.ondemand_video_rounded, label: 'YouTube', value: _orDash(user?.youtube)),
          _DetailRow(icon: Icons.link_rounded, label: 'Website', value: _orDash(user?.website)),
          _DetailRow(icon: Icons.info_outline_rounded, label: 'About', value: _orDash(user?.about), last: true),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context) {
    final textMain = context.textMain;
    final textMuted = context.textMuted;
    final accent = context.accentColor;

    return StudioCard(
      child: Container(
        decoration: BoxDecoration(
          color: context.innerBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.cardBorder),
        ),
        child: Column(
          children: [
            // Option 1: Change Password
            InkWell(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              onTap: _openChangePasswordSheet,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.lock_reset_rounded, color: accent, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Change Password',
                            style: TextStyle(
                              color: textMain,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Update current login password',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: textMuted),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: context.cardBorder),
            // Option 2: Delete Account
            InkWell(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
              onTap: _showDeleteAccountSheet,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: textMuted.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.delete_outline_rounded, color: textMain, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delete Account',
                            style: TextStyle(
                              color: textMain,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Permanently remove account and studio data',
                            style: TextStyle(
                              color: textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: textMuted),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          StudioTextField(
            label: 'Photography studio name',
            hint: 'Lumen Studio',
            controller: _studioName,
            prefixIcon: Icons.apartment_outlined,
            validator: (value) =>
                (value == null || value.trim().isEmpty)
                    ? 'Enter your studio name'
                    : null,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Owner name',
            hint: 'Your name',
            controller: _ownerName,
            prefixIcon: Icons.person_outline_rounded,
            validator: (value) =>
                (value == null || value.trim().isEmpty)
                    ? 'Enter the owner name'
                    : null,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Phone number',
            hint: '10-digit mobile number',
            controller: _phone,
            keyboardType: TextInputType.phone,
            prefixIcon: Icons.phone_outlined,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: Validators.phone,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Email',
            hint: 'studio@email.com',
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.mail_outline_rounded,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'City',
            hint: 'Where the studio is based',
            controller: _city,
            prefixIcon: Icons.location_city_outlined,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Address',
            hint: 'Street, floor, landmark',
            controller: _address,
            prefixIcon: Icons.place_outlined,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Specialties',
            hint: 'Weddings, portraits, commercial...',
            controller: _specialties,
            prefixIcon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Instagram',
            hint: '@yourstudio',
            controller: _instagram,
            prefixIcon: Icons.camera_alt_outlined,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'YouTube Channel / Link',
            hint: 'https://youtube.com/@yourstudio',
            controller: _youtube,
            prefixIcon: Icons.ondemand_video_rounded,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Website',
            hint: 'https://yourstudio.com',
            controller: _website,
            prefixIcon: Icons.link_rounded,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'About',
            hint: 'Tell clients what makes your studio special',
            controller: _about,
            maxLines: 4,
          ),
          const SizedBox(height: 20),
          StudioButton(
            label: 'Save profile',
            isLoading: isLoading,
            onPressed: isLoading ? null : _save,
          ),
        ],
      ),
    );
  }

  String _orDash(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    return value.trim();
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.icon,
    this.last = false,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: context.accentColor.withValues(alpha: 0.7)),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted(context),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMain(context),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two-step account deletion verification sheet (Email OTP + Password)
class _DeleteAccountSheet extends StatefulWidget {
  const _DeleteAccountSheet();

  @override
  State<_DeleteAccountSheet> createState() => _DeleteAccountSheetState();
}

class _DeleteAccountSheetState extends State<_DeleteAccountSheet> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _sendingOtp = false;
  bool _otpSent = false;
  int _cooldown = 0;
  Timer? _timer;
  bool _deleting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldown <= 1) {
        timer.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _sendOtp() async {
    setState(() {
      _sendingOtp = true;
      _errorMessage = null;
    });

    try {
      final auth = context.read<AuthProvider>();
      final result = await auth.sendDeleteAccountOtp();
      if (!mounted) return;

      setState(() {
        _sendingOtp = false;
        _otpSent = true;
      });
      _startCooldown();

      // Auto-fill debug OTP if provided by server fallback
      final debugOtp = result['debugOtp'] as String?;
      if (debugOtp != null && debugOtp.isNotEmpty) {
        _otpController.text = debugOtp;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String? ?? 'Verification code sent to your email.'),
          backgroundColor: AppColors.navy,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sendingOtp = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _confirmDelete() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text;

    if (otp.length != 6) {
      setState(() => _errorMessage = 'Please enter the 6-digit verification code.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your account password.');
      return;
    }

    setState(() {
      _deleting = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    final success = await auth.deleteAccount(otp: otp, password: password);

    if (!mounted) return;
    setState(() => _deleting = false);

    if (success) {
      Navigator.of(context).pop(); // Close bottom sheet
      Navigator.of(context).pop(); // Exit profile screen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your account and associated data have been permanently deleted.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } else {
      setState(() {
        _errorMessage = auth.errorMessage ?? 'Unable to delete account.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    const dangerColor = Color(0xFFFF5252);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: dangerColor.withValues(alpha: 0.3), width: 1.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: dangerColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: dangerColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Permanently Delete Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: dangerColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'This action cannot be undone.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Warning Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dangerColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: dangerColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: dangerColor, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'All your events, clients, quotes, invoices, and expenses will be permanently wiped. To protect your data, verify your identity below.',
                      style: TextStyle(fontSize: 12, color: context.textMain, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Error banner if any
            if (_errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(fontSize: 12, color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Step 1: Mail Verification
            Text(
              'STEP 1: VERIFY EMAIL OWNERSHIP',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.accentColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.innerBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: context.cardBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.mail_outline_rounded, size: 18, color: context.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      user?.email ?? 'Registered Email',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: context.textMain,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 34,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: (_sendingOtp || _cooldown > 0) ? null : _sendOtp,
                      child: _sendingOtp
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _cooldown > 0
                                  ? '${_cooldown}s'
                                  : (_otpSent ? 'Resend' : 'Send Code'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            if (_otpSent) ...[
              const SizedBox(height: 10),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: TextStyle(
                  color: context.textMain,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter 6-digit code',
                  hintStyle: TextStyle(
                    color: context.textMuted,
                    fontSize: 13,
                    letterSpacing: 0,
                  ),
                  prefixIcon: Icon(Icons.pin_outlined, color: context.accentColor, size: 20),
                  filled: true,
                  fillColor: context.innerBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.cardBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.cardBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: context.accentColor, width: 1.5),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 18),

            // Step 2: Password Verification
            Text(
              'STEP 2: CONFIRM ACCOUNT PASSWORD',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: context.accentColor,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(color: context.textMain, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Enter your account password',
                hintStyle: TextStyle(color: context.textMuted, fontSize: 13),
                prefixIcon: Icon(Icons.lock_outline_rounded, color: context.accentColor, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: context.textMuted,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                filled: true,
                fillColor: context.innerBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.cardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.accentColor, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Delete Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: dangerColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _deleting ? null : _confirmDelete,
              child: _deleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'Permanently Delete Account',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: context.textMuted, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
