import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Robust multi-lingual translation service with Google Translate API integration
/// and two-tier in-memory & SharedPreferences disk caching.
class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  // In-memory cache: targetLang -> (sourceText -> translatedText)
  final Map<String, Map<String, String>> _memoryCache = {};
  bool _initialized = false;

  /// Comprehensive pre-populated dictionaries for instant, zero-latency rendering
  /// of core UI elements across all screens.
  static const Map<String, Map<String, String>> _initialDictionary = {
    'te': {
      // Navigation & Dock
      'Home': 'హోమ్',
      'Calendar': 'క్యాలెండర్',
      'Invoices': 'ఇన్‌వాయిస్‌లు',
      'Clients': 'క్లయింట్లు',
      'Discover': 'డిస్కవర్',
      'Find Photographers': 'ఫోటోగ్రాఫర్లను కనుగొనండి',

      // Profile & Studio Info
      'Studio Profile': 'స్టూడియో ప్రొఫైల్',
      'Studio Details': 'స్టూడియో వివరాలు',
      'Studio Name': 'స్టూడియో పేరు',
      'Studio name': 'స్టూడియో పేరు',
      'Studio name *': 'స్టూడియో పేరు *',
      'Owner': 'యజమాని',
      'Owner name': 'యజమాని పేరు',
      'Owner name *': 'యజమాని పేరు *',
      'Username': 'యూజర్ పేరు',
      'Username *': 'యూజర్ పేరు *',
      'Username (Locked)': 'యూజర్ పేరు (లాక్ చేయబడింది)',
      'Phone': 'ఫోన్ నంబర్',
      'Phone number': 'ఫోన్ నంబర్',
      'Mobile number *': 'మొబైల్ నంబర్ *',
      '10-digit mobile number': '10-అంకెల మొబైల్ నంబర్',
      'Email': 'ఇమెయిల్',
      'Email (Read-only)': 'ఇమెయిల్ (చదవడానికి మాత్రమే)',
      'Email (Locked)': 'ఇమెయిల్ (లాక్ చేయబడింది)',
      'Studio Location': 'స్టూడియో స్థానం',
      'Search studio address or venue…': 'స్టూడియో చిరునామా లేదా వేదికను శోధించండి…',
      'Country': 'దేశం',
      'Country *': 'దేశం *',
      'Enter Country Name *': 'దేశం పేరు నమోదు చేయండి *',
      'City': 'నగరం',
      'State': 'రాష్ట్రం',
      'District': 'జిల్లా',
      'State / Region *': 'రాష్ట్రం / ప్రాంతం *',
      'District / Area *': 'జిల్లా / ప్రాంతం *',
      'State / Province / Region *': 'రాష్ట్రం / ప్రావిన్స్ / ప్రాంతం *',
      'City / District / Area *': 'నగరం / జిల్లా / ప్రాంతం *',
      'Select State': 'రాష్ట్రం ఎంచుకోండి',
      'Select District': 'జిల్లా ఎంచుకోండి',
      'Select state first': 'ముందుగా రాష్ట్రాన్ని ఎంచుకోండి',
      'Select your state': 'మీ రాష్ట్రాన్ని ఎంచుకోండి',
      'Select your district': 'మీ జిల్లాను ఎంచుకోండి',
      'Enter or select your state / region': 'మీ రాష్ట్రాన్ని నమోదు చేయండి లేదా ఎంచుకోండి',
      'Enter or select your district / city': 'మీ జిల్లాను నమోదు చేయండి లేదా ఎంచుకోండి',
      'Enter your state or province': 'మీ రాష్ట్రాన్ని నమోదు చేయండి',
      'Enter your city or area': 'మీ నగరాన్ని నమోదు చేయండి',
      'Address': 'చిరునామా',
      'Studio address *': 'స్టూడియో చిరునామా *',
      'Street, floor, landmark': 'వీధి, అంతస్తు, ల్యాండ్‌మార్క్',
      'Specialties': 'ప్రత్యేకతలు',
      'Specialties *': 'ప్రత్యేకతలు *',
      'Weddings, portraits, commercial...': 'వివాహాలు, పోర్ట్రెయిట్‌లు, కమర్షియల్...',
      'About': 'స్టూడియో గురించి',
      'About your studio *': 'మీ స్టూడియో గురించి *',
      'Tell clients what makes your studio special': 'మీ స్టూడియో ప్రత్యేకతను క్లయింట్లకు తెలియజేయండి',
      'Save profile': 'ప్రొఫైల్ సేవ్ చేయండి',
      'Profile saved.': 'ప్రొఫైల్ సేవ్ చేయబడింది.',
      'Checking username availability, please wait...': 'యూజర్ పేరు అందుబాటు తనిఖీ చేస్తోంది...',
      'Please choose an available username.': 'దయచేసి అందుబాటులో ఉన్న యూజర్ పేరును ఎంచుకోండి.',
      'Please fix the highlighted fields.': 'దయచేసి హైలైట్ చేసిన ఫీల్డ్‌లను సరిచేయండి.',

      // Photographer Roles & Categories
      'Photographer Roles': 'ఫోటోగ్రాఫర్ పాత్రలు',
      'Photographer Roles & Categories': 'ఫోటోగ్రాఫర్ పాత్రలు & వర్గాలు',
      'Select Roles': 'పాత్రలు ఎంచుకోండి',
      'Edit Roles': 'పాత్రలు సవరించండి',
      'Select Roles & Categories': 'పాత్రలు & వర్గాలను ఎంచుకోండి',
      'Choose the roles and service categories your studio provides': 'మీ స్టూడియో అందించే పాత్రలు మరియు సేవా వర్గాలను ఎంచుకోండి',
      'Select your roles': 'మీ పాత్రలను ఎంచుకోండి',
      'Wedding': 'వివాహం (Wedding)',
      'Pre-wedding': 'ప్రీ-వెడ్డింగ్',
      'Maternity': 'మాతృత్వం (Maternity)',
      'Newborn': 'నవజాత శిశువు (Newborn)',
      'Portrait': 'పోర్ట్రెయిట్',
      'Fashion': 'ఫ్యాషన్',
      'Commercial': 'వాణిజ్య (Commercial)',
      'Event': 'ఈవెంట్',
      'Drone': 'డ్రోన్ ఆపరేటర్',
      'Cinematography': 'సినిమాటోగ్రఫీ',
      'Album Designer': 'ఆల్బమ్ డిజైనర్',
      'Video Editor': 'వీడియో ఎడిటర్',
      'Reels': 'రీల్స్ & షార్ట్స్',
      'Traditional Photo Operator': 'ట్రెడిషనల్ ఫోటో ఆపరేటర్',
      'Traditional Video Operator': 'ట్రెడిషనల్ వీడియో ఆపరేటర్',
      'Candid Photo Operator': 'క్యాండిడ్ ఫోటో ఆపరేటర్',
      'Candid Video Operator': 'క్యాండిడ్ వీడియో ఆపరేటర్',
      'Other': 'ఇతర',
      'Others': 'ఇతరములు',
      'Specify your role / category *': 'మీ పాత్ర / వర్గాన్ని పేర్కొనండి *',
      'e.g. Aerial Photographer, Food Photographer...': 'ఉదా. ఏరియల్ ఫోటోగ్రాఫర్, ఫుడ్ ఫోటోగ్రాఫర్...',
      'Please enter custom category name': 'దయచేసి ప్రత్యేక వర్గం పేరును నమోదు చేయండి',

      // Settings & Account
      'Social & Portfolio': 'సోషల్ & పోర్ట్‌ఫోలియో',
      'Socials (optional)': 'సోషల్స్ (ఐచ్ఛికం)',
      'Payments': 'చెల్లింపులు',
      'Payment QR': 'చెల్లింపు QR',
      'Account Settings': 'ఖాతా సెట్టింగ్‌లు',
      'App Language': 'యాప్ భాష',
      'Choose App Language': 'యాప్ భాషను ఎంచుకోండి',
      'Powered by Google Translate • Auto-translates entire app': 'గూగుల్ ట్రాన్స్‌లేట్ ద్వారా ఆధారితం • యాప్ మొత్తం అనువదించబడుతుంది',
      'Language updated': 'భాష నవీకరించబడింది',
      'Change Password': 'పాస్‌వర్డ్ మార్చండి',
      'Update current login password': 'ప్రస్తుత లాగిన్ పాస్‌వర్డ్‌ను నవీకరించండి',
      'Change Email': 'ఇమెయిల్ మార్చండి',
      'Verify and update your email address': 'మీ ఇమెయిల్ చిరునామాను ధృవీకరించి నవీకరించండి',
      'Delete Account': 'ఖాతా తొలగించండి',
      'Permanently remove account and studio data': 'ఖాతా మరియు స్టూడియో డేటాను శాశ్వతంగా తొలగించండి',
      'Legal': 'చట్టపరమైన సమాచారం',
      'Privacy Policy': 'గోప్యతా విధానం',
      'Terms of Service': 'సేవా నిబంధనలు',
      'App Features & Tour': 'యాప్ ఫీచర్లు & టూర్',
      'Sign out': 'సైన్ అవుట్',
      'Signed out successfully.': 'విజయవంతంగా సైన్ అవుట్ అయ్యారు.',

      // Actions & Common
      'Edit': 'సవరించు',
      'Cancel': 'రద్దు చేయి',
      'Save': 'సేవ్',
      'Done': 'పూర్తయింది',
      'Later': 'తర్వాత',
      'Close': 'మూసివేయి',
      'Back': 'వెనుకకు',
      'Continue': 'కొనసాగించు',
      'Submit': 'సమర్పించు',
      'Search': 'శోధించండి',
      'Filter': 'ఫిల్టర్',
      'Upload QR': 'QR అప్‌లోడ్ చేయండి',
      'Replace': 'మార్చండి',
      'Remove': 'తొలగించు',
      'Delete': 'తొలగించు',
      'Confirm': 'ధృవీకరించండి',

      // Onboarding
      'Set up your studio': 'మీ స్టూడియో సెటప్ చేయండి',
      'Tell us about your photography studio. These details appear on your receipts and profile.': 'మీ ఫోటోగ్రఫీ స్టూడియో గురించి తెలియజేయండి. ఈ వివరాలు రశీదులు మరియు ప్రొఫైల్‌లో కనిపిస్తాయి.',
      'Studio logo (optional)': 'స్టూడియో లోగో (ఐచ్ఛికం)',
      'Save & Enter Studio': 'సేవ్ చేసి స్టూడియో ప్రవేశించండి',
      'Contact & Location': 'సంప్రదింపు & స్థానం',

      // Events
      'Create New Event': 'కొత్త ఈవెంట్ సృష్టించండి',
      'Event Name': 'ఈవెంట్ పేరు',
      'Event Category': 'ఈవెంట్ వర్గం',
      'Select category': 'వర్గాన్ని ఎంచుకోండి',
      'Event Date': 'ఈవెంట్ తేదీ',
      'Client Name': 'క్లయింట్ పేరు',
      'Shoot Budget': 'షూట్ బడ్జెట్',
      'Advance Amount': 'అడ్వాన్స్ మొత్తం',
      'Upcoming Shoots': 'రాబోయే షూట్‌లు',
      'View All': 'అన్నీ చూడండి',
      'Quick Actions': 'త్వరిత చర్యలు',
      'Create Event': 'ఈవెంట్ సృష్టించండి',
      'New Invoice': 'కొత్త ఇన్‌వాయిస్',
      'Add Client': 'క్లయింట్‌ను జోడించండి',
      'Financial Overview': 'ఆర్థిక అవలోకనం',
      'Total Earnings': 'మొత్తం ఆదాయం',
      'Recent Invoices': 'ఇటీవలి ఇన్‌వాయిస్‌లు',
      'Complete Your Profile': 'మీ ప్రొఫైల్ పూర్తి చేయండి',
    },
    'hi': {
      'Home': 'होम',
      'Calendar': 'कैलेंडर',
      'Invoices': 'इनवॉइस',
      'Clients': 'क्लाइंट्स',
      'Discover': 'डिस्कवर',
      'Find Photographers': 'फ़ोटोग्राफ़र खोजें',
      'Studio Profile': 'स्टूडियो प्रोफ़ाइल',
      'Studio Details': 'स्टूडियो विवरण',
      'Studio Name': 'स्टूडियो का नाम',
      'Studio name': 'स्टूडियो का नाम',
      'Studio name *': 'स्टूडियो का नाम *',
      'Owner': 'मालिक',
      'Owner name': 'मालिक का नाम',
      'Owner name *': 'मालिक का नाम *',
      'Username': 'उपयोगकर्ता नाम',
      'Username *': 'उपयोगकर्ता नाम *',
      'Username (Locked)': 'उपयोगकर्ता नाम (लॉक)',
      'Phone': 'फ़ोन नंबर',
      'Phone number': 'फ़ोन नंबर',
      'Mobile number *': 'मोबाइल नंबर *',
      '10-digit mobile number': '10 अंकों का मोबाइल नंबर',
      'Email': 'ईमेल',
      'Email (Read-only)': 'ईमेल (केवल पढ़ने के लिए)',
      'Studio Location': 'स्टूडियो स्थान',
      'Country': 'देश',
      'Country *': 'देश *',
      'Enter Country Name *': 'देश का नाम दर्ज करें *',
      'City': 'शहर',
      'State': 'राज्य',
      'District': 'ज़िला',
      'State / Region *': 'राज्य / क्षेत्र *',
      'District / Area *': 'ज़िला / क्षेत्र *',
      'State / Province / Region *': 'राज्य / प्रांत / क्षेत्र *',
      'City / District / Area *': 'शहर / ज़िला / क्षेत्र *',
      'Select State': 'राज्य चुनें',
      'Select District': 'ज़िला चुनें',
      'Select state first': 'पहले राज्य चुनें',
      'Select your state': 'अपना राज्य चुनें',
      'Select your district': 'अपना ज़िला चुनें',
      'Address': 'पता',
      'Studio address *': 'स्टूडियो का पता *',
      'Specialties': 'विशेषज्ञता',
      'Specialties *': 'विशेषज्ञता *',
      'About': 'स्टूडियो के बारे में',
      'About your studio *': 'अपने स्टूडियो के बारे में *',
      'Save profile': 'प्रोफ़ाइल सहेजें',
      'Profile saved.': 'प्रोफ़ाइल सहेज ली गई।',
      'Photographer Roles': 'फ़ोटोग्राफ़र की भूमिकाएँ',
      'Photographer Roles & Categories': 'फ़ोटोग्राफ़र की भूमिकाएँ और श्रेणियाँ',
      'Select Roles': 'भूमिकाएँ चुनें',
      'Edit Roles': 'भूमिकाएँ बदलें',
      'Wedding': 'विवाह (Wedding)',
      'Pre-wedding': 'प्री-वेडिंग',
      'Maternity': 'मातृत्व (Maternity)',
      'Newborn': 'नवजात (Newborn)',
      'Portrait': 'पोर्ट्रेट',
      'Fashion': 'फ़ैशन',
      'Commercial': 'व्यावसायिक (Commercial)',
      'Event': 'इवेंट',
      'Drone': 'ड्रोन ऑपरेटर',
      'Cinematography': 'सिनेमैटोग्राफी',
      'Album Designer': 'एल्बम डिज़ाइनर',
      'Video Editor': 'वीडियो एडिटर',
      'Reels': 'रील्स और शॉर्ट्स',
      'Traditional Photo Operator': 'ट्रेडिशनल फ़ोटो ऑपरेटर',
      'Traditional Video Operator': 'ट्रेडिशनल वीडियो ऑपरेटर',
      'Candid Photo Operator': 'कैंडिड फ़ोटो ऑपरेटर',
      'Candid Video Operator': 'कैंडिड वीडियो ऑपरेटर',
      'Other': 'अन्य',
      'Others': 'अन्य',
      'Specify your role / category *': 'अपनी भूमिका / श्रेणी निर्दिष्ट करें *',
      'Account Settings': 'खाता सेटिंग्स',
      'App Language': 'ऐप भाषा',
      'Choose App Language': 'ऐप भाषा चुनें',
      'Change Password': 'पासवर्ड बदलें',
      'Change Email': 'ईमेल बदलें',
      'Delete Account': 'खाता हटाएं',
      'Sign out': 'साइन आउट',
      'Edit': 'संपादित करें',
      'Cancel': 'रद्द करें',
      'Save': 'सहेजें',
      'Done': 'पूर्ण',
      'Later': 'बाद में',
      'Create New Event': 'नया इवेंट बनाएं',
      'Event Name': 'इवेंट का नाम',
      'Event Category': 'इवेंट श्रेणी',
      'Set up your studio': 'अपना स्टूडियो सेट करें',
      'Save & Enter Studio': 'सहेजें और स्टूडियो में प्रवेश करें',
    },
    'ta': {
      'Home': 'முகப்பு',
      'Calendar': 'நாட்காட்டி',
      'Invoices': 'விலைப்பட்டியல்கள்',
      'Clients': 'வாடிக்கையாளர்கள்',
      'Discover': 'கண்டுபிடி',
      'Studio Profile': 'ஸ்டுடியோ சுயவிவரம்',
      'Studio Details': 'ஸ்டுடியோ விவரங்கள்',
      'Studio Name': 'ஸ்டுடியோ பெயர்',
      'Owner name': 'உரிமையாளர் பெயர்',
      'Phone': 'தொலைபேசி',
      'Email': 'மின்னஞ்சல்',
      'City': 'நகரம்',
      'State': 'மாநிலம்',
      'District': 'மாவட்டம்',
      'Address': 'முகவரி',
      'Save profile': 'சுயவிவரத்தைச் சேமிக்கவும்',
      'Save': 'சேமிக்க',
      'Cancel': 'ரத்துசெய்',
      'Edit': 'திருத்து',
      'Sign out': 'வெளியேறு',
      'App Language': 'செயலி மொழி',
    },
    'kn': {
      'Home': 'ಮುಖಪುಟ',
      'Calendar': 'ಕ್ಯಾಲೆಂಡರ್',
      'Invoices': 'ಇನ್‌ವಾಯ್ಸ್‌ಗಳು',
      'Clients': 'ಗ್ರಾಹಕರು',
      'Discover': 'ಅನ್ವೇಷಿಸಿ',
      'Studio Profile': 'ಸ್ಟುಡಿಯೋ ಪ್ರೊಫೈಲ್',
      'Studio Details': 'ಸ್ಟುಡಿಯೋ ವಿವರಗಳು',
      'Studio Name': 'ಸ್ಟುಡಿಯೋ ಹೆಸರು',
      'Owner name': 'ಮಾಲೀಕರ ಹೆಸರು',
      'City': 'ನಗರ',
      'State': 'ರಾಜ್ಯ',
      'District': 'ಜಿಲ್ಲೆ',
      'Address': 'ವಿಳಾಸ',
      'Save profile': 'ಪ್ರೊಫೈಲ್ ಉಳಿಸಿ',
      'Save': 'ಉಳಿಸಿ',
      'Cancel': 'ರದ್ದುಮಾಡಿ',
      'Edit': 'ತಿದ್ದು',
      'Sign out': 'ಸೈನ್ ಔಟ್',
      'App Language': 'ಅಪ್ಲಿಕೇಶನ್ ಭಾಷೆ',
    },
    'es': {
      'Home': 'Inicio',
      'Calendar': 'Calendario',
      'Invoices': 'Facturas',
      'Clients': 'Clientes',
      'Discover': 'Descubrir',
      'Studio Profile': 'Perfil del Estudio',
      'Studio Details': 'Detalles del Estudio',
      'Studio Name': 'Nombre del Estudio',
      'Owner name': 'Nombre del Propietario',
      'City': 'Ciudad',
      'State': 'Estado',
      'District': 'Distrito',
      'Address': 'Dirección',
      'Save profile': 'Guardar Perfil',
      'Save': 'Guardar',
      'Cancel': 'Cancelar',
      'Edit': 'Editar',
      'Sign out': 'Cerrar sesión',
      'App Language': 'Idioma de la App',
    },
  };

  /// Initializes persisted translations from SharedPreferences and merges default dictionaries.
  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('tr_cache_'));
      for (final key in keys) {
        final lang = key.replaceFirst('tr_cache_', '');
        final jsonStr = prefs.getString(key);
        if (jsonStr != null) {
          final map = Map<String, String>.from(jsonDecode(jsonStr) as Map);
          _memoryCache[lang] = map;
        }
      }
      // Populate defaults
      _initialDictionary.forEach((lang, dict) {
        _memoryCache.putIfAbsent(lang, () => {});
        dict.forEach((src, tr) {
          _memoryCache[lang]!.putIfAbsent(src.trim(), () => tr);
        });
      });
      _initialized = true;
    } catch (_) {
      _initialized = true;
    }
  }

  /// Synchronously returns cached translation or original text.
  String getCached(String text, String targetLang) {
    if (targetLang == 'en') return text;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    final dict = _memoryCache[targetLang];
    if (dict != null) {
      if (dict.containsKey(trimmed)) return dict[trimmed]!;
      if (dict.containsKey(text)) return dict[text]!;
    }

    final initialDict = _initialDictionary[targetLang];
    if (initialDict != null) {
      if (initialDict.containsKey(trimmed)) return initialDict[trimmed]!;
      if (initialDict.containsKey(text)) return initialDict[text]!;
    }

    return text;
  }

  /// Translates text using Google Translate endpoint with automatic retry & fallback.
  Future<String> translate(String text, {required String targetLang}) async {
    if (targetLang == 'en') return text;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return text;

    final cached = getCached(trimmed, targetLang);
    if (cached != trimmed) return cached;

    const headers = {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      'Accept': '*/*',
    };

    // Primary Google Translate endpoint
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(trimmed)}',
      );
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty && data[0] is List) {
          final buffer = StringBuffer();
          for (final part in data[0]) {
            if (part is List && part.isNotEmpty && part[0] != null) {
              buffer.write(part[0]);
            }
          }
          final result = buffer.toString().trim();
          if (result.isNotEmpty) {
            _saveToCache(trimmed, result, targetLang);
            return result;
          }
        }
      }
    } catch (_) {}

    // Secondary Google Translate fallback endpoint
    try {
      final fallbackUri = Uri.parse(
        'https://clients5.google.com/translate_a/t?client=dict-chrome-ex&sl=auto&tl=$targetLang&q=${Uri.encodeComponent(trimmed)}',
      );
      final response = await http
          .get(fallbackUri, headers: headers)
          .timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final first = data[0];
          if (first is String && first.trim().isNotEmpty) {
            final result = first.trim();
            _saveToCache(trimmed, result, targetLang);
            return result;
          }
        }
      }
    } catch (_) {}

    return text;
  }

  void _saveToCache(String text, String translated, String targetLang) {
    _memoryCache.putIfAbsent(targetLang, () => {})[text] = translated;
    _memoryCache[targetLang]![text.trim()] = translated;

    // Persist to SharedPreferences in background
    SharedPreferences.getInstance().then((prefs) {
      final jsonStr = jsonEncode(_memoryCache[targetLang]);
      prefs.setString('tr_cache_$targetLang', jsonStr);
    }).catchError((_) {});
  }
}
