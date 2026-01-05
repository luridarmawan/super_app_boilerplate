# Authentication Documentation

Complete documentation for authentication system in Super App Boilerplate.

> **📚 Related Documents:**
> - **[README.md](../README.md)** - Main project documentation
> - **[API.md](./API.md)** - Network layer documentation
> - **[SuperApp-Architecture.md](./SuperApp-Architecture.md)** - Architecture overview

---

## Table of Contents

1. [Overview](#overview)
2. [Auth Provider Selection](#auth-provider-selection)
3. [API Configuration](#api-configuration)
4. [Login](#login)
5. [Register](#register)
6. [Logout](#logout)
7. [Refresh Token](#refresh-token)
8. [Google Sign-In](#google-sign-in)
9. [Password Reset](#password-reset)
10. [Testing](#testing)
11. [Client Implementation](#client-implementation)

---

## Overview

Super App Boilerplate supports multiple authentication providers through an abstraction layer:

```
BaseAuthService (Interface)
    ├── CustomApiAuthProvider (REST API)
    └── FirebaseAuthProvider (Firebase Auth + Google OAuth)
```

### Features

| Feature | Custom API | Firebase |
|---------|------------|----------|
| Email/Password Login | ✅ | ✅ |
| Email/Password Register | ✅ | ✅ |
| Google Sign-In | ✅ | ✅ |
| Persistent Session | ✅ | ✅ |
| Token Refresh | ✅ | Automatic |
| Password Reset | ✅ | ✅ |
| Email Verification | ⏳ TODO | ✅ |

---

## Auth Provider Selection

Configure the auth provider in `.env` file:

```env
# Auth Provider: 'firebase' or 'custom_api'
AUTH_PROVIDER=custom_api
```

### Custom API Provider

Use this when you have your own backend REST API:

```env
AUTH_PROVIDER=custom_api
API_BASE_URL=https://api.yourdomain.com/
```

### Firebase Provider

Use this for Firebase Authentication:

```env
AUTH_PROVIDER=firebase
```

> **Note:** Firebase requires additional setup:
> - Add `google-services.json` for Android
> - Add `GoogleService-Info.plist` for iOS
> - Enable Firebase packages in `pubspec.yaml`

---

## API Configuration

### Base URL and Endpoints

All API endpoints are configured through `.env` file:

```env
# Base URL
API_BASE_URL=https://api.yourdomain.com/
API_BASE_URL_DEVELOPMENT=https://dev-api.yourdomain.com/

# Auth Endpoints (Full URLs)
AUTH_LOGIN_URL=https://api.yourdomain.com/o/auth/login/
AUTH_LOGIN_CONTENT_TYPE="application/json"

AUTH_REFRESH_TOKEN_URL=https://api.yourdomain.com/o/auth/token/
AUTH_LOGOUT_URL=https://api.yourdomain.com/o/auth/logout/
AUTH_REGISTER_URL=https://api.yourdomain.com/o/auth/register/
AUTH_FORGOT_PASSWORD_URL=https://api.yourdomain.com/o/auth/forgot-password/
AUTH_RESET_PASSWORD_URL=https://api.yourdomain.com/o/auth/reset-password/
AUTH_VERIFY_TOKEN_URL=https://api.yourdomain.com/o/auth/verify-token/
```

> **Note:** All auth endpoints use full URLs. Adjust according to your backend structure.

---

## Login

Endpoint for login using username/email and password.

### Endpoint

Login uses the URL directly from the `AUTH_LOGIN_URL` configuration in the `.env` file:

```
POST {AUTH_LOGIN_URL}
```


### Request

#### Headers

Content-Type is configured via `AUTH_LOGIN_CONTENT_TYPE` in the `.env` file.

| Header | Value | Description |
|--------|-------|-------------|
| Content-Type | Configurable | `application/json` (default) or `application/x-www-form-urlencoded` |

**Supported Content Types:**

| Content-Type | Format Data |
|--------------|-------------|
| `application/json` | JSON body (default) |
| `application/x-www-form-urlencoded` | Form URL encoded |

#### Payload

**JSON Format** (`application/json`):
```json
{
    "username": "admin@yourdomain.com",
    "password": "admin123"
}
```

**Form URL Encoded** (`application/x-www-form-urlencoded`):
```
username=admin%40yourdomain.com&password=admin123
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| username | string | Yes | User's email or username |
| password | string | Yes | User's password (min. 6 characters) |

### Response

#### Success Response (code: 0 or 200)
```json
{
    "code": 0,
    "id": "user_id",
    "first_name": "John",
    "last_name": "Doe",
    "email": "admin@yourdomain.com",
    "phone": "",
    "avatar": "https://picsum.photos/200/200?random=10",
    "token": "access_token_here",
    "elapsed_time": 0
}
```

| Field | Type | Description |
|-------|------|-------------|
| code | int | Status code (0 = success, non-zero = error) |
| id | string | User ID |
| first_name | string | User's first name |
| last_name | string | User's last name |
| email | string | User's email |
| phone | string | Phone number (optional) |
| avatar | string | Profile photo URL |
| token | string | Access token for subsequent API calls |
| elapsed_time | int | Request processing time (ms) |

> **Alternative Response Structures:**  
> The app also supports these response structures:
> - `{ user: {...}, token: "..." }`
> - `{ data: { user: {...}, token: "..." } }`

#### Error Response

The application supports various error response formats:

**Format 1: With `message` field**
```json
{
    "code": 400,
    "message": "Invalid email format",
    "elapsed_time": 0
}
```

**Format 2: With `msg` field**
```json
{
    "code": 404,
    "msg": "Invalid password or username not exists.",
    "attempt": 1
}
```

**Supported Error Fields:**

The application will look for error messages from the following fields (in priority order):

| Priority | Field Name | Example |
|----------|------------|--------|
| 1 | `message` | `{"message": "Invalid email"}` |
| 2 | `msg` | `{"msg": "Invalid password"}` |
| 3 | `error` | `{"error": "Unauthorized"}` |
| 4 | `detail` | `{"detail": "Not found"}` |

**Error Code Reference:**

| HTTP Status | code | message/msg |
|-------------|------|-------------|
| 200 | 404 | Invalid password or username not exists |
| 401 | - | Unauthorized |
| 500 | - | Internal Server Error |

---

## Register

Endpoint for user registration.

### Endpoint
```
POST {AUTH_REGISTER_URL}
```

### Request

#### Headers
| Header | Value |
|--------|-------|
| Content-Type | application/json |

#### Payload
```json
{
    "email": "user@example.com",
    "password": "password123",
    "name": "John Doe"
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | User's email |
| password | string | Yes | Password (min. 6 characters) |
| name | string | No | User's display name |

### Response

#### Success Response
```json
{
    "code": 0,
    "id": "new_user_id",
    "email": "user@example.com",
    "token": "access_token_here",
    "message": "Registration successful"
}
```

---

## Logout

Endpoint for user logout.

### Endpoint
```
POST {AUTH_LOGOUT_URL}
```

### Request

#### Headers
| Header | Value |
|--------|-------|
| Content-Type | application/json |
| Authorization | Bearer {token} |

### Response

#### Success Response
```json
{
    "code": 0,
    "message": "Logout successful"
}
```

---

## Refresh Token

Endpoint to refresh access token.

### Endpoint
```
POST {AUTH_REFRESH_TOKEN_URL}
```

### Request

#### Headers
| Header | Value |
|--------|-------|
| Content-Type | application/json |

#### Payload
```json
{
    "refresh_token": "your_refresh_token_here"
}
```

### Response

#### Success Response
```json
{
    "code": 0,
    "token": "new_access_token_here",
    "refresh_token": "new_refresh_token_here"
}
```

---

## Google Sign-In

Authentication using Google OAuth. The app sends Google ID Token to backend for verification.

### Endpoint
```
POST {AUTH_GOOGLE_VERIFICATION_URL}
```

### Request

#### Headers
| Header | Value |
|--------|-------|
| Content-Type | application/json |

#### Payload
```json
{
    "token": "google_id_token_here"
}
```

### Response

#### Success Response
```json
{
    "user": {
        "id": "user_id",
        "email": "user@gmail.com",
        "name": "User Name",
        "picture": "https://lh3.googleusercontent.com/...",
        "email_verified": true
    }
}
```

### Google Login Configuration

To enable Google Sign-In, add the following to `.env`:

```env
# Enable Google Login
ENABLE_GOOGLE_LOGIN=true

# Google OAuth Client ID
# Get from Google Cloud Console: https://console.cloud.google.com/
# Use the Web Client ID (not Android Client ID)
GOOGLE_CLIENT_ID=your_google_client_id

# Endpoint for backend to verify Google ID Token
AUTH_GOOGLE_VERIFICATION_URL=https://api.yourdomain.com/v1/auth/google/verify
```

### Steps to Get Google Client ID

1. Open [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable **Google Sign-In API** in APIs & Services menu
4. Open **Credentials** → Create Credentials → **OAuth Client ID**
5. Select **Web application** as Application type
6. Copy the **Client ID** and add to `GOOGLE_CLIENT_ID` in `.env`

> **Important:** Use the **Web Client ID**, not Android Client ID. Web Client ID is required for backend token verification.

---

## Password Reset

### Forgot Password

#### Endpoint
```
POST {AUTH_FORGOT_PASSWORD_URL}
```

#### Payload
```json
{
    "email": "user@example.com"
}
```

#### Response
```json
{
    "code": 0,
    "message": "Password reset email sent"
}
```

### Reset Password

#### Endpoint
```
POST {AUTH_RESET_PASSWORD_URL}
```

#### Payload
```json
{
    "token": "reset_token_from_email",
    "new_password": "new_password_here"
}
```

---

## Testing

### Manual Login Testing with cURL

**Login Request:**
```bash
curl -X POST https://api.yourdomain.com/v1/auth/login/ \
  -H "Content-Type: application/json" \
  -d '{"username":"admin@yourdomain.com","password":"admin123"}'
```

**Logout Request:**
```bash
curl -X POST https://api.yourdomain.com/v1/auth/logout/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Refresh Token Request:**
```bash
curl -X POST https://api.yourdomain.com/v1/auth/refresh-token/ \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"YOUR_REFRESH_TOKEN"}'
```

### Demo Credentials

For testing, you can configure default credentials in `.env`:

```env
USERNAME_DEFAULT=admin@yourdomain.com
PASSWORD_DEFAULT=admin123
```

---

## Client Implementation

### Files

| File | Description |
|------|-------------|
| `lib/core/auth/auth_interface.dart` | BaseAuthService abstract class + AuthUser model |
| `lib/core/auth/custom_api_provider.dart` | Custom API implementation |
| `lib/core/auth/firebase_provider.dart` | Firebase Auth implementation |

### AuthUser Model

```dart
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool isEmailVerified;
  final bool isGoogleLogin;
}
```

### BaseAuthService Methods

```dart
abstract class BaseAuthService {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;
  
  Future<AuthResult> signInWithEmailAndPassword({...});
  Future<AuthResult> createUserWithEmailAndPassword({...});
  Future<AuthResult> signInWithGoogle();
  Future<void> signOut();
  Future<AuthResult> sendEmailVerification();
  Future<AuthResult> sendPasswordResetEmail(String email);
  Future<AuthResult> updateProfile({...});
  void dispose();
}
```

### Feature Status

| Feature | Status |
|---------|--------|
| ✅ Login with Email/Password | Implemented |
| ✅ Login with Google | Implemented |
| ✅ Register with Email/Password | Implemented |
| ✅ Persistent login (session saved) | Implemented |
| ✅ Logout with clear session | Implemented |
| ✅ Update Profile | Implemented |
| ⏳ Refresh Token | In Progress |
| ⏳ Email Verification | In Progress |

---

## See Also

- **[API.md](./API.md)** - Network layer with Dio + Retrofit
- **[README.md](../README.md)** - Main project documentation
- **[SuperApp-Architecture.md](./SuperApp-Architecture.md)** - Architecture overview

---

*Updated: January 5, 2026*
*Version: 2.1.0*
