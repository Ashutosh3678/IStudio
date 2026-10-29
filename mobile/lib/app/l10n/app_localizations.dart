import 'package:flutter/material.dart';
import '../services/translation_service.dart';

/// App-wide localization supporting English by default, Telugu, and ANY language
/// dynamically via Google Translate.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return loc ?? const AppLocalizations(Locale('en'));
  }

  static const delegate = _AppLocalizationsDelegate();

  static const supportedLocales = [
    Locale('en'),
    Locale('te'),
    Locale('hi'),
    Locale('ta'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('bn'),
    Locale('gu'),
    Locale('pa'),
    Locale('ur'),
    Locale('or'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('ar'),
    Locale('ja'),
    Locale('zh'),
    Locale('ru'),
  ];

  String get languageCode => locale.languageCode;

  /// Translate any string dynamically for this locale
  String t(String englishText) {
    return TranslationService.instance.getCached(englishText, languageCode);
  }

  // ── Common getters ─────────────────────────────────────────────────────────
  String get signIn => t('Sign In');
  String get signUp => t('Sign Up');
  String get email => t('Email');
  String get password => t('Password');
  String get forgotPassword => t('Forgot Password?');
  String get signOut => t('Sign out');
  String get home => t('Home');
  String get clients => t('Clients');
  String get calendar => t('Calendar');
  String get invoices => t('Invoices');
  String get profile => t('Profile');

  // ── Onboarding ─────────────────────────────────────────────────────────────
  String get setUpYourStudio => t('Set up your studio');
  String get onboardingSubtitle => t(
      'Tell us about your photography studio. These details appear on your receipts and profile.');
  String get studioLogoOptional => t('Studio logo (optional)');
  String get saveAndEnterStudio => t('Save & Enter Studio');
  String get studioDetails => t('Studio Details');
  String get contactAndLocation => t('Contact & Location');
  String get socialsOptional => t('Socials (optional)');

  // ── Profile ────────────────────────────────────────────────────────────────
  String get studioProfile => t('Studio Profile');
  String get edit => t('Edit');
  String get cancel => t('Cancel');
  String get save => t('Save');
  String get saveProfile => t('Save profile');
  String get studioName => t('Studio name');
  String get ownerName => t('Owner name');
  String get username => t('Username');
  String get phone => t('Phone');
  String get city => t('City');
  String get state => t('State');
  String get district => t('District');
  String get address => t('Address');
  String get specialties => t('Specialties');
  String get about => t('About');
  String get photographerRoles => t('Photographer Roles');
  String get selectRoles => t('Select Roles');
  String get editRoles => t('Edit Roles');
  String get accountSettings => t('Account Settings');
  String get changePassword => t('Change Password');
  String get changeEmail => t('Change Email');
  String get deleteAccount => t('Delete Account');

  // ── Settings & Language ────────────────────────────────────────────────────
  String get appLanguage => t('App Language');
  String get selectLanguage => t('Select Language');
  String get languageSubtitle => t('Choose the language for the entire app');
  String get english => 'English';
  String get telugu => 'తెలుగు (Telugu)';
  String get languageUpdated => t('Language updated');

  // ── Events ─────────────────────────────────────────────────────────────────
  String get createNewEvent => t('Create New Event');
  String get eventName => t('Event Name');
  String get eventCategory => t('Event Category');
  String get selectEventCategory => t('Select Event Category');
  String get wedding => t('Wedding');
  String get maternity => t('Maternity');
  String get commercial => t('Commercial');
  String get newborn => t('Newborn');
  String get preWedding => t('Pre-wedding');
  String get portrait => t('Portrait');
  String get fashion => t('Fashion');
  String get event => t('Event');
  String get others => t('Others');
  String get specifyEventType => t('Specify Event Type *');

  // ── State & District Dropdowns ─────────────────────────────────────────────
  String get stateRegion => t('State / Region *');
  String get selectState => t('Select State');
  String get districtArea => t('District / Area *');
  String get selectDistrict => t('Select District');
  String get selectStateFirst => t('Select state first');
  String get selectYourState => t('Select your state');
  String get selectYourDistrict => t('Select your district');

  // ── Custom Category / Other ────────────────────────────────────────────────
  String get other => t('Other');
  String get specifyCategoryHint => t('e.g. Aerial Photographer, Food Photographer...');
  String get specifyCustomCategory => t('Specify your role / category *');
  String get selected => t('Selected');
  String get multipleAllowed => t('Multiple Allowed');
  String get primaryRoles => t('Primary Roles');
  String get operators => t('Operators');
  String get done => t('Done');
  String get photographerRolesAndCategories => t('Photographer Roles & Categories');
  String get chooseMultipleRoles => t('Choose multiple roles that define your studio and services');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true; // Support ANY language!

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}

