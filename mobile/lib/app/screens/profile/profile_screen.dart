import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_background.dart';
import '../../utils/validators.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/studio_button.dart';
import '../../widgets/studio_card.dart';
import '../../widgets/studio_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _studioName;
  late final TextEditingController _ownerName;
  late final TextEditingController _phone;
  late final TextEditingController _email;
  late final TextEditingController _city;
  late final TextEditingController _address;
  late final TextEditingController _about;
  late final TextEditingController _instagram;
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
    _website.text = user.website;
    _specialties.text = user.specialties;
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    final auth = context.read<AuthProvider>();
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    final success = await auth.uploadLogo(bytes, picked.name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Studio logo updated.'
              : auth.errorMessage ?? 'Could not upload logo.',
        ),
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
      'website': _website.text.trim(),
      'specialties': _specialties.text.trim(),
    });
    if (!mounted) return;
    if (success) {
      setState(() => _editing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Could not save profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return AuthBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            TextButton(
              onPressed: auth.isLoading
                  ? null
                  : () {
                      if (_editing) {
                        _fillFrom(user);
                        setState(() => _editing = false);
                      } else {
                        setState(() => _editing = true);
                      }
                    },
              child: Text(_editing ? 'Cancel' : 'Edit'),
            ),
          ],
        ),
        body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Center(
            child: Stack(
              children: [
                ProfileAvatar(logoUrl: user?.logoUrl, size: 112),
                if (_editing)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Semantics(
                      button: true,
                      label: 'Upload studio logo',
                      child: Material(
                        color: AppColors.aqua,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: auth.isLoading ? null : _pickLogo,
                          child: const Padding(
                            padding: EdgeInsets.all(8),
                            child: Icon(
                              Icons.photo_camera_outlined,
                              size: 18,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayStudioName ?? 'Your studio',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.paper,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.displayOwner ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 22),
          if (_editing) _buildForm(auth.isLoading) else _buildDetails(user),
          const SizedBox(height: 24),
          StudioButton(
            label: 'Sign out',
            onPressed: auth.isLoading
                ? null
                : () {
                    Navigator.of(context).pop();
                    context.read<AuthProvider>().logout();
                  },
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDetails(User? user) {
    return StudioCard(
      child: Column(
        children: [
          _DetailRow(label: 'Studio name', value: user?.displayStudioName ?? '—'),
          _DetailRow(label: 'Owner', value: user?.displayOwner ?? '—'),
          _DetailRow(label: 'Phone', value: user?.phone ?? '—'),
          _DetailRow(label: 'Email', value: _orDash(user?.email)),
          _DetailRow(label: 'City', value: _orDash(user?.city)),
          _DetailRow(label: 'Address', value: _orDash(user?.address)),
          _DetailRow(label: 'Specialties', value: _orDash(user?.specialties)),
          _DetailRow(label: 'Instagram', value: _orDash(user?.instagram)),
          _DetailRow(label: 'Website', value: _orDash(user?.website)),
          _DetailRow(label: 'About', value: _orDash(user?.about), last: true),
        ],
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
            label: 'Studio address',
            hint: 'Street, area, landmark',
            controller: _address,
            prefixIcon: Icons.map_outlined,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Specialties',
            hint: 'Wedding, fashion, newborn',
            controller: _specialties,
            prefixIcon: Icons.auto_awesome_outlined,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Instagram',
            hint: '@yourstudio',
            controller: _instagram,
            prefixIcon: Icons.camera_outlined,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'Website',
            hint: 'https://yourstudio.com',
            controller: _website,
            keyboardType: TextInputType.url,
            prefixIcon: Icons.language_rounded,
          ),
          const SizedBox(height: 14),
          StudioTextField(
            label: 'About the studio',
            hint: 'A short note clients will see',
            controller: _about,
            prefixIcon: Icons.notes_rounded,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 22),
          StudioButton(
            label: 'Save profile',
            isLoading: isLoading,
            onPressed: isLoading ? null : _save,
          ),
        ],
      ),
    );
  }

  String _orDash(String? value) =>
      (value == null || value.isEmpty) ? '—' : value;
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.muted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.paper,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
