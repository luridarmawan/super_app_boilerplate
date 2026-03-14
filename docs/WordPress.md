# WordPress API Support

Boilerplate ini memiliki **dukungan penuh untuk WordPress REST API**, termasuk autentikasi dengan **JWT (JSON Web Token)**.

## ✨ Fitur Utama

| Fitur | Deskripsi |
|-------|-----------|
| **Auto-Detection** | Otomatis mendeteksi apakah backend adalah WordPress melalui endpoint `/wp-json/` |
| **JWT Authentication** | Support login via WordPress JWT Auth plugin |
| **User Profile Sync** | Otomatis mengambil profil user dari `/wp-json/wp/v2/users/me` |
| **Avatar Support** | Mapping avatar URL dari WordPress Gravatar/avatar_urls |
| **Token Management** | Token JWT disimpan dan dikelola secara otomatis |
| **Bearer Token Headers** | Authorization header ditambahkan ke semua API calls |

---

## 🔧 Konfigurasi

Untuk menggunakan WordPress sebagai backend, konfigurasikan di `.env`:

```env
# WordPress REST API
AUTH_API_URL=https://yourdomain.com/wp-json/jwt-auth/v1/token
```

---

## 📋 WordPress Plugin yang Diperlukan

Untuk autentikasi JWT, install salah satu plugin berikut di WordPress:

| Plugin | Deskripsi |
|--------|-----------|
| **Simple JWT Login** | [Simple JWT Login](https://wordpress.org/plugins/simple-jwt-login/) |
| **JWT Auth** | [JWT Authentication for WP REST API](https://wordpress.org/plugins/jwt-auth/) |
| **JWT Auth (Tmeister)** | [JWT Authentication for WP-API](https://github.com/Tmeister/wp-api-jwt-auth) |

---

## 📖 Cara Kerja

```
┌─────────────────────────────────────────────────────────────────┐
│                        LOGIN FLOW                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  1. User Input                                                   │
│     ┌──────────────────┐                                        │
│     │ Username/Email   │                                        │
│     │ Password         │                                        │
│     └────────┬─────────┘                                        │
│              │                                                   │
│              ▼                                                   │
│  2. POST /wp-json/jwt-auth/v1/token                             │
│     ┌──────────────────────────────────────────┐                │
│     │ { "username": "...", "password": "..." } │                │
│     └────────┬─────────────────────────────────┘                │
│              │                                                   │
│              ▼                                                   │
│  3. WordPress Returns JWT Token                                  │
│     ┌──────────────────────────────────────────┐                │
│     │ { "token": "eyJ...", "user_email": ... } │                │
│     └────────┬─────────────────────────────────┘                │
│              │                                                   │
│              ▼                                                   │
│  4. Auto-Detect WordPress (check /wp-json/ in URL)              │
│              │                                                   │
│              ▼                                                   │
│  5. GET /wp-json/wp/v2/users/me                                 │
│     (with Authorization: Bearer <token>)                        │
│              │                                                   │
│              ▼                                                   │
│  6. Map User Profile to AuthUser                                │
│     ┌──────────────────────────────────────────┐                │
│     │ id → userId                              │                │
│     │ name → displayName                       │                │
│     │ avatar_urls.48 → avatarUrl               │                │
│     └──────────────────────────────────────────┘                │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Langkah-langkah Detail:

1. **Login Request** → Kirim `username` & `password` ke endpoint JWT Auth
2. **Receive Token** → WordPress mengembalikan JWT token
3. **Auto-Detect WordPress** → Sistem mendeteksi endpoint mengandung `/wp-json/`
4. **Fetch User Profile** → Otomatis GET ke `/wp-json/wp/v2/users/me`
5. **Map User Data** → ID, name, dan avatar_urls di-mapping ke `AuthUser`

---

## 🔒 Contoh Response WordPress

### Login Response

**Endpoint:** `POST /wp-json/jwt-auth/v1/token`

**Request Body:**
```json
{
  "username": "johndoe",
  "password": "secretpassword"
}
```

**Response:**
```json
{
  "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL2V4YW1wbGUuY29tIiwiaWF0IjoxNjk4NzY1NDMyLCJuYmYiOjE2OTg3NjU0MzIsImV4cCI6MTY5OTM3MDIzMiwiZGF0YSI6eyJ1c2VyIjp7ImlkIjoiMSJ9fX0.SIGNATURE",
  "user_email": "user@example.com",
  "user_nicename": "johndoe",
  "user_display_name": "John Doe"
}
```

### User Profile Response

**Endpoint:** `GET /wp-json/wp/v2/users/me`

**Headers:**
```
Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...
```

**Response:**
```json
{
  "id": 1,
  "name": "John Doe",
  "url": "https://johndoe.com",
  "description": "WordPress developer",
  "slug": "johndoe",
  "avatar_urls": {
    "24": "https://secure.gravatar.com/avatar/abc123?s=24&d=mm&r=g",
    "48": "https://secure.gravatar.com/avatar/abc123?s=48&d=mm&r=g",
    "96": "https://secure.gravatar.com/avatar/abc123?s=96&d=mm&r=g"
  },
  "meta": [],
  "_links": {
    "self": [{ "href": "https://example.com/wp-json/wp/v2/users/1" }]
  }
}
```

---

## 🛠️ Implementasi di Kode

File utama: `lib/core/auth/custom_api_provider.dart`

### Auto-Detection WordPress

```dart
// Deteksi apakah backend adalah WordPress
bool _isWordPressApi(String url) {
  return url.contains('/wp-json/');
}
```

### Fetch User Profile

```dart
Future<void> _fetchWordPressUserProfile(String token, String baseUrl) async {
  // Extract base URL from login endpoint
  final uri = Uri.parse(baseUrl);
  final wpUserEndpoint = '${uri.scheme}://${uri.host}/wp-json/wp/v2/users/me';

  final response = await dio.get(
    wpUserEndpoint,
    options: Options(
      headers: {'Authorization': 'Bearer $token'},
    ),
  );

  if (response.statusCode == 200) {
    final data = response.data;
    // Map to AuthUser
    final user = AuthUser(
      id: data['id'].toString(),
      displayName: data['name'],
      avatarUrl: data['avatar_urls']?['48'],
    );
  }
}
```

---

## 🔐 Keamanan

### Best Practices

1. **HTTPS Wajib** - Selalu gunakan HTTPS untuk endpoint WordPress
2. **Strong Secret Key** - Gunakan secret key yang kuat untuk JWT
3. **Token Expiration** - Atur masa berlaku token (default 7 hari)
4. **CORS Configuration** - Konfigurasi CORS dengan benar di WordPress

---

## 🐛 Troubleshooting


---

## 📚 Referensi

- [WordPress REST API Handbook](https://developer.wordpress.org/rest-api/)
- [JWT Auth Plugin (Tmeister)](https://github.com/Tmeister/wp-api-jwt-auth)
- [JWT.io - JWT Decoder](https://jwt.io/)
