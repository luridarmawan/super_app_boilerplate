# Splash Screen 

Complete documentation for Splash Screen configuration and usage.

> **📚 Related Documents:**
> - **[README.md](../README.md)** - Main project documentation

---

## Table of Contents

1. [Introduction](#introduction)
2. [Main Features](#main-features)
3. [.env Configuration](#env-configuration)
4. [Visual Customization](#visual-customization)
5. [Flow Logic](#flow-logic)
6. [Technical Implementation](#technical-implementation)
7. [Troubleshooting](#troubleshooting)

---

## Introduction

Splash Screen is the opening screen displayed when the app is first launched. Super App Boilerplate provides a fully customizable splash screen through the `.env` file.

### How Splash Screen Works

1. **If not logged in**: Splash screen is **always displayed**.
2. **If logged in**:
   - Splash screen is displayed on the first N app opens (default: 5).
   - After that, splash screen only appears if the user hasn't opened the app for more than X hours (default: 24 hours).

---

## Main Features

| Feature | Description |
|---------|-------------|
| **Smooth Transition** | Smooth transition from native splash to Flutter splash |
| **Custom Background** | Background image from URL (with gradient fallback) |
| **Custom Gradient** | Configure 3-point gradient colors (start, middle, end) |
| **Configurable Duration** | Splash duration can be configured |
| **Tap to Dismiss** | User can tap screen to skip splash |
| **Loading Indicator** | Loading animation at the bottom |
| **Version Display** | Shows app version at the bottom |
| **Conditional Display** | Smart logic to determine when splash is displayed |

---

## .env Configuration

### All Available Variables

```env
# ============================================
# SPLASH SCREEN CONFIGURATION
# ============================================

# Enable/disable splash screen
ENABLE_SPLASH_SCREEN=true

# Duration splash screen is displayed (in seconds)
SPLASH_DURATION=5

# Number of first app opens that show splash (for logged-in users)
SPLASH_SHOW_COUNT=5

# Hours of inactivity before splash is shown again (for logged-in users)
SPLASH_DELAY=24

# Background image URL (optional, if empty uses gradient only)
SPLASH_BACKGROUND=https://example.com/splash-bg.jpg

# Gradient colors (hex format: #RRGGBB)
SPLASH_GRADIENT_START=#1E88E5
SPLASH_GRADIENT_MIDDLE=#42A5F5
SPLASH_GRADIENT_END=#90CAF9

# Custom logo for splash (optional)
SPLASH_LOGO=assets/images/logo/my_logo.png
```

### Detailed Explanation

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ENABLE_SPLASH_SCREEN` | bool | `false` | Enable/disable splash screen |
| `SPLASH_DURATION` | int | `5` | Splash duration in seconds |
| `SPLASH_SHOW_COUNT` | int | `5` | Number of initial opens that show splash |
| `SPLASH_DELAY` | int | `24` | Hours of inactivity before splash appears again |
| `SPLASH_BACKGROUND` | string | `picsum` | Background image URL |
| `SPLASH_GRADIENT_START` | hex | theme | Top gradient color |
| `SPLASH_GRADIENT_MIDDLE` | hex | theme | Middle gradient color (optional) |
| `SPLASH_GRADIENT_END` | hex | theme | Bottom gradient color |
| `SPLASH_LOGO` | string | default | Path to splash logo |

---

## Visual Customization

### Background Image

Background image will be loaded from URL and displayed with a dark overlay to ensure text remains readable.

```env
# Use your own image
SPLASH_BACKGROUND=https://your-cdn.com/splash-background.jpg

# Or leave empty for gradient only
SPLASH_BACKGROUND=
```

**Notes:**
- Image will be cached using `CachedNetworkImage`
- 3-second timeout for image loading
- If loading fails, will fallback to gradient

### Custom Gradient

Configure 3-color gradient from top to bottom:

```env
# Example: Blue gradient
SPLASH_GRADIENT_START=#1565C0
SPLASH_GRADIENT_MIDDLE=#42A5F5
SPLASH_GRADIENT_END=#BBDEFB

# Example: Purple gradient
SPLASH_GRADIENT_START=#7B1FA2
SPLASH_GRADIENT_MIDDLE=#AB47BC
SPLASH_GRADIENT_END=#E1BEE7

# Example: Green gradient
SPLASH_GRADIENT_START=#2E7D32
SPLASH_GRADIENT_MIDDLE=#66BB6A
SPLASH_GRADIENT_END=#C8E6C9
```

**If not set**, gradient will use theme colors:
- `colorScheme.primary`
- `colorScheme.primaryContainer`
- `colorScheme.secondaryContainer`

### Visual Structure of Splash Screen

```
┌────────────────────────────────────┐
│                                    │
│                                    │
│         ┌─────────────┐            │
│         │             │            │
│         │    LOGO     │            │
│         │             │            │
│         └─────────────┘            │
│                                    │
│           App Name                 │
│           Tagline                  │
│                                    │
│                                    │
│                                    │
│            ◐ Loading...            │
│                                    │
│         v1.0.0 build 1             │
└────────────────────────────────────┘
```

---

## Flow Logic

### Splash Screen Flow Diagram

```
┌─────────────────────────────────────┐
│        App Launched                 │
└─────────────────┬───────────────────┘
                  │
                  ▼
┌─────────────────────────────────────┐
│    ENABLE_SPLASH_SCREEN = true?     │
└─────────────────┬───────────────────┘
                  │
        ┌─────────┴─────────┐
        │ No                │ Yes
        ▼                   ▼
┌───────────────┐  ┌───────────────────────────┐
│ Skip Splash   │  │      User Logged In?      │
│ → Login/Dash  │  └─────────────┬─────────────┘
└───────────────┘                │
                       ┌─────────┴─────────┐
                       │ No                │ Yes
                       ▼                   ▼
              ┌──────────────┐   ┌───────────────────────────┐
              │ Show Splash  │   │ openCount < SPLASH_COUNT? │
              │ → Login      │   └─────────────┬─────────────┘
              └──────────────┘                 │
                                     ┌─────────┴─────────┐
                                     │ Yes               │ No
                                     ▼                   ▼
                            ┌──────────────┐   ┌──────────────────────────┐
                            │ Show Splash  │   │ lastOpen > DELAY hours?  │
                            │ → Dashboard  │   └────────────┬─────────────┘
                            └──────────────┘                │
                                                  ┌─────────┴─────────┐
                                                  │ Yes               │ No
                                                  ▼                   ▼
                                         ┌──────────────┐    ┌───────────────┐
                                         │ Show Splash  │    │ Skip Splash   │
                                         │ → Dashboard  │    │ → Dashboard   │
                                         └──────────────┘    └───────────────┘
```

### Smooth Transition Flow

```
1. Native splash (solid color) appears instantly when app launches
                    │
                    ▼
2. Flutter splash appears on top of native splash
                    │
                    ▼
3. Background image is preloaded (async)
                    │
                    ▼
4. After image ready, crossfade from solid to image
                    │
                    ▼
5. Logo and content fade-in + scale animation
                    │
                    ▼
6. After SPLASH_DURATION or user tap → Navigate
```

---

## Technical Implementation

### Files Involved

| File | Description |
|------|-------------|
| `lib/core/constants/app_info.dart` | Splash configuration from .env |
| `lib/core/services/prefs_service.dart` | Tracking open count and last opened time |
| `lib/core/routes/app_router.dart` | Routing logic based on splash conditions |
| `lib/features/splash/splash_screen.dart` | Splash screen widget |
| `pubspec.yaml` (flutter_native_splash) | Native splash configuration |

### AppInfo Properties

```dart
// lib/core/constants/app_info.dart

// Enable/disable
static bool get enableSplashScreen => ...;

// Duration
static Duration get splashScreenDuration => ...;

// Visibility logic
static int get splashShowCount => ...;
static int get splashDelayHours => ...;

// Visual customization
static String get splashBackground => ...;
static String? get splashGradientStart => ...;
static String? get splashGradientMiddle => ...;
static String? get splashGradientEnd => ...;
static List<Color>? get splashGradientColors => ...;
static String get flutterSplashLogo => ...;
```

### PrefsService Methods

```dart
// lib/core/services/prefs_service.dart

// Tracking
int get splashOpenCount;
DateTime? get lastOpenedTime;

// Logic
Future<bool> shouldShowSplash();
Future<void> recordAppOpen();
```

### Splash Screen Widget

```dart
// lib/features/splash/splash_screen.dart

class SplashScreen extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;      // Callback after splash completes
  final Duration? splashDuration;       // Override duration (optional)
  
  // Features:
  // - Smooth transition from native splash
  // - Background image with preload
  // - Gradient fallback
  // - Logo fade + scale animation
  // - Tap to dismiss
  // - Loading indicator
  // - Version display
}
```

---

## Troubleshooting

### Splash not appearing

1. Make sure `ENABLE_SPLASH_SCREEN=true` in `.env`
2. Fully restart the app (not hot reload)
3. Check if you've exceeded `SPLASH_SHOW_COUNT`

### Background image not appearing

1. Check if URL is valid and accessible
2. Make sure device has internet connection
3. Image will timeout after 3 seconds

### Gradient not matching

1. Make sure hex format is correct: `#RRGGBB`
2. If only 1-2 colors are set, other colors will use theme defaults

### Native splash different from Flutter splash

Edit `pubspec.yaml` section `flutter_native_splash`:

```yaml
flutter_native_splash:
  color: "#1565C0"  # Must match SPLASH_GRADIENT_START
```

Then run:
```bash
dart run flutter_native_splash:create
```

---

## Configuration Examples

### Minimal (Default)

```env
ENABLE_SPLASH_SCREEN=true
```

### Dengan Custom Duration

```env
ENABLE_SPLASH_SCREEN=true
SPLASH_DURATION=3
SPLASH_SHOW_COUNT=3
SPLASH_DELAY=12
```

### Full Customization

```env
ENABLE_SPLASH_SCREEN=true
SPLASH_DURATION=5
SPLASH_SHOW_COUNT=5
SPLASH_DELAY=24
SPLASH_BACKGROUND=https://cdn.example.com/splash.jpg
SPLASH_GRADIENT_START=#1565C0
SPLASH_GRADIENT_MIDDLE=#42A5F5
SPLASH_GRADIENT_END=#BBDEFB
SPLASH_LOGO=assets/images/logo/custom_logo.png
```

---

## See Also

- **[README.md](../README.md)** - Main project documentation
- **[Modular.md](./Modular.md)** - Modular architecture

---

*Updated: January 1, 2026*
*Version: 2.0.0*
