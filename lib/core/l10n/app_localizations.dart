import 'package:flutter/material.dart';

import 'package:super_app/core/l10n/id_strings.dart';
import 'package:super_app/core/l10n/en_strings.dart';

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
    'id': idStrings,
    'en': enStrings,
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
  // String get appName => translate('appName');
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
  String get confirmLogout => translate('confirmLogout');
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
  String get workspace => translate('workspace');

  // ============================================
  // SCAN & PHOTO STRINGS
  // ============================================
  String get scanAndPhoto => translate('scanAndPhoto');
  String get scanQr => translate('scanQr');
  String get takePhoto => translate('takePhoto');
  String get upload => translate('upload');
  String get photoCaptureCancelled => translate('photoCaptureCancelled');
  String get cameraError => translate('cameraError');
  String get photoPreview => translate('photoPreview');
  String get photoCaptured => translate('photoCaptured');
  String get photoCapturedSuccessfully => translate('photoCapturedSuccessfully');
  String get photoSaved => translate('photoSaved');
  String get imageSelectionCancelled => translate('imageSelectionCancelled');
  String get galleryError => translate('galleryError');

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
  String get showQuickActionsLabel => translate('showQuickActionsLabel');
  String get showQuickActionsDesc => translate('showQuickActionsDesc');
  String get quickActionsManager => translate('quickActionsManager');
  String get quickActionsManagerDesc => translate('quickActionsManagerDesc');
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
  String get sweetBrown => translate('sweetBrown');
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

  // ============================================
  // GPS / LOCATION STRINGS
  // ============================================
  String get location => translate('location');
  String get myLocation => translate('myLocation');
  String get gettingLocation => translate('gettingLocation');
  String get gpsDisabled => translate('gpsDisabled');
  String get gpsDisabledDesc => translate('gpsDisabledDesc');
  String get locationPermissionDenied => translate('locationPermissionDenied');
  String get locationServiceDisabled => translate('locationServiceDisabled');
  String get openSettings => translate('openSettings');
  String get locationUpdated => translate('locationUpdated');
  String get failedToGetLocation => translate('failedToGetLocation');
  String get accuracy => translate('accuracy');

  // ============================================
  // NEWS MODULE STRINGS
  // ============================================
  String get failedToLoadCoverStory => translate('failedToLoadCoverStory');
  String get failedToLoadNews => translate('failedToLoadNews');
  String get noNewsAvailable => translate('noNewsAvailable');
  String get tryAgain => translate('tryAgain');
}


/// Extension untuk akses mudah lokalisasi dari BuildContext
extension LocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
