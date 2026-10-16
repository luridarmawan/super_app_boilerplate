# Localization (Multi-Language) Guide

> **📚 Related Documents:**
> - **[README.md](../README.md)** - Main project documentation
> - **[Modular.md](./Modular.md)** - Modular architecture (per-module localization)

## 📖 Overview

OSA supports multi-language with **four languages**:

| Locale | Bahasa | File string |
|--------|--------|-------------|
| `en_US` | **English** — *default* | `lib/core/l10n/en_strings.dart` |
| `id_ID` | Bahasa Indonesia | `lib/core/l10n/id_strings.dart` |
| `tr_TR` | Türkçe | `lib/core/l10n/tr_strings.dart` |
| `ko_KR` | 한국어 | `lib/core/l10n/ko_strings.dart` |

Locale default aplikasi adalah `en_US` (`AppConfigState.selectedLocale`), dan English juga
menjadi fallback ketika sebuah key tidak tersedia di bahasa aktif.

> Modul `arrow_sense` memiliki set string sendiri di
> `modules/arrow_sense/lib/l10n/` dengan empat bahasa yang sama.

## 🏗️ Struktur File

```
lib/
└── core/
    └── l10n/
        ├── app_localizations.dart   # Delegate, getter, dan fungsi translate()
        ├── en_strings.dart          # enStrings — English (default & fallback)
        ├── id_strings.dart          # idStrings — Bahasa Indonesia
        ├── tr_strings.dart          # trStrings — Türkçe
        └── ko_strings.dart          # koStrings — 한국어
```

## 🚀 Cara Penggunaan

### 1. Import di File yang Membutuhkan

```dart
import 'package:super_app/core/l10n/app_localizations.dart';
```

### 2. Menggunakan String Terjemahan

Ada beberapa cara untuk mengakses string terjemahan:

#### Cara 1: Menggunakan Extension (Recommended)
```dart
// Di dalam Widget
Text(context.l10n.welcomeBack)
Text(context.l10n.signIn)
```

#### Cara 2: Menggunakan AppLocalizations.of()
```dart
// Di dalam Widget
Text(AppLocalizations.of(context).welcomeBack)
```

#### Cara 3: Menggunakan translate() untuk key dinamis
```dart
final l10n = AppLocalizations.of(context);
Text(l10n.translate('welcomeBack'))
```

## 📋 Available String Categories

### General
- `appName`, `appTagline`, `loading`, `error`, `success`
- `cancel`, `confirm`, `save`, `delete`, `edit`, `close`
- `back`, `next`, `done`, `ok`, `yes`, `no`
- `on`, `off`, `left`, `right`, `seeAll`

### Authentication
- `welcomeBack`, `signInToContinue`, `email`, `password`
- `confirmPassword`, `fullName`, `forgotPassword`
- `signIn`, `signUp`, `signOut`, `logout`, `confirmLogout`
- `createAccount`, `joinSuperApp`, `createAccountDesc`
- `dontHaveAccount`, `alreadyHaveAccount`
- `orContinueWith`, `continueWithGoogle`
- `agreeToTerms`, `termsOfService`, `and`, `privacyPolicy`

### Validation
- `pleaseEnterEmail`, `pleaseEnterValidEmail`
- `pleaseEnterPassword`, `passwordMinLength`
- `pleaseConfirmPassword`, `passwordsDoNotMatch`
- `pleaseEnterName`, `loginFailed`, `googleLoginFailed`
- `registrationFailed`, `accountCreatedSuccess`

### Navigation
- `home`, `explore`, `scan`, `activity`, `profile`
- `dashboard`, `menu`, `notifications`
- `history`, `favorites`, `saved`
- `settings`, `helpAndSupport`, `viewProfile`

### Dashboard
- `quickActions`, `latestNews`, `recommendedForYou`
- `noNewNotifications`, `chatSupport`
- `discoverNewServices`, `viewRecentTransactions`
- `guestUser`, `pleaseLoginToContinue`, `editProfile`
- `workspace`

### Scan & Photo
- `scanAndPhoto`, `scanQr`, `takePhoto`, `upload`
- `photoCaptureCancelled`, `cameraError`, `photoPreview`
- `photoCaptured`, `photoCapturedSuccessfully`, `photoSaved`
- `imageSelectionCancelled`, `galleryError`

### Settings
- `appearance`, `themeTemplate`, `darkMode`
- `languageAndRegion`, `language`, `layout`
- `sidebarPosition`, `showQuickActionsLabel`, `showQuickActionsDesc`
- `quickActionsManager`, `quickActionsManagerDesc`
- `authentication`, `authProvider`
- `about`, `appVersion`, `buildNumber`
- `selectTheme`, `selectLanguage`
- `bahasaIndonesia`, `english`
- `firebaseAuth`, `customApi`, `useFirebaseAuth`, `useCustomApi`

### Theme Templates
- `defaultBlue`, `modernPurple`, `elegantGreen`
- `warmOrange`, `sweetBrown`, `darkModeTheme`

### Help & Support
- `searchHelpArticles`, `quickHelp`, `contactUs`
- `liveChat`, `chatWithSupport`, `emailSupport`
- `callCenter`, `reportAnIssue`, `faq`
- `howToResetPassword`, `resetPasswordAnswer`
- `howToUpdateProfile`, `updateProfileAnswer`
- `howToContactSupport`, `contactSupportAnswer`
- `describeYourIssue`, `submit`, `reportSubmittedThankYou`
- And more...

### Menu Grid
- `payment`, `transfer`, `topUp`, `bills`
- `shopping`, `food`, `transport`, `more`

### Profile
- `personalInfo`, `phone`, `dateOfBirth`, `gender`, `address`
- `accountSettings`, `changePassword`, `notificationSettings`
- `linkedAccounts`, `accountInformation`, `emailVerified`
- `notSet`, `notLoggedIn`, `privacyAndSecurity`
- `dangerZone`, `deleteAccount`, `deleteAccountConfirm`
- `accountDeletionRequested`

### GPS / Location
- `location`, `myLocation`, `gettingLocation`
- `gpsDisabled`, `gpsDisabledDesc`
- `locationPermissionDenied`, `locationServiceDisabled`
- `openSettings`, `locationUpdated`, `failedToGetLocation`
- `accuracy`

### Banners & Articles
- `promoTitle1`, `promoSubtitle1`, `promoTitle2`, `promoSubtitle2`
- `promoTitle3`, `promoSubtitle3`
- `articleTitle1`, `articleDesc1`, `articleTitle2`, `articleDesc2`
- `articleTitle3`, `articleDesc3`

### TOS & Privacy
- `tosTitle`, `tosLastUpdated`, `tosIntro`
- `privacyTitle`, `privacyLastUpdated`, `privacyIntro`

## 🔄 Mengganti Bahasa

User dapat mengganti bahasa melalui Settings Screen:

```dart
// Menggunakan provider
ref.read(appConfigProvider.notifier).setLocale(const Locale('en', 'US'));
ref.read(appConfigProvider.notifier).setLocale(const Locale('id', 'ID'));
ref.read(appConfigProvider.notifier).setLocale(const Locale('tr', 'TR'));
ref.read(appConfigProvider.notifier).setLocale(const Locale('ko', 'KR'));
```

## ➕ Menambah String Baru

1. Tambahkan string ke **setiap** file bahasa (`en_strings.dart` wajib, karena jadi fallback):

```dart
// lib/core/l10n/en_strings.dart
const Map<String, String> enStrings = {
  // ... existing strings
  'newString': 'New text in English',
};
```

```dart
// lib/core/l10n/id_strings.dart
const Map<String, String> idStrings = {
  // ... existing strings
  'newString': 'Teks baru dalam Bahasa Indonesia',
};
```

Ulangi untuk `tr_strings.dart` dan `ko_strings.dart`.

2. Tambahkan getter di class `AppLocalizations` (`app_localizations.dart`):
```dart
String get newString => translate('newString');
```

## 🌍 Menambah Bahasa Baru

1. Tambahkan bahasa ke `isSupported` di delegate:
```dart
@override
bool isSupported(Locale locale) {
  return ['id', 'en', 'tr', 'ko', 'zh'].contains(locale.languageCode); // Tambah 'zh'
}
```

2. Buat file string baru `lib/core/l10n/zh_strings.dart`:
```dart
const Map<String, String> zhStrings = {
  'appName': '超级应用',
  // ... tambahkan semua string
};
```

3. Import file tersebut lalu daftarkan di `_localizedStrings`:
```dart
static final Map<String, Map<String, String>> _localizedStrings = {
  'id': idStrings,
  'en': enStrings,
  'tr': trStrings,
  'ko': koStrings,
  'zh': zhStrings, // Tambah ini
};
```

4. Update `supportedLocales` di `main.dart`:
```dart
supportedLocales: const [
  Locale('en', 'US'),
  Locale('id', 'ID'),
  Locale('tr', 'TR'),
  Locale('ko', 'KR'),
  Locale('zh', 'CN'), // Tambah ini
],
```

## 📱 Contoh Implementasi di Screen

```dart
import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';

class ExampleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.settings),
      ),
      body: Column(
        children: [
          Text(context.l10n.welcomeBack),
          ElevatedButton(
            onPressed: () {},
            child: Text(context.l10n.signIn),
          ),
          Text(context.l10n.dontHaveAccount),
          TextButton(
            onPressed: () {},
            child: Text(context.l10n.signUp),
          ),
        ],
      ),
    );
  }
}
```

## ✅ Best Practices

1. **Selalu gunakan lokalisasi** - Jangan hardcode string dalam UI
2. **Gunakan key yang deskriptif** - `loginButton` lebih baik dari `btn1`
3. **Grouping yang jelas** - Kelompokkan string berdasarkan fitur/screen
4. **Fallback ke English** - Jika key tidak ditemukan di bahasa aktif, `translate()` mengambil dari `enStrings`; jika tetap tidak ada, key-nya sendiri yang ditampilkan
5. **Konsisten** - Gunakan pola penamaan yang sama

## 🔍 Testing

Untuk testing lokalisasi:

```dart
testWidgets('should display correct localized text', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('id', 'ID'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      home: YourWidget(),
    ),
  );
  
  expect(find.text('Selamat Datang Kembali'), findsOneWidget);
});
```

---

## See Also

- **[README.md](../README.md)** - Main project documentation
- **[Modular.md](./Modular.md)** - Modular architecture (per-module localization)
- **[GPS.md](./GPS.md)** - GPS feature with localized strings

---

*Updated: 28 Agustus 2026*
*Version: 2.0.0*
