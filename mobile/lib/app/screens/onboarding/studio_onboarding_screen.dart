import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/validators.dart';
import '../../widgets/avatar_crop_screen.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_card.dart';
import '../../widgets/studio_text_field.dart';

/// Shown after sign-in until the studio profile has every required field.
class StudioOnboardingScreen extends StatefulWidget {
  const StudioOnboardingScreen({super.key});

  @override
  State<StudioOnboardingScreen> createState() => _StudioOnboardingScreenState();
}

class _StudioOnboardingScreenState extends State<StudioOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studioName;
  late final TextEditingController _ownerName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _specialties;
  late final TextEditingController _about;
  late final TextEditingController _instagram;
  late final TextEditingController _youtube;
  late final TextEditingController _website;
  bool _uploadingLogo = false;

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
    _specialties = TextEditingController(text: user?.specialties ?? '');
    _about = TextEditingController(text: user?.about ?? '');
    _instagram = TextEditingController(text: user?.instagram ?? '');
    _youtube = TextEditingController(text: user?.youtube ?? '');
    _website = TextEditingController(text: user?.website ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _studioName,
      _ownerName,
      _phone,
      _email,
      _city,
      _address,
      _specialties,
      _about,
      _instagram,
      _youtube,
      _website,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? value, String message) =>
      (value == null || value.trim().isEmpty) ? message : null;

  Future<void> _pickLogo(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    final original = await picked.readAsBytes();
    if (!mounted) return;
    final cropped = await AvatarCropScreen.open(
      context,
      bytes: original,
      filename: picked.name,
    );
    if (cropped == null || !mounted) return;
    setState(() => _uploadingLogo = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.uploadLogo(cropped.bytes, cropped.filename);
    if (!mounted) return;
    setState(() => _uploadingLogo = false);
    if (ok) {
      AppSnackBar.success(context, 'Studio photo uploaded.');
    } else {
      AppSnackBar.error(context, auth.errorMessage ?? 'Could not upload photo.');
    }
  }

  void _showLogoSourcePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library_outlined,
                    color: sheetContext.accentColor),
                title: Text('Choose from Gallery',
                    style: TextStyle(color: sheetContext.textMain)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickLogo(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt_outlined,
                    color: sheetContext.accentColor),
                title: Text('Take a Photo',
                    style: TextStyle(color: sheetContext.textMain)),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickLogo(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      AppSnackBar.error(context, 'Please fix the highlighted fields.');
      return;
    }
    final auth = context.read<AuthProvider>();
    final ok = await auth.updateProfile({
      'studioName': _studioName.text.trim(),
      'ownerName': _ownerName.text.trim(),
      'phone': _phone.text.trim(),
      'email': _email.text.trim(),
      'city': _city.text.trim(),
      'address': _address.text.trim(),
      'specialties': _specialties.text.trim(),
      'about': _about.text.trim(),
      'instagram': _instagram.text.trim(),
      'youtube': _youtube.text.trim(),
      'website': _website.text.trim(),
    });
    if (!mounted) return;
    if (ok) {
      AppSnackBar.success(context, 'Welcome aboard! Your studio is ready.');
    } else {
      AppSnackBar.error(
        context,
        auth.errorMessage ?? 'Could not save your profile. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final busy = auth.isLoading || _uploadingLogo;
    final accent = context.accentColor;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  32 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: busy ? null : auth.logout,
                      icon: const Icon(Icons.logout_rounded, size: 16),
                      label: const Text('Sign out'),
                    ),
                  ),
                  Text(
                    'Set up your studio',
                    style: GoogleFonts.playfairDisplay(
                      color: context.textMain,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tell us about your photography studio. These details appear on your receipts and profile.',
                    style: GoogleFonts.plusJakartaSans(
                      color: context.textMuted,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: accent.withValues(alpha: 0.35),
                              width: 2.5,
                            ),
                          ),
                          child: ProfileAvatar(logoUrl: user?.logoUrl, size: 96),
                        ),
                        if (_uploadingLogo)
                          const SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(strokeWidth: 3),
                          ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Material(
                            color: accent,
                            shape: const CircleBorder(),
                            elevation: 4,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: busy ? null : _showLogoSourcePicker,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Icon(Icons.camera_alt_rounded,
                                    size: 16, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Studio logo / photo (optional)',
                      style: TextStyle(color: context.textMuted, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _section('Studio Details'),
                  StudioCard(
                    child: Column(
                      children: [
                        StudioTextField(
                          label: 'Studio name *',
                          hint: 'e.g. Royal Lens Studios',
                          controller: _studioName,
                          prefixIcon: Icons.apartment_outlined,
                          validator: (v) =>
                              _required(v, 'Enter your studio name'),
                        ),
                        const SizedBox(height: 14),
                        StudioTextField(
                          label: 'Owner / photographer name *',
                          hint: 'e.g. Rahul Sharma',
                          controller: _ownerName,
                          prefixIcon: Icons.badge_outlined,
                          validator: (v) => _required(v, 'Enter the owner name'),
                        ),
                        const SizedBox(height: 14),
                        StudioTextField(
                          label: 'Specialties *',
                          hint: 'Weddings, portraits, commercial...',
                          controller: _specialties,
                          prefixIcon: Icons.auto_awesome_outlined,
                          validator: (v) =>
                              _required(v, 'Enter what you specialise in'),
                        ),
                        const SizedBox(height: 14),
                        StudioTextField(
                          label: 'About your studio *',
                          hint: 'Tell clients what makes your studio special',
                          controller: _about,
                          maxLines: 3,
                          validator: (v) =>
                              _required(v, 'Write a short description'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _section('Contact & Location'),
                  StudioCard(
                    child: Column(
                      children: [
                        StudioTextField(
                          label: 'Mobile number *',
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
                          label: 'Email *',
                          hint: 'studio@email.com',
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.mail_outline_rounded,
                          validator: Validators.email,
                        ),
                        const SizedBox(height: 14),
                        StudioTextField(
                          label: 'City *',
                          hint: 'e.g. Mumbai',
                          controller: _city,
                          prefixIcon: Icons.location_city_outlined,
                          validator: (v) => _required(v, 'Enter your city'),
                        ),
                        const SizedBox(height: 14),
                        StudioTextField(
                          label: 'Studio address *',
                          hint: 'Street, floor, landmark',
                          controller: _address,
                          prefixIcon: Icons.place_outlined,
                          maxLines: 2,
                          validator: (v) =>
                              _required(v, 'Enter your studio address'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _section('Socials (optional)'),
                  StudioCard(
                    child: Column(
                      children: [
                        StudioTextField(
                          label: 'Instagram',
                          hint: 'instagram.com/yourstudio',
                          controller: _instagram,
                          keyboardType: TextInputType.url,
                          prefixIcon: Icons.camera_alt_outlined,
                          validator: Validators.instagram,
                        ),
                        const SizedBox(height: 14),
                        StudioTextField(
                          label: 'YouTube',
                          hint: 'youtube.com/@yourstudio',
                          controller: _youtube,
                          keyboardType: TextInputType.url,
                          prefixIcon: Icons.ondemand_video_rounded,
                          validator: Validators.youtube,
                        ),
                        const SizedBox(height: 14),
                        StudioTextField(
                          label: 'Website',
                          hint: 'yourstudio.com',
                          controller: _website,
                          keyboardType: TextInputType.url,
                          prefixIcon: Icons.link_rounded,
                          validator: Validators.website,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  StudioButton(
                    label: 'Save & Enter Studio',
                    isLoading: auth.isLoading,
                    onPressed: busy ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          color: context.textMain,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
