# Assets README

This folder contains the application's image assets.

## Folder Structure

```
assets/
└── images/
    ├── logo.png          # App logo
    ├── logo_white.png    # White version of logo
    ├── splash.png        # Splash screen image
    ├── splash_bg.png     # Splash background
    ├── placeholder.png   # General placeholder image
    └── user_placeholder.png  # User avatar placeholder
```

## Usage

Reference these assets using the `Assets` class from `lib/core/constants/assets.dart`:

```dart
import 'package:super_app_boilerplate/core/constants/assets.dart';

// Use assets
Image.asset(Assets.logo);
Image.asset(Assets.placeholder);
```

## Adding New Assets

1. Add your image files to the appropriate subfolder
2. Update `lib/core/constants/assets.dart` with the new paths
3. Run `flutter pub get` to update asset references
