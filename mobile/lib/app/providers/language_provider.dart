import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/translation_service.dart';

class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}

class LanguageProvider extends ChangeNotifier {
  static const String _prefKey = 'app_selected_language_code';

  static const List<AppLanguage> supportedLanguages = [
    AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧'),
    AppLanguage(code: 'te', name: 'Telugu', nativeName: 'తెలుగు', flag: '🇮🇳'),
    AppLanguage(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी', flag: '🇮🇳'),
    AppLanguage(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்', flag: '🇮🇳'),
    AppLanguage(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ', flag: '🇮🇳'),
    AppLanguage(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം', flag: '🇮🇳'),
    AppLanguage(code: 'mr', name: 'Marathi', nativeName: 'मराठी', flag: '🇮🇳'),
    AppLanguage(code: 'bn', name: 'Bengali', nativeName: 'বাংলা', flag: '🇮🇳'),
    AppLanguage(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી', flag: '🇮🇳'),
    AppLanguage(code: 'pa', name: 'Punjabi', nativeName: 'ਪੰਜਾਬੀ', flag: '🇮🇳'),
    AppLanguage(code: 'ur', name: 'Urdu', nativeName: 'اردو', flag: '🇮🇳'),
    AppLanguage(code: 'or', name: 'Odia', nativeName: 'ଓଡ଼ିଆ', flag: '🇮🇳'),
    AppLanguage(code: 'es', name: 'Spanish', nativeName: 'Español', flag: '🇪🇸'),
    AppLanguage(code: 'fr', name: 'French', nativeName: 'Français', flag: '🇫🇷'),
    AppLanguage(code: 'de', name: 'German', nativeName: 'Deutsch', flag: '🇩🇪'),
    AppLanguage(code: 'ar', name: 'Arabic', nativeName: 'العربية', flag: '🇸🇦'),
    AppLanguage(code: 'ja', name: 'Japanese', nativeName: '日本語', flag: '🇯🇵'),
    AppLanguage(code: 'zh', name: 'Chinese', nativeName: '中文', flag: '🇨🇳'),
    AppLanguage(code: 'ru', name: 'Russian', nativeName: 'Русский', flag: '🇷🇺'),
  ];

  String _languageCode = 'en';
  final bool _isTranslating = false;

  String get languageCode => _languageCode;
  Locale get locale => Locale(_languageCode);
  bool get isEnglish => _languageCode == 'en';
  bool get isTelugu => _languageCode == 'te';
  bool get isTranslating => _isTranslating;

  AppLanguage get currentLanguage {
    return supportedLanguages.firstWhere(
      (l) => l.code == _languageCode,
      orElse: () => AppLanguage(
        code: _languageCode,
        name: _languageCode.toUpperCase(),
        nativeName: _languageCode.toUpperCase(),
        flag: '🌐',
      ),
    );
  }

  Future<void> bootstrap() async {
    await TranslationService.instance.init();
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved != null && saved.isNotEmpty) {
        _languageCode = saved;
        notifyListeners();
        _precacheEssentialPhrases(saved);
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String code) async {
    if (_languageCode == code) return;
    _languageCode = code;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}

    // Pre-cache primary app phrases for the newly selected language via Google Translate
    _precacheEssentialPhrases(code);
  }

  /// Translates [englishText] to current language.
  /// If cached, returns immediately. If not cached, triggers background Google Translate and notifies UI.
  String t(String englishText) {
    if (_languageCode == 'en' || englishText.trim().isEmpty) {
      return englishText;
    }

    final cached = TranslationService.instance.getCached(englishText, _languageCode);
    if (cached != englishText) {
      return cached;
    }

    // Trigger asynchronous translation in background
    _fetchAsync(englishText, _languageCode);
    return englishText;
  }

  final Set<String> _pendingRequests = {};
  Timer? _notifyDebounceTimer;

  void _scheduleNotifyListeners() {
    _notifyDebounceTimer?.cancel();
    _notifyDebounceTimer = Timer(const Duration(milliseconds: 60), () {
      notifyListeners();
    });
  }

  void _fetchAsync(String text, String lang) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final key = '$lang::$trimmed';
    if (_pendingRequests.contains(key)) return;
    _pendingRequests.add(key);

    TranslationService.instance.translate(trimmed, targetLang: lang).then((result) {
      _pendingRequests.remove(key);
      if (result != trimmed && _languageCode == lang) {
        _scheduleNotifyListeners();
      }
    }).catchError((_) {
      _pendingRequests.remove(key);
    });
  }

  void _precacheEssentialPhrases(String lang) {
    if (lang == 'en') return;
    const commonPhrases = [
      'Home',
      'Calendar',
      'Invoices',
      'Clients',
      'Discover',
      'Find Photographers',
      'Set up your studio',
      'Studio Profile',
      'Studio Details',
      'Contact & Location',
      'Socials (optional)',
      'Account Settings',
      'App Language',
      'Choose App Language',
      'Studio Name',
      'Studio name',
      'Owner',
      'Owner name',
      'Username',
      'Phone',
      'Phone number',
      'Mobile number *',
      'Email',
      'Email (Read-only)',
      'Country',
      'Country *',
      'City',
      'State',
      'District',
      'Address',
      'Studio address *',
      'Specialties',
      'About',
      'Photographer Roles',
      'Photographer Roles & Categories',
      'Select Roles',
      'Edit Roles',
      'Save profile',
      'Edit',
      'Cancel',
      'Save',
      'Done',
      'Later',
      'Sign out',
      'State / Region *',
      'District / Area *',
      'State / Province / Region *',
      'City / District / Area *',
      'Select State',
      'Select District',
      'Select state first',
      'Select your state',
      'Select your district',
      'Create New Event',
      'Event Name',
      'Event Category',
      'Wedding',
      'Maternity',
      'Commercial',
      'Newborn',
      'Pre-wedding',
      'Portrait',
      'Fashion',
      'Event',
      'Drone',
      'Album Designer',
      'Video Editor',
      'Reels',
      'Traditional Photo Operator',
      'Traditional Video Operator',
      'Candid Photo Operator',
      'Candid Video Operator',
      'Other',
      'Others',
      'Specify your role / category *',
      'Change Password',
      'Change Email',
      'Delete Account',
      'Payments',
      'Payment QR',
      'Legal',
      'Privacy Policy',
      'Terms of Service',
      'App Features & Tour',
      'Quick Actions',
      'Upcoming Shoots',
      'View All',
      'Financial Overview',
      'Recent Invoices',
      'Complete Your Profile',
      // Calendar
      'Calendar',
      'Booked sessions',
      'Monthly Earnings',
      'Income, expenses & profit for',
      'No events on this day',
      'Shoot',
      'Shoots',
      'Paid in Full',
      'Balance',
      'Details',
      // Invoice
      'Receipt',
      'Make a bill',
      'All bills',
      'New',
      'Past',
      // Clients
      'Clients',
      'clients',
      'Search by name or phone...',
      'No clients found',
      'Adjust your search or clear filters',
      'Filter Clients',
      'Reset',
      'All',
      'Information',
      'Coming Up',
      'Completed',
      'Not Responded',
      'Due',
      'New Client Profile',
      'Inquiry lead, upcoming shoot, or past client',
      'Client Stage / Category',
      'Save Client Profile',
      'Please enter client full name',
      'Please enter phone number',
      'Phone number must be at least 10 digits',
      'Inquiry',
      'No response after 15 days',
      'Follow Up',
      'Inquiry lead · Event not booked yet',
      'Active',
      'No events scheduled yet',
      'Event',
      'Events',
      'All Paid',
      // Discover
      'Discover Photographers',
      'Nearby Photographers',
      'Explore Photographers in India',
      'Select a state or union territory to discover verified local studios and operators.',
      'Search 36 states & union territories...',
      'districts',
      'State',
      'Change State',
      'Select District in',
      'About',
      'Categories & Services',
      'Send via WhatsApp',
      'More Sharing Options',
      'Event Summary',
    ];

    for (final phrase in commonPhrases) {
      _fetchAsync(phrase, lang);
    }
  }

  @override
  void dispose() {
    _notifyDebounceTimer?.cancel();
    super.dispose();
  }
}

extension TranslationExtension on BuildContext {
  /// Convenient translate method: context.tr('Some English Text')
  String tr(String englishText) {
    if (englishText.isEmpty) return englishText;
    try {
      return watch<LanguageProvider>().t(englishText);
    } catch (_) {
      return englishText;
    }
  }
}
