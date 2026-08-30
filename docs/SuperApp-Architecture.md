# Super App Architecture Overview

Complete architectural overview of the **OSA (One Stop Archery)** application.

> Brief produk dan status fitur ada di [`BRIEF.md`](../BRIEF.md).

> **📚 Related Documents:**
> - **[BRIEF.md](../BRIEF.md)** - Brief produk (sumber tunggal kebenaran)
> - **[README.md](../README.md)** - Main project documentation
> - **[Modular.md](./Modular.md)** - Modular architecture
> - **[API.md](./API.md)** - Network layer documentation

---

## Table of Contents

1. [Introduction](#introduction)
2. [Technical Stack](#technical-stack)
3. [Architecture Overview](#architecture-overview)
4. [Core Components](#core-components)
5. [Feature Specifications](#feature-specifications)
6. [Configuration System](#configuration-system)
7. [Folder Structure](#folder-structure)

---

## Introduction

OSA (One Stop Archery) is a mobile application (Android & iOS) for the KPBI/IHASA archery community, built with Clean Architecture, using Material 3, and supporting multi-language and multi-template configurations. Archery features live in the external `arrow_sense` module; the app shell provides auth, dashboard, profile, and settings.

### Key Characteristics

| Aspect | Description |
|--------|-------------|
| **Org/Package** | `id.ihasa.app` |
| **Framework** | Flutter (Android & iOS) |
| **UI Standard** | Material 3 (`useMaterial3: true`) |
| **Architecture** | Clean Architecture + Modular |
| **State Management** | Flutter Riverpod |
| **Navigation** | GoRouter |
| **Modul fitur** | `arrow_sense` (repo terpisah) + `news` (internal) |

---

## Technical Stack

### Core Technologies

| Component | Technology | Version |
|-----------|------------|---------|
| **State Management** | Flutter Riverpod | ^2.6.1 |
| **Navigation** | GoRouter | ^17.0.1 |
| **HTTP Client** | Dio | ^5.4.0 |
| **API Layer** | Retrofit | ^4.1.0 |
| **Local Storage** | SharedPreferences | ^2.3.4 |
| **Environment** | flutter_dotenv | ^5.2.1 |
| **Location** | Geolocator | ^13.0.2 |

### Authentication

- **BaseAuthService** - Abstract class for auth abstraction
- **Firebase Auth** - OAuth with Google Sign-In
- **Custom API Auth** - Backend-agnostic REST API authentication
- Switchable via `.env` configuration

### Push Notification

- **Multi-Provider System** - FCM, OneSignal, or Mock
- **Abstraction Layer** - Easy provider switching
- Configured via `NOTIFICATION_PROVIDER` in `.env`

---

## Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                        PRESENTATION                          │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   Screens   │ │   Widgets   │ │   Providers (Riverpod)  │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
                              │
┌──────────────────────────────────────────────────────────────┐
│                         DOMAIN                                │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │   Modules   │ │   Services  │ │      Repositories       │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
                              │
┌──────────────────────────────────────────────────────────────┐
│                          DATA                                 │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────────────────┐ │
│  │  API Client │ │   Models    │ │    Local Storage        │ │
│  └─────────────┘ └─────────────┘ └─────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
```

### Layer Responsibilities

| Layer | Responsibility | Examples |
|-------|----------------|----------|
| **Presentation** | UI, User interaction | Screens, Widgets, Providers |
| **Domain** | Business logic | Modules, Services, Use cases |
| **Data** | Data access | API, Database, Models |

---

## Core Components

### 1. Modular System

The app uses a plugin-based module system:

```dart
// Each module extends BaseModule
class MyModule extends BaseModule {
  @override String get name => 'mymodule';
  @override String get version => '1.0.0';
  @override List<RouteBase> get routes => [...];
  @override List<QuickActionItem> get quickActions => [...];
}
```

**Features:**
- Dynamic route registration
- Quick actions per module
- Dashboard widget slots
- Independent navigation items

📚 See [Modular.md](./Modular.md) for details.

### 2. Network Layer

Repository pattern with Dio + Retrofit:

```
API Request → Interceptors → Repository → API Service → Response
```

**Features:**
- Centralized Dio instance
- Auth token injection
- Error handling
- Bot protection detection (Cloudflare, Imunify360)

📚 See [API.md](./API.md) for details.

### 3. Authentication System

```
BaseAuthService (Interface)
    ├── FirebaseAuthService (Google OAuth)
    └── CustomApiAuthService (REST API)
```

Configurable via `.env`:
```env
AUTH_PROVIDER="customApi"  # or 'firebase'
```

> Nilainya camelCase (`customApi`), bukan `custom_api` — lihat [Auth.md](./Auth.md#auth-provider-selection).

### 4. Theme System

Material 3 with multiple templates:

| Template | Description |
|----------|-------------|
| Default Blue | Primary blue color scheme |
| Modern Purple | Purple gradient theme |
| Elegant Green | Green nature theme |
| Warm Orange | Orange warm theme |
| Sweet Brown | Brown coffee theme |
| Dark Mode | Dark theme with dark surfaces |

---

## Feature Specifications

### Navigation & Layout (Material 3 Adaptive)

| Component | Implementation | Description |
|-----------|----------------|-------------|
| **Header** | `SliverAppBar` / `AppBar` | Dynamic header with logo, title, notification icon |
| **Sidebar** | `NavigationDrawer` | Profile info, activity list, configurable position |
| **Footer** | `NavigationBar` | 5 buttons with dominant center FAB |
| **FAB** | `FloatingActionButton` | Additional action button |

### Screens

| Screen | File | Description |
|--------|------|-------------|
| Splash | `splash_screen.dart` | Full screen with configurable background |
| Dashboard | `main_dashboard.dart` | Banner carousel, menu grid, articles |
| Login | `login_screen.dart` | Email/Google authentication |
| Register | `register_screen.dart` | User registration |
| Profile | `profile_screen.dart` | User profile details |
| Settings | `setting_screen.dart` | Language, theme, layout settings |
| Help | `help_screen.dart` | Help & report |
| TOS | `tos_screen.dart` | Terms of Service |
| Privacy | `privacy_screen.dart` | Privacy Policy |
| Campaign | `campaign_home_screen.dart` | Campaign / promo landing |
| Maintenance | `maintenance_mode_screen.dart` | Maintenance mode (via Remote Config) |
| Quick Actions Manager | `quick_actions_manager_screen.dart` | Atur visibilitas quick action |
| Forgot / Change Password | `forgot_password_screen.dart`, `change_password_screen.dart` | Pemulihan & ganti password |

---

## Configuration System

### Environment Variables (.env)

All configuration is centralized in `.env` file:

```env
# Authentication
AUTH_PROVIDER=firebase

# Notification
ENABLE_NOTIFICATION=true
NOTIFICATION_PROVIDER=firebase

# GPS/Location
ENABLE_GPS=true
GPS_REVERSE_GEO_URL=https://nominatim.openstreetmap.org/reverse?...

# Splash Screen
ENABLE_SPLASH_SCREEN=true
SPLASH_DURATION=5
SPLASH_BACKGROUND=https://example.com/bg.jpg

# Quick Actions
ENABLE_QUICK_ACTION=true
ENABLE_QUICK_ACTION_DEMO=true

# API
ENVIRONMENT=production
API_BASE_URL=https://api.example.com/
API_BASE_URL_DEVELOPMENT=https://staging-api.example.com/

# Modul
ENABLE_MODULE_ARROW_SENSE=true
ENABLE_MODULE_NEWS=true
```

> Timeout HTTP (30 detik) adalah konstanta di `lib/core/network/api_config.dart` dan tidak
> dapat diatur lewat `.env`. Daftar lengkap variabel `.env` ada di
> [Development-and-Build.md](./Development-and-Build.md#2️⃣-konfigurasi-environment-env).

### AppInfo Properties

Configuration is accessed via `AppInfo` class:

```dart
// lib/core/constants/app_info.dart

static String get name => 'Super App';
static bool get enableGps => ...;
static bool get enableNotification => ...;
static String get authProvider => ...;
// ... and many more
```

---

## Folder Structure

```
lib/
├── core/                           # Application core (DO NOT MODIFY)
│   ├── auth/                       # Authentication abstraction
│   │   ├── auth_interface.dart     # BaseAuthService
│   │   ├── firebase_provider.dart  # Firebase implementation
│   │   └── custom_api_provider.dart # Custom API implementation
│   ├── config/                     # App configuration
│   ├── constants/                  # Constants & app info
│   ├── gps/                        # GPS & Location services
│   ├── l10n/                       # Localization (EN, ID, TR, KO)
│   ├── network/                    # Network layer (Dio + Retrofit)
│   ├── notification/               # Push notification services
│   ├── routes/                     # GoRouter navigation
│   ├── services/                   # Core services
│   ├── theme/                      # Material 3 themes
│   └── utils/                      # Utility functions
│
├── modules/                        # Pluggable modules (EXTENSIBLE)
│   ├── all_modules.dart            # Module manifest
│   ├── module_base.dart            # Abstract module class
│   ├── module_registry.dart        # Module registration
│   ├── quick_action_item.dart      # Quick action model
│   └── [module_name]/              # Each module is self-contained
│
├── features/                       # Built-in core features
│   ├── auth/                       # Authentication screens
│   ├── dashboard/                  # Main dashboard
│   ├── profile/                    # User profile
│   ├── settings/                   # App settings
│   └── splash/                     # Splash screen
│
├── shared/                         # Global components
│   ├── info/                       # Info screens (help, TOS, privacy)
│   └── widgets/                    # Shared widgets
│
├── main.dart                       # Entry point
│
modules/                            # External modules (SEPARATE REPOS)
└── [external_module]/              # Cloned from separate repositories
```

---

## See Also

- **[README.md](../README.md)** - Main project documentation
- **[Modular.md](./Modular.md)** - Modular architecture in depth
- **[SubModule.md](./SubModule.md)** - External module integration
- **[API.md](./API.md)** - Network layer documentation
- **[Notification.md](./Notification.md)** - Push notification system
- **[GPS.md](./GPS.md)** - GPS/Location feature
- **[LOCALIZATION.md](./LOCALIZATION.md)** - Multi-language support
- **[SplashScreen.md](./SplashScreen.md)** - Splash screen configuration
- **[QuickAction.md](./QuickAction.md)** - Quick actions system

---

*Updated: 28 Agustus 2026*
*Version: 2.1.0*
