import 'package:flutter/material.dart';

/// Delegate untuk AppLocalizations
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['id', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Class utama untuk lokalisasi aplikasi
/// Mendukung Bahasa Indonesia (id) dan English (en)
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// Helper method untuk mendapatkan instance dari BuildContext
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en', 'US'));
  }

  /// Delegate untuk digunakan di MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  /// Map untuk menyimpan semua string terjemahan
  static final Map<String, Map<String, String>> _localizedStrings = {
    'id': _idStrings,
    'en': _enStrings,
  };

  /// Mendapatkan string berdasarkan key
  String translate(String key) {
    return _localizedStrings[locale.languageCode]?[key] ??
        _localizedStrings['en']?[key] ??
        key;
  }

  // ============================================
  // GENERAL APP STRINGS
  // ============================================
  String get appName => translate('appName');
  String get appTagline => translate('appTagline');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get cancel => translate('cancel');
  String get confirm => translate('confirm');
  String get save => translate('save');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get close => translate('close');
  String get back => translate('back');
  String get next => translate('next');
  String get done => translate('done');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
  String get on => translate('on');
  String get off => translate('off');
  String get left => translate('left');
  String get right => translate('right');
  String get seeAll => translate('seeAll');

  // ============================================
  // AUTHENTICATION STRINGS
  // ============================================
  String get welcomeBack => translate('welcomeBack');
  String get signInToContinue => translate('signInToContinue');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get fullName => translate('fullName');
  String get forgotPassword => translate('forgotPassword');
  String get signIn => translate('signIn');
  String get signUp => translate('signUp');
  String get signOut => translate('signOut');
  String get logout => translate('logout');
  String get createAccount => translate('createAccount');
  String get joinSuperApp => translate('joinSuperApp');
  String get createAccountDesc => translate('createAccountDesc');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get orContinueWith => translate('orContinueWith');
  String get continueWithGoogle => translate('continueWithGoogle');
  String get agreeToTerms => translate('agreeToTerms');
  String get termsOfService => translate('termsOfService');
  String get and => translate('and');
  String get privacyPolicy => translate('privacyPolicy');

  // ============================================
  // VALIDATION STRINGS
  // ============================================
  String get pleaseEnterEmail => translate('pleaseEnterEmail');
  String get pleaseEnterValidEmail => translate('pleaseEnterValidEmail');
  String get pleaseEnterPassword => translate('pleaseEnterPassword');
  String get passwordMinLength => translate('passwordMinLength');
  String get pleaseConfirmPassword => translate('pleaseConfirmPassword');
  String get passwordsDoNotMatch => translate('passwordsDoNotMatch');
  String get pleaseEnterName => translate('pleaseEnterName');
  String get loginFailed => translate('loginFailed');
  String get googleLoginFailed => translate('googleLoginFailed');
  String get registrationFailed => translate('registrationFailed');
  String get accountCreatedSuccess => translate('accountCreatedSuccess');

  // ============================================
  // NAVIGATION STRINGS
  // ============================================
  String get home => translate('home');
  String get explore => translate('explore');
  String get scan => translate('scan');
  String get activity => translate('activity');
  String get profile => translate('profile');
  String get dashboard => translate('dashboard');
  String get menu => translate('menu');
  String get notifications => translate('notifications');
  String get history => translate('history');
  String get favorites => translate('favorites');
  String get saved => translate('saved');
  String get settings => translate('settings');
  String get helpAndSupport => translate('helpAndSupport');
  String get viewProfile => translate('viewProfile');

  // ============================================
  // DASHBOARD STRINGS
  // ============================================
  String get quickActions => translate('quickActions');
  String get latestNews => translate('latestNews');
  String get recommendedForYou => translate('recommendedForYou');
  String get noNewNotifications => translate('noNewNotifications');
  String get chatSupport => translate('chatSupport');
  String get discoverNewServices => translate('discoverNewServices');
  String get viewRecentTransactions => translate('viewRecentTransactions');
  String get guestUser => translate('guestUser');
  String get pleaseLoginToContinue => translate('pleaseLoginToContinue');
  String get editProfile => translate('editProfile');

  // ============================================
  // SCAN & PAY STRINGS
  // ============================================
  String get scanAndPay => translate('scanAndPay');
  String get scanQr => translate('scanQr');
  String get takePhoto => translate('takePhoto');
  String get upload => translate('upload');

  // ============================================
  // SETTINGS STRINGS
  // ============================================
  String get appearance => translate('appearance');
  String get themeTemplate => translate('themeTemplate');
  String get darkMode => translate('darkMode');
  String get languageAndRegion => translate('languageAndRegion');
  String get language => translate('language');
  String get layout => translate('layout');
  String get sidebarPosition => translate('sidebarPosition');
  String get authentication => translate('authentication');
  String get authProvider => translate('authProvider');
  String get about => translate('about');
  String get appVersion => translate('appVersion');
  String get buildNumber => translate('buildNumber');
  String get selectTheme => translate('selectTheme');
  String get selectLanguage => translate('selectLanguage');
  String get bahasaIndonesia => translate('bahasaIndonesia');
  String get english => translate('english');
  String get firebaseAuth => translate('firebaseAuth');
  String get customApi => translate('customApi');
  String get useFirebaseAuth => translate('useFirebaseAuth');
  String get useCustomApi => translate('useCustomApi');

  // ============================================
  // THEME TEMPLATE NAMES
  // ============================================
  String get defaultBlue => translate('defaultBlue');
  String get modernPurple => translate('modernPurple');
  String get elegantGreen => translate('elegantGreen');
  String get warmOrange => translate('warmOrange');
  String get darkModeTheme => translate('darkModeTheme');

  // ============================================
  // HELP & SUPPORT STRINGS
  // ============================================
  String get searchHelpArticles => translate('searchHelpArticles');
  String get quickHelp => translate('quickHelp');
  String get accountAndProfile => translate('accountAndProfile');
  String get manageAccountSettings => translate('manageAccountSettings');
  String get paymentsAndTransactions => translate('paymentsAndTransactions');
  String get paymentMethodsHistory => translate('paymentMethodsHistory');
  String get securityAndPrivacy => translate('securityAndPrivacy');
  String get accountSecurityPrivacy => translate('accountSecurityPrivacy');
  String get usingTheApp => translate('usingTheApp');
  String get featuresNavigationTips => translate('featuresNavigationTips');
  String get contactUs => translate('contactUs');
  String get liveChat => translate('liveChat');
  String get chatWithSupport => translate('chatWithSupport');
  String get emailSupport => translate('emailSupport');
  String get callCenter => translate('callCenter');
  String get reportAnIssue => translate('reportAnIssue');
  String get havingTrouble => translate('havingTrouble');
  String get reportIssueDesc => translate('reportIssueDesc');
  String get faq => translate('faq');
  String get howToResetPassword => translate('howToResetPassword');
  String get resetPasswordAnswer => translate('resetPasswordAnswer');
  String get howToUpdateProfile => translate('howToUpdateProfile');
  String get updateProfileAnswer => translate('updateProfileAnswer');
  String get howToContactSupport => translate('howToContactSupport');
  String get contactSupportAnswer => translate('contactSupportAnswer');
  String get describeYourIssue => translate('describeYourIssue');
  String get submit => translate('submit');
  String get reportSubmittedThankYou => translate('reportSubmittedThankYou');

  // ============================================
  // SIDEBAR MENU STRINGS
  // ============================================
  String get menuLabel => translate('menuLabel');
  String get activityLabel => translate('activityLabel');
  String get settingsLabel => translate('settingsLabel');

  // ============================================
  // MENU GRID ITEMS
  // ============================================
  String get payment => translate('payment');
  String get transfer => translate('transfer');
  String get topUp => translate('topUp');
  String get bills => translate('bills');
  String get shopping => translate('shopping');
  String get food => translate('food');
  String get transport => translate('transport');
  String get more => translate('more');

  // ============================================
  // ARTICLE/BANNER SAMPLE TEXTS
  // ============================================
  String get promoTitle1 => translate('promoTitle1');
  String get promoSubtitle1 => translate('promoSubtitle1');
  String get promoTitle2 => translate('promoTitle2');
  String get promoSubtitle2 => translate('promoSubtitle2');
  String get promoTitle3 => translate('promoTitle3');
  String get promoSubtitle3 => translate('promoSubtitle3');
  String get articleTitle1 => translate('articleTitle1');
  String get articleDesc1 => translate('articleDesc1');
  String get articleTitle2 => translate('articleTitle2');
  String get articleDesc2 => translate('articleDesc2');
  String get articleTitle3 => translate('articleTitle3');
  String get articleDesc3 => translate('articleDesc3');

  // ============================================
  // TERMS OF SERVICE & PRIVACY STRINGS
  // ============================================
  String get tosTitle => translate('tosTitle');
  String get tosLastUpdated => translate('tosLastUpdated');
  String get tosIntro => translate('tosIntro');
  String get privacyTitle => translate('privacyTitle');
  String get privacyLastUpdated => translate('privacyLastUpdated');
  String get privacyIntro => translate('privacyIntro');

  // ============================================
  // PROFILE STRINGS
  // ============================================
  String get personalInfo => translate('personalInfo');
  String get phone => translate('phone');
  String get dateOfBirth => translate('dateOfBirth');
  String get gender => translate('gender');
  String get address => translate('address');
  String get accountSettings => translate('accountSettings');
  String get changePassword => translate('changePassword');
  String get notificationSettings => translate('notificationSettings');
  String get linkedAccounts => translate('linkedAccounts');
  String get accountInformation => translate('accountInformation');
  String get emailVerified => translate('emailVerified');
  String get notSet => translate('notSet');
  String get notLoggedIn => translate('notLoggedIn');
  String get privacyAndSecurity => translate('privacyAndSecurity');
  String get dangerZone => translate('dangerZone');
  String get deleteAccount => translate('deleteAccount');
  String get deleteAccountConfirm => translate('deleteAccountConfirm');
  String get accountDeletionRequested => translate('accountDeletionRequested');
}

// ============================================
// BAHASA INDONESIA STRINGS
// ============================================
const Map<String, String> _idStrings = {
  // General
  'appName': 'Super App',
  'appTagline': 'Solusi All-in-One Anda',
  'loading': 'Memuat...',
  'error': 'Kesalahan',
  'success': 'Berhasil',
  'cancel': 'Batal',
  'confirm': 'Konfirmasi',
  'save': 'Simpan',
  'delete': 'Hapus',
  'edit': 'Edit',
  'close': 'Tutup',
  'back': 'Kembali',
  'next': 'Selanjutnya',
  'done': 'Selesai',
  'ok': 'OK',
  'yes': 'Ya',
  'no': 'Tidak',
  'on': 'Aktif',
  'off': 'Nonaktif',
  'left': 'Kiri',
  'right': 'Kanan',
  'seeAll': 'Lihat Semua',

  // Authentication
  'welcomeBack': 'Selamat Datang Kembali',
  'signInToContinue': 'Masuk untuk melanjutkan ke Super App',
  'email': 'Email',
  'password': 'Kata Sandi',
  'confirmPassword': 'Konfirmasi Kata Sandi',
  'fullName': 'Nama Lengkap',
  'forgotPassword': 'Lupa Kata Sandi?',
  'signIn': 'Masuk',
  'signUp': 'Daftar',
  'signOut': 'Keluar',
  'logout': 'Keluar',
  'createAccount': 'Buat Akun',
  'joinSuperApp': 'Bergabung dengan Super App',
  'createAccountDesc': 'Buat akun untuk memulai',
  'dontHaveAccount': 'Belum punya akun?',
  'alreadyHaveAccount': 'Sudah punya akun?',
  'orContinueWith': 'atau lanjutkan dengan',
  'continueWithGoogle': 'Lanjutkan dengan Google',
  'agreeToTerms': 'Saya setuju dengan ',
  'termsOfService': 'Ketentuan Layanan',
  'and': ' dan ',
  'privacyPolicy': 'Kebijakan Privasi',

  // Validation
  'pleaseEnterEmail': 'Silakan masukkan email Anda',
  'pleaseEnterValidEmail': 'Silakan masukkan email yang valid',
  'pleaseEnterPassword': 'Silakan masukkan kata sandi Anda',
  'passwordMinLength': 'Kata sandi minimal 6 karakter',
  'pleaseConfirmPassword': 'Silakan konfirmasi kata sandi Anda',
  'passwordsDoNotMatch': 'Kata sandi tidak cocok',
  'pleaseEnterName': 'Silakan masukkan nama Anda',
  'loginFailed': 'Login gagal',
  'googleLoginFailed': 'Login Google gagal',
  'registrationFailed': 'Pendaftaran gagal',
  'accountCreatedSuccess': 'Akun berhasil dibuat!',

  // Navigation
  'home': 'Beranda',
  'explore': 'Jelajahi',
  'scan': 'Scan',
  'activity': 'Aktivitas',
  'profile': 'Profil',
  'dashboard': 'Dashboard',
  'menu': 'Menu',
  'notifications': 'Notifikasi',
  'history': 'Riwayat',
  'favorites': 'Favorit',
  'saved': 'Tersimpan',
  'settings': 'Pengaturan',
  'helpAndSupport': 'Bantuan & Dukungan',
  'viewProfile': 'Lihat Profil',

  // Dashboard
  'quickActions': 'Aksi Cepat',
  'latestNews': 'Berita Terbaru',
  'recommendedForYou': 'Rekomendasi untuk Anda',
  'noNewNotifications': 'Tidak ada notifikasi baru',
  'chatSupport': 'Bantuan Chat',
  'discoverNewServices': 'Temukan layanan dan fitur baru',
  'viewRecentTransactions': 'Lihat transaksi terbaru Anda',
  'guestUser': 'Pengguna Tamu',
  'pleaseLoginToContinue': 'Silakan masuk untuk melanjutkan',
  'editProfile': 'Edit Profil',

  // Scan & Pay
  'scanAndPay': 'Scan & Bayar',
  'scanQr': 'Scan QR',
  'takePhoto': 'Ambil Foto',
  'upload': 'Unggah',

  // Settings
  'appearance': 'Tampilan',
  'themeTemplate': 'Template Tema',
  'darkMode': 'Mode Gelap',
  'languageAndRegion': 'Bahasa & Wilayah',
  'language': 'Bahasa',
  'layout': 'Tata Letak',
  'sidebarPosition': 'Posisi Sidebar',
  'authentication': 'Autentikasi',
  'authProvider': 'Penyedia Auth',
  'about': 'Tentang',
  'appVersion': 'Versi Aplikasi',
  'buildNumber': 'Nomor Build',
  'selectTheme': 'Pilih Tema',
  'selectLanguage': 'Pilih Bahasa',
  'bahasaIndonesia': 'Bahasa Indonesia',
  'english': 'English',
  'firebaseAuth': 'Firebase Auth',
  'customApi': 'Custom API',
  'useFirebaseAuth': 'Gunakan Firebase Authentication',
  'useCustomApi': 'Gunakan custom backend API',

  // Theme Templates
  'defaultBlue': 'Biru Default',
  'modernPurple': 'Ungu Modern',
  'elegantGreen': 'Hijau Elegan',
  'warmOrange': 'Oranye Hangat',
  'darkModeTheme': 'Mode Gelap',

  // Help & Support
  'searchHelpArticles': 'Cari artikel bantuan...',
  'quickHelp': 'Bantuan Cepat',
  'accountAndProfile': 'Akun & Profil',
  'manageAccountSettings': 'Kelola pengaturan akun Anda',
  'paymentsAndTransactions': 'Pembayaran & Transaksi',
  'paymentMethodsHistory': 'Metode pembayaran, riwayat, pengembalian',
  'securityAndPrivacy': 'Keamanan & Privasi',
  'accountSecurityPrivacy': 'Keamanan akun, pengaturan privasi',
  'usingTheApp': 'Menggunakan Aplikasi',
  'featuresNavigationTips': 'Fitur, navigasi, tips',
  'contactUs': 'Hubungi Kami',
  'liveChat': 'Live Chat',
  'chatWithSupport': 'Chat dengan tim support kami',
  'emailSupport': 'Dukungan Email',
  'callCenter': 'Call Center',
  'reportAnIssue': 'Laporkan Masalah',
  'havingTrouble': 'Mengalami masalah?',
  'reportIssueDesc': 'Beritahu kami tentang masalah yang Anda alami. Kami akan menghubungi Anda sesegera mungkin.',
  'faq': 'Pertanyaan yang Sering Diajukan',
  'howToResetPassword': 'Bagaimana cara reset kata sandi?',
  'resetPasswordAnswer': 'Anda dapat mereset kata sandi dengan pergi ke Pengaturan > Akun > Ubah Kata Sandi, atau gunakan opsi "Lupa Kata Sandi" di halaman login.',
  'howToUpdateProfile': 'Bagaimana cara memperbarui profil?',
  'updateProfileAnswer': 'Pergi ke Profil > Edit Profil untuk memperbarui informasi pribadi, foto profil, dan detail lainnya.',
  'howToContactSupport': 'Bagaimana cara menghubungi customer support?',
  'contactSupportAnswer': 'Anda dapat menghubungi kami melalui Live Chat, Email, atau Call Center. Cek bagian "Hubungi Kami" di atas untuk detailnya.',
  'describeYourIssue': 'Jelaskan masalah yang Anda alami...',
  'submit': 'Kirim',
  'reportSubmittedThankYou': 'Laporan terkirim. Terima kasih!',

  // Sidebar
  'menuLabel': 'Menu',
  'activityLabel': 'Aktivitas',
  'settingsLabel': 'Pengaturan',

  // Menu Grid
  'payment': 'Pembayaran',
  'transfer': 'Transfer',
  'topUp': 'Isi Ulang',
  'bills': 'Tagihan',
  'shopping': 'Belanja',
  'food': 'Makanan',
  'transport': 'Transportasi',
  'more': 'Lainnya',

  // Banners & Articles
  'promoTitle1': 'Promo Spesial',
  'promoSubtitle1': 'Diskon hingga 50% untuk pengguna baru',
  'promoTitle2': 'Transfer Gratis',
  'promoSubtitle2': 'Biaya transfer 0% selama bulan ini',
  'promoTitle3': 'Cashback Belanja',
  'promoSubtitle3': 'Dapatkan cashback 20% untuk belanja',
  'articleTitle1': 'Tips Mengelola Keuangan',
  'articleDesc1': 'Pelajari cara mengelola keuangan Anda dengan bijak',
  'articleTitle2': 'Fitur Baru di Super App',
  'articleDesc2': 'Temukan fitur-fitur terbaru yang memudahkan Anda',
  'articleTitle3': 'Keamanan Transaksi Digital',
  'articleDesc3': 'Tips menjaga keamanan saat bertransaksi digital',

  // TOS & Privacy
  'tosTitle': 'Ketentuan Layanan',
  'tosLastUpdated': 'Terakhir diperbarui',
  'tosIntro': 'Selamat datang di Super App. Dengan menggunakan aplikasi ini, Anda setuju untuk mematuhi ketentuan berikut.',
  'privacyTitle': 'Kebijakan Privasi',
  'privacyLastUpdated': 'Terakhir diperbarui',
  'privacyIntro': 'Privasi Anda penting bagi kami. Kebijakan ini menjelaskan bagaimana kami mengumpulkan dan menggunakan data Anda.',

  // Profile
  'personalInfo': 'Informasi Pribadi',
  'phone': 'Telepon',
  'dateOfBirth': 'Tanggal Lahir',
  'gender': 'Jenis Kelamin',
  'address': 'Alamat',
  'accountSettings': 'Pengaturan Akun',
  'changePassword': 'Ubah Kata Sandi',
  'notificationSettings': 'Pengaturan Notifikasi',
  'linkedAccounts': 'Akun Tertaut',
  'accountInformation': 'Informasi Akun',
  'emailVerified': 'Email Terverifikasi',
  'notSet': 'Belum diatur',
  'notLoggedIn': 'Belum masuk',
  'privacyAndSecurity': 'Privasi & Keamanan',
  'dangerZone': 'Zona Berbahaya',
  'deleteAccount': 'Hapus Akun',
  'deleteAccountConfirm': 'Apakah Anda yakin ingin menghapus akun? Tindakan ini tidak dapat dibatalkan.',
  'accountDeletionRequested': 'Permintaan penghapusan akun terkirim',
};

// ============================================
// ENGLISH STRINGS
// ============================================
const Map<String, String> _enStrings = {
  // General
  'appName': 'Super App',
  'appTagline': 'Your All-in-One Solution',
  'loading': 'Loading...',
  'error': 'Error',
  'success': 'Success',
  'cancel': 'Cancel',
  'confirm': 'Confirm',
  'save': 'Save',
  'delete': 'Delete',
  'edit': 'Edit',
  'close': 'Close',
  'back': 'Back',
  'next': 'Next',
  'done': 'Done',
  'ok': 'OK',
  'yes': 'Yes',
  'no': 'No',
  'on': 'On',
  'off': 'Off',
  'left': 'Left',
  'right': 'Right',
  'seeAll': 'See All',

  // Authentication
  'welcomeBack': 'Welcome Back',
  'signInToContinue': 'Sign in to continue to Super App',
  'email': 'Email',
  'password': 'Password',
  'confirmPassword': 'Confirm Password',
  'fullName': 'Full Name',
  'forgotPassword': 'Forgot Password?',
  'signIn': 'Sign In',
  'signUp': 'Sign Up',
  'signOut': 'Sign Out',
  'logout': 'Logout',
  'createAccount': 'Create Account',
  'joinSuperApp': 'Join Super App',
  'createAccountDesc': 'Create an account to get started',
  'dontHaveAccount': "Don't have an account?",
  'alreadyHaveAccount': 'Already have an account?',
  'orContinueWith': 'or continue with',
  'continueWithGoogle': 'Continue with Google',
  'agreeToTerms': 'I agree to the ',
  'termsOfService': 'Terms of Service',
  'and': ' and ',
  'privacyPolicy': 'Privacy Policy',

  // Validation
  'pleaseEnterEmail': 'Please enter your email',
  'pleaseEnterValidEmail': 'Please enter a valid email',
  'pleaseEnterPassword': 'Please enter your password',
  'passwordMinLength': 'Password must be at least 6 characters',
  'pleaseConfirmPassword': 'Please confirm your password',
  'passwordsDoNotMatch': 'Passwords do not match',
  'pleaseEnterName': 'Please enter your name',
  'loginFailed': 'Login failed',
  'googleLoginFailed': 'Google login failed',
  'registrationFailed': 'Registration failed',
  'accountCreatedSuccess': 'Account created successfully!',

  // Navigation
  'home': 'Home',
  'explore': 'Explore',
  'scan': 'Scan',
  'activity': 'Activity',
  'profile': 'Profile',
  'dashboard': 'Dashboard',
  'menu': 'Menu',
  'notifications': 'Notifications',
  'history': 'History',
  'favorites': 'Favorites',
  'saved': 'Saved',
  'settings': 'Settings',
  'helpAndSupport': 'Help & Support',
  'viewProfile': 'View Profile',

  // Dashboard
  'quickActions': 'Quick Actions',
  'latestNews': 'Latest News',
  'recommendedForYou': 'Recommended for You',
  'noNewNotifications': 'No new notifications',
  'chatSupport': 'Chat support',
  'discoverNewServices': 'Discover new services and features',
  'viewRecentTransactions': 'View your recent transactions',
  'guestUser': 'Guest User',
  'pleaseLoginToContinue': 'Please login to continue',
  'editProfile': 'Edit Profile',

  // Scan & Pay
  'scanAndPay': 'Scan & Pay',
  'scanQr': 'Scan QR',
  'takePhoto': 'Take Photo',
  'upload': 'Upload',

  // Settings
  'appearance': 'Appearance',
  'themeTemplate': 'Theme Template',
  'darkMode': 'Dark Mode',
  'languageAndRegion': 'Language & Region',
  'language': 'Language',
  'layout': 'Layout',
  'sidebarPosition': 'Sidebar Position',
  'authentication': 'Authentication',
  'authProvider': 'Auth Provider',
  'about': 'About',
  'appVersion': 'App Version',
  'buildNumber': 'Build Number',
  'selectTheme': 'Select Theme',
  'selectLanguage': 'Select Language',
  'bahasaIndonesia': 'Bahasa Indonesia',
  'english': 'English',
  'firebaseAuth': 'Firebase Auth',
  'customApi': 'Custom API',
  'useFirebaseAuth': 'Use Firebase Authentication',
  'useCustomApi': 'Use custom backend API',

  // Theme Templates
  'defaultBlue': 'Default Blue',
  'modernPurple': 'Modern Purple',
  'elegantGreen': 'Elegant Green',
  'warmOrange': 'Warm Orange',
  'darkModeTheme': 'Dark Mode',

  // Help & Support
  'searchHelpArticles': 'Search help articles...',
  'quickHelp': 'Quick Help',
  'accountAndProfile': 'Account & Profile',
  'manageAccountSettings': 'Manage your account settings',
  'paymentsAndTransactions': 'Payments & Transactions',
  'paymentMethodsHistory': 'Payment methods, history, refunds',
  'securityAndPrivacy': 'Security & Privacy',
  'accountSecurityPrivacy': 'Account security, privacy settings',
  'usingTheApp': 'Using the App',
  'featuresNavigationTips': 'Features, navigation, tips',
  'contactUs': 'Contact Us',
  'liveChat': 'Live Chat',
  'chatWithSupport': 'Chat with our support team',
  'emailSupport': 'Email Support',
  'callCenter': 'Call Center',
  'reportAnIssue': 'Report an Issue',
  'havingTrouble': 'Having trouble?',
  'reportIssueDesc': "Let us know about any issues you experience. We'll get back to you as soon as possible.",
  'faq': 'Frequently Asked Questions',
  'howToResetPassword': 'How do I reset my password?',
  'resetPasswordAnswer': 'You can reset your password by going to Settings > Account > Change Password, or use the "Forgot Password" option on the login screen.',
  'howToUpdateProfile': 'How do I update my profile?',
  'updateProfileAnswer': 'Go to Profile > Edit Profile to update your personal information, profile picture, and other details.',
  'howToContactSupport': 'How do I contact customer support?',
  'contactSupportAnswer': 'You can reach us through Live Chat, Email, or Call Center. Check the "Contact Us" section above for details.',
  'describeYourIssue': "Describe the issue you're experiencing...",
  'submit': 'Submit',
  'reportSubmittedThankYou': 'Report submitted. Thank you!',

  // Sidebar
  'menuLabel': 'Menu',
  'activityLabel': 'Activity',
  'settingsLabel': 'Settings',

  // Menu Grid
  'payment': 'Payment',
  'transfer': 'Transfer',
  'topUp': 'Top Up',
  'bills': 'Bills',
  'shopping': 'Shopping',
  'food': 'Food',
  'transport': 'Transport',
  'more': 'More',

  // Banners & Articles
  'promoTitle1': 'Special Promo',
  'promoSubtitle1': 'Up to 50% off for new users',
  'promoTitle2': 'Free Transfer',
  'promoSubtitle2': '0% transfer fee this month',
  'promoTitle3': 'Shopping Cashback',
  'promoSubtitle3': 'Get 20% cashback on shopping',
  'articleTitle1': 'Financial Management Tips',
  'articleDesc1': 'Learn how to manage your finances wisely',
  'articleTitle2': 'New Features in Super App',
  'articleDesc2': 'Discover the latest features that make your life easier',
  'articleTitle3': 'Digital Transaction Security',
  'articleDesc3': 'Tips to stay safe when making digital transactions',

  // TOS & Privacy
  'tosTitle': 'Terms of Service',
  'tosLastUpdated': 'Last updated',
  'tosIntro': 'Welcome to Super App. By using this application, you agree to comply with the following terms.',
  'privacyTitle': 'Privacy Policy',
  'privacyLastUpdated': 'Last updated',
  'privacyIntro': 'Your privacy is important to us. This policy explains how we collect and use your data.',

  // Profile
  'personalInfo': 'Personal Information',
  'phone': 'Phone',
  'dateOfBirth': 'Date of Birth',
  'gender': 'Gender',
  'address': 'Address',
  'accountSettings': 'Account Settings',
  'changePassword': 'Change Password',
  'notificationSettings': 'Notification Settings',
  'linkedAccounts': 'Linked Accounts',
  'accountInformation': 'Account Information',
  'emailVerified': 'Email Verified',
  'notSet': 'Not set',
  'notLoggedIn': 'Not logged in',
  'privacyAndSecurity': 'Privacy & Security',
  'dangerZone': 'Danger Zone',
  'deleteAccount': 'Delete Account',
  'deleteAccountConfirm': 'Are you sure you want to delete your account? This action cannot be undone.',
  'accountDeletionRequested': 'Account deletion requested',
};

/// Extension untuk akses mudah lokalisasi dari BuildContext
extension LocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
