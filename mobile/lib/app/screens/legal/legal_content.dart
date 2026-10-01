enum LegalDocument { privacy, terms }

class LegalSection {
  const LegalSection(this.title, {this.body, this.points = const []});

  final String title;
  final String? body;
  final List<String> points;
}

class LegalContent {
  const LegalContent._();

  static const appName = 'Clients Hub';
  static const contactEmail = 'istudio2512@gmail.com';
  static const lastUpdated = '2 October 2026';

  static String title(LegalDocument doc) => switch (doc) {
    LegalDocument.privacy => 'Privacy Policy',
    LegalDocument.terms => 'Terms & Conditions',
  };

  static String intro(LegalDocument doc) => switch (doc) {
    LegalDocument.privacy =>
      '$appName helps photographers and studios manage clients, shoots, '
          'payments and invoices. This policy explains what information we '
          'collect, why we collect it and the choices you have.',
    LegalDocument.terms =>
      'These terms govern your use of $appName. By creating an account or '
          'using the app, you agree to them. If you do not agree, please do '
          'not use the app.',
  };

  static List<LegalSection> sections(LegalDocument doc) => switch (doc) {
    LegalDocument.privacy => _privacy,
    LegalDocument.terms => _terms,
  };

  static const _privacy = [
    LegalSection(
      'Information you give us',
      points: [
        'Account details: username, email address, phone number and password '
            '(stored only in encrypted, hashed form).',
        'Google sign-in: your name, email and profile picture, if you choose '
            'to sign in with Google.',
        'Studio profile: studio and owner name, address, city, specialties, '
            'logo, social links, UPI ID and payment QR code.',
        'Business records you add: clients, shoots and events, deliverables, '
            'payments, payment proofs, expenses, estimates and invoices.',
      ],
    ),
    LegalSection(
      'Information about your clients',
      body:
          'When you add a client, you store their name, phone number, address '
          'and shoot details in $appName. You are responsible for having your '
          'clients\' permission to store and use this information. We process '
          'it only to provide the app to you and never contact your clients '
          'for our own purposes.',
    ),
    LegalSection(
      'Photos and files',
      body:
          'Images you upload, such as your studio logo, payment QR code and '
          'payment proof screenshots, are stored securely with our cloud image '
          'provider. $appName does not access your phone\'s gallery or camera '
          'unless you choose a photo to upload, and we never scan, sell or use '
          'your images for advertising or AI training.',
    ),
    LegalSection(
      'How we use information',
      points: [
        'To create and secure your account, including email verification '
            'codes and password resets.',
        'To show your schedule, clients, payments and reports in the app.',
        'To generate invoices and receipts with your studio branding.',
        'To send reminders and notifications related to your shoots.',
        'To fix problems, prevent misuse and improve the app.',
      ],
    ),
    LegalSection(
      'Sharing',
      body:
          'We do not sell your personal information or your clients\' '
          'information. We share data only with service providers that help '
          'run the app (cloud hosting, database, image storage, email delivery '
          'and Google sign-in), only as needed to provide those services, or '
          'when required by law. Invoices and receipts are shared only when '
          'you choose to share them.',
    ),
    LegalSection(
      'Storage and security',
      body:
          'Your data is stored on secure servers and sent over encrypted '
          '(HTTPS) connections. Your sign-in session is kept in secure storage '
          'on your device. No system is completely secure, so please keep your '
          'password private and sign out on shared devices.',
    ),
    LegalSection(
      'Retention and deletion',
      body:
          'We keep your data while your account is active. You can edit or '
          'delete clients, events, payments and invoices at any time. You can '
          'permanently delete your account from Profile > Account Settings > '
          'Delete Account, which removes your account and studio data from our '
          'active systems. Backups are cleared within a reasonable period.',
    ),
    LegalSection(
      'Your rights',
      body:
          'You can access, correct or delete your information from within the '
          'app, or contact us for help. Where applicable law, including '
          'India\'s Digital Personal Data Protection Act, 2023, gives you '
          'additional rights, we will honour them.',
    ),
    LegalSection(
      'Children',
      body:
          '$appName is a business tool meant for people aged 18 and over. We '
          'do not knowingly collect information from children.',
    ),
    LegalSection(
      'Changes to this policy',
      body:
          'We may update this policy from time to time. When we make important '
          'changes, we will let you know in the app. The date at the top shows '
          'when it was last updated.',
    ),
    LegalSection(
      'Contact us',
      body: 'For privacy questions or requests, email us at $contactEmail.',
    ),
  ];

  static const _terms = [
    LegalSection(
      'Using $appName',
      body:
          '$appName is a studio management tool for photographers and '
          'videographers to manage clients, shoots, deliverables, payments, '
          'expenses and invoices. You must be at least 18 years old and able '
          'to enter into a binding agreement to use it.',
    ),
    LegalSection(
      'Your account',
      points: [
        'Provide accurate information and keep it up to date.',
        'Keep your password secure. You are responsible for all activity on '
            'your account.',
        'Tell us right away if you suspect unauthorised access.',
      ],
    ),
    LegalSection(
      'Your content and data',
      body:
          'You own everything you add to $appName, including client details, '
          'event records, logos and payment proofs. You give us permission to '
          'store and process this content only to run the app for you. You '
          'confirm that you have the right to upload it and that you have your '
          'clients\' consent to store their details.',
    ),
    LegalSection(
      'Acceptable use',
      body: 'You agree not to:',
      points: [
        'Use the app for anything illegal, fraudulent or misleading.',
        'Upload content you do not have rights to, or that is offensive or '
            'harmful.',
        'Send spam or unwanted messages to clients through the app.',
        'Try to break, overload, reverse engineer or gain unauthorised access '
            'to the app or its servers.',
      ],
    ),
    LegalSection(
      'Invoices, payments and records',
      body:
          '$appName helps you prepare invoices, receipts and payment records, '
          'but it does not process payments or hold money. Payments happen '
          'directly between you and your clients through UPI, cash, bank '
          'transfer or other methods. You are responsible for the accuracy of '
          'your invoices, pricing and records, and for meeting your own tax '
          'and GST obligations.',
    ),
    LegalSection(
      'Your client relationships',
      body:
          'Bookings, contracts, deliverables, refunds and disputes are between '
          'you and your clients. $appName is not a party to these agreements '
          'and is not responsible for them.',
    ),
    LegalSection(
      'Availability',
      body:
          'We work to keep $appName running smoothly, but we cannot promise it '
          'will always be available or error free. We may update, change or '
          'discontinue features. Please keep your own copies of important '
          'invoices and records.',
    ),
    LegalSection(
      'Our app',
      body:
          'The $appName name, design and software belong to us. These terms do '
          'not give you any rights to them other than to use the app as '
          'intended.',
    ),
    LegalSection(
      'Ending your account',
      body:
          'You can stop using $appName and delete your account at any time '
          'from Profile > Account Settings. We may suspend or close accounts '
          'that break these terms or put other users or the service at risk.',
    ),
    LegalSection(
      'Disclaimer and liability',
      body:
          '$appName is provided "as is". To the fullest extent allowed by law, '
          'we are not liable for indirect or consequential losses, such as '
          'lost bookings, income or data, arising from your use of the app.',
    ),
    LegalSection(
      'Governing law',
      body:
          'These terms are governed by the laws of India. Any disputes will be '
          'handled by the courts of India.',
    ),
    LegalSection(
      'Changes to these terms',
      body:
          'We may update these terms from time to time. Continuing to use the '
          'app after an update means you accept the new terms.',
    ),
    LegalSection(
      'Contact us',
      body: 'Questions about these terms? Email us at $contactEmail.',
    ),
  ];
}
