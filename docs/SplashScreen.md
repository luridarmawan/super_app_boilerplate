# Splash Screen 

How the splash screen works:

1. **If not logged in**: Splash screen will **always be displayed**.
2. **If logged in**:
   - Splash screen is displayed on the first 5 app launches.
   - After that, splash screen will only appear again if the user hasn't opened the app for more than 24 hours (configurable via .env).


## .env Configuration

```env
ENABLE_SPLASH_SCREEN=true
SPLASH_SHOW_COUNT=5
SPLASH_DELAY=24
```

| Variable | Description | Default |
|----------|-------------|---------|
| `ENABLE_SPLASH_SCREEN` | Enable/disable splash screen | `false` |
| `SPLASH_SHOW_COUNT` | Number of initial launches that display splash screen (for logged-in users) | `5` |
| `SPLASH_DELAY` | Hours of inactivity before splash screen is displayed again (for logged-in users) | `24` |


## Technical Implementation

### Files Involved

1. **`lib/core/constants/app_info.dart`**
   - `enableSplashScreen`: Flag to enable splash screen
   - `splashShowCount`: Number of initial launches to show splash
   - `splashDelayHours`: Hours of delay before splash appears again

2. **`lib/core/services/prefs_service.dart`**
   - `splashOpenCount`: Counts how many times app has been opened
   - `lastOpenedTime`: Last time the app was opened
   - `shouldShowSplash()`: Determines if splash should be displayed
   - `recordAppOpen()`: Records each app opening

3. **`lib/core/routes/app_router.dart`**
   - Logic to determine `initialLocation` based on splash conditions and login status

### Flow Logic

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
