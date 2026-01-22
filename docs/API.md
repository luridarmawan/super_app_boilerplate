# 📡 Network Layer Documentation

Dokumentasi lengkap untuk Network Layer menggunakan **Dio + Retrofit** dengan **Repository Pattern**.

---

## 📁 Struktur Folder

```
lib/core/network/
├── api_config.dart              # Konfigurasi base URL, timeout, environment
├── api_client.dart              # Instance Dio terpusat dengan interceptors
├── network.dart                 # Barrel export untuk kemudahan import
├── connectivity/
│   └── connectivity_provider.dart # Network connectivity monitoring
├── exceptions/
│   └── api_exception.dart       # Penanganan exception terpadu
├── interceptors/
│   ├── auth_interceptor.dart    # Injeksi token otomatis & refresh
│   ├── logging_interceptor.dart # Logging request/response
│   └── error_interceptor.dart   # Error handling & retry logic
├── models/
│   ├── base_request.dart        # Field shared untuk semua request
│   └── base_response.dart       # Wrapper response standar
├── repository/
│   ├── base_repository.dart     # Base repository dengan method HTTP
│   ├── user_repository.dart     # User API repository
│   ├── article_repository.dart  # Article API repository
│   └── banner_repository.dart   # Banner API repository
└── services/
    ├── api_service.dart         # Definisi API Retrofit
    └── api_service.g.dart       # Kode hasil generate
```

---

## 🚀 Quick Start

### 1. Import Network Layer

```dart
// Import semua komponen sekaligus
import 'package:super_app/core/network/network.dart';

// Atau import spesifik
import 'package:super_app/core/network/api_client.dart';
import 'package:super_app/core/network/repository/base_repository.dart';
```

### 2. Konfigurasi Base URL

Base URL dikonfigurasi otomatis berdasarkan environment di `lib/core/constants/app_info.dart`:

```dart
class AppInfo {
  /// Environment flag: Set to true for production, false for development
  /// - false (default): Uses development API (https://staging-api.carik.id/)
  /// - true: Uses production API (https://api.carik.id/)
  static const bool isProduction = false;
}
```

### 3. Environment Configuration

Konfigurasi environment otomatis berdasarkan flag `AppInfo.isProduction`:

| Environment | Base URL | Logging | Kapan Digunakan |
|-------------|----------|---------|-----------------|
| Development | `https://staging-api.carik.id/` | ✅ Enabled | Saat `isProduction = false` |
| Production | `https://api.carik.id/` | ❌ Disabled | Saat `isProduction = true` |

```dart
// Cek environment saat ini
print(EnvironmentConfig.current.name);      // 'Development' atau 'Production'
print(EnvironmentConfig.current.baseUrl);   // URL sesuai environment
print(EnvironmentConfig.isDevelopment);     // true/false
print(EnvironmentConfig.isProduction);      // true/false
```

---

## 📦 Dependencies

Tambahkan di `pubspec.yaml`:

```yaml
dependencies:
  # Network
  dio: ^5.4.0
  retrofit: ^4.1.0
  json_annotation: ^4.8.1
  connectivity_plus: ^7.0.0      # Network connectivity monitoring

dev_dependencies:
  # Code Generation
  build_runner: ^2.4.8
  retrofit_generator: ^8.2.1
  json_serializable: ^6.8.0
```

Jalankan:
```bash
flutter pub get
```

---

## 🔧 Komponen Utama

### ApiClient

`ApiClient` adalah instance Dio terpusat yang sudah dikonfigurasi dengan semua interceptors.

```dart
// Menggunakan provider (recommended)
final apiClient = ref.watch(apiClientProvider);

// Atau buat manual
final apiClient = ApiClient(
  baseUrl: 'https://api.example.com',
  onUnauthorized: () {
    // Navigate ke login screen
  },
);

// Akses Dio langsung jika diperlukan
final dio = apiClient.dio;
```

#### Token Management

```dart
// Simpan token setelah login
await apiClient.saveTokens(
  accessToken: 'your_access_token',
  refreshToken: 'your_refresh_token',
);

// Hapus token saat logout
await apiClient.clearTokens();
```

---

## 🛡️ Interceptors

### 1. AuthInterceptor

Otomatis menambahkan header `Authorization: Bearer <token>` ke semua request.

```dart
// Token diambil otomatis dari TokenStorage
// Tidak perlu menambahkan header manual!

// Jika perlu skip auth untuk endpoint tertentu:
final response = await dio.get(
  '/public/data',
  options: Options(extra: {'skipAuth': true}),
);
```

**Fitur:**
- ✅ Auto token injection
- ✅ Token refresh otomatis saat 401
- ✅ Skip auth untuk public endpoints
- ✅ Callback `onUnauthorized` untuk redirect ke login

---

## 🍪 Cookie Management (Opsional)

### Konfigurasi

Cookie management dapat diaktifkan melalui environment variable:

```ini
# Di file .env
AUTH_USE_COOKIE=true
```

Ketika diaktifkan:
- Cookies akan otomatis disimpan saat server mengirim `Set-Cookie` header
- Cookies akan otomatis dikirim di setiap request berikutnya
- Cookies disimpan secara persisten (tetap ada setelah app di-restart)

### Dependencies

Pastikan dependencies berikut ada di `pubspec.yaml`:

```yaml
dependencies:
  dio_cookie_manager: ^3.0.0
  cookie_jar: ^4.0.8
  path_provider: ^2.1.1
```

### Inisialisasi

Cookie manager diinisialisasi otomatis di `main.dart` jika `AUTH_USE_COOKIE=true`:

```dart
// Otomatis dilakukan di main.dart
if (AppInfo.authUseCookie) {
  await CookieManager.instance.initialize(usePersistentCookies: true);
}
```

### Penggunaan di Module

Untuk modul yang memerlukan akses cookies, gunakan `CookieManager.instance`:

```dart
import 'package:super_app/core/network/cookie/cookie_manager.dart';

// Ambil semua cookies untuk URL tertentu
final cookies = await CookieManager.instance.getCookies(Uri.parse('https://api.example.com'));

// Ambil cookie string (format: "name1=value1; name2=value2")
final cookieString = await CookieManager.instance.getCookieString('https://api.example.com');

// Ambil nilai cookie spesifik
final sessionId = await CookieManager.instance.getCookieValue(
  'https://api.example.com',
  'session_id',
);

// Set cookie manual
await CookieManager.instance.setCookie(
  Uri.parse('https://api.example.com'),
  Cookie('custom_cookie', 'value'),
);

// Clear semua cookies (saat logout)
await CookieManager.instance.clearCookies();
```

### Penggunaan dengan Dio Instance Manual

Jika modul membuat instance Dio sendiri, tambahkan cookie interceptor:

```dart
final dio = Dio();

// Tambahkan cookie management ke Dio instance
if (AppInfo.authUseCookie) {
  dio.addCookieManager(); // Extension method
}

// Atau secara manual
if (AppInfo.authUseCookie) {
  final interceptor = CookieManager.instance.createInterceptor();
  if (interceptor != null) {
    dio.interceptors.add(interceptor);
  }
}
```

### Provider untuk Riverpod

```dart
// Akses via provider
final cookieManager = ref.watch(cookieManagerProvider);
final cookies = await cookieManager.getCookies(Uri.parse('https://api.example.com'));
```

### Kapan Menggunakan Cookies vs JWT

| Aspek | Cookies | JWT |
|-------|---------|-----|
| **Server Control** | Server mengontrol via Set-Cookie | Aplikasi mengontrol storage |
| **Auto-expiry** | Ya (via cookie attributes) | Harus handle manual |
| **Cross-domain** | Perlu credentials: true | Mudah |
| **Security** | HttpOnly, Secure flags | Rentan XSS jika tidak hati-hati |
| **Use Case** | Session-based auth | Stateless API |

Gunakan cookies jika:
- Backend menggunakan session-based authentication
- Server mengirim `Set-Cookie` header saat login
- Perlu CSRF protection bawaan

---

## 🔐 JWT Authentication

### Cara Kerja JWT di Aplikasi

JWT (JSON Web Token) digunakan untuk autentikasi API. Token disimpan setelah login berhasil dan otomatis dikirim di setiap request API yang memerlukan autentikasi.

#### Struktur Penyimpanan Token

Token disimpan di `SharedPreferences` dengan key `app_saved_user`:

```json
{
  "uid": "9",
  "email": "user@example.com",
  "displayName": "User Name",
  "photoUrl": null,
  "isEmailVerified": true,
  "isGoogleLogin": true,
  "jwt": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
}
```

#### Response Login yang Didukung

Aplikasi mendukung berbagai struktur response login:

**1. JWT di root level:**
```json
{
  "success": true,
  "jwt": "eyJ0eX...",
  "user": { "id": "1", "email": "user@example.com" }
}
```

**2. JWT di dalam object `data`:**
```json
{
  "success": true,
  "data": {
    "jwt": "eyJ0eX...",
    "id": "1",
    "email": "user@example.com"
  }
}
```

**3. Field `token` sebagai alternatif:**
```json
{
  "success": true,
  "token": "eyJ0eX...",
  "data": { "id": "1", "email": "user@example.com" }
}
```

#### Pengambilan JWT untuk API Request

JWT diambil otomatis dari user yang tersimpan:

```dart
// Di module yang memerlukan JWT (contoh: equipment_repository.dart)
Future<String?> _getJwtToken(Ref ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final savedUserJson = prefs.getString('app_saved_user');

    if (savedUserJson != null && savedUserJson.isNotEmpty) {
      final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
      final jwt = userMap['jwt'] as String?;
      return jwt;
    }

    return null;
  } catch (e) {
    return null;
  }
}
```

#### Penggunaan JWT di Header Request

```dart
// JWT ditambahkan sebagai Bearer token
final headers = <String, dynamic>{
  'Authorization': 'Bearer $jwtToken',
  'Accept': 'application/json',
};

final response = await dio.get(
  'https://api.example.com/protected-endpoint',
  options: Options(headers: headers),
);
```

#### Debug Log untuk JWT

Saat mode debug, log berikut akan muncul:

```
[GAUTH] Extracted JWT: (256 chars)
[GAUTH] <<< Success: user@example.com, Name: User Name
[GAUTH] JWT saved: (256 chars)
```

```
[EquipmentRepository] JWT Token: (256 chars)
[EquipmentRepository] Authorization header added
```

#### Error Handling JWT

| Status Code | Penyebab | Penanganan |
|-------------|----------|------------|
| 401 | Token expired atau invalid | Redirect ke login screen |
| 403 | User tidak memiliki permission | Tampilkan error message |

```dart
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    _debugLog('ERROR: Unauthorized - JWT token may be invalid or expired');
    // Redirect ke login
  } else if (e.response?.statusCode == 403) {
    _debugLog('ERROR: Forbidden - User may not have permission');
  }
}
```

---

## 🌐 Browser User-Agent

### Tujuan

User-Agent browser-like digunakan untuk menghindari bot detection dari server yang memiliki proteksi seperti Cloudflare atau Imunify360.

### Konfigurasi di Main App

Di `lib/core/network/api_config.dart`:

```dart
class ApiConfig {
  /// Browser-like User-Agent to avoid bot detection
  /// Used for external API calls that may have bot protection
  static const String browserUserAgent =
      'Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';
}
```

### Penggunaan di Module

Untuk module terpisah (seperti `super_module`), definisikan konstanta lokal karena tidak bisa import langsung dari main app:

```dart
// Di module super_module
const String _browserUserAgent =
    'Mozilla/5.0 (Linux; Android 13; SM-G998B) AppleWebKit/537.36 '
    '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36';

// Penggunaan di request
final headers = <String, dynamic>{
  'User-Agent': _browserUserAgent,
  'Accept': 'application/json, text/plain, */*',
  'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
};
```

### Contoh Implementasi Lengkap

```dart
Future<List<EquipmentModel>> getEquipment() async {
  try {
    // Build headers dengan User-Agent dan JWT
    final headers = <String, dynamic>{
      'User-Agent': _browserUserAgent,
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.9,id;q=0.8',
    };

    // Add Authorization header if JWT token is available
    if (_jwtToken != null && _jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }

    final response = await _dio.get(
      _equipmentApiUrl,
      options: Options(headers: headers),
    );

    // Parse response...
  } catch (e) {
    rethrow;
  }
}
```

### Kapan Menggunakan Browser User-Agent

| Situasi | Gunakan Browser UA? |
|---------|---------------------|
| API internal (backend sendiri) | Opsional |
| API eksternal dengan bot protection | ✅ Wajib |
| Scraping atau crawling | ✅ Wajib |
| API publik tanpa proteksi | Opsional |

### 2. LoggingInterceptor

Mencatat semua request dan response untuk debugging.

**Output Example:**
```
┌──────────────────────────────────────────────────────────────
│ 🚀 REQUEST
├──────────────────────────────────────────────────────────────
│ POST https://api.example.com/api/v1/auth/login
│ Timestamp: 2025-12-24T20:00:00.000
│ Headers:
│   Content-Type: application/json
│   Authorization: [REDACTED]
│ Body: {"email": "user@example.com", "password": "***"}
└──────────────────────────────────────────────────────────────

┌──────────────────────────────────────────────────────────────
│ ✅ RESPONSE
├──────────────────────────────────────────────────────────────
│ 200 POST https://api.example.com/api/v1/auth/login
│ Duration: 234ms
│ Body: {"success": true, "data": {...}}
└──────────────────────────────────────────────────────────────
```

**Fitur:**
- ✅ Redaksi data sensitif (Authorization, Cookie)
- ✅ Truncate body yang terlalu panjang
- ✅ Hanya aktif di debug mode
- ✅ Request timing

### 3. ErrorInterceptor & RetryInterceptor

Menangani error secara terpusat dan retry otomatis.

```dart
// Retry otomatis untuk:
// - Status code: 500, 502, 503, 504
// - Connection timeout
// - Receive timeout
// - Connection error

// Disable retry untuk request tertentu:
final response = await dio.get(
  '/critical-endpoint',
  options: Options(extra: {'noRetry': true}),
);
```

**Konfigurasi:**
```dart
RetryInterceptor(
  dio: dio,
  maxRetries: 3,                    // Maksimal retry
  retryDelay: Duration(seconds: 1), // Delay antar retry (exponential backoff)
  retryStatusCodes: [500, 502, 503, 504],
);
```

### 4. CommonHeadersInterceptor

Menambahkan header umum ke semua request:

```dart
// Header yang ditambahkan otomatis:
X-Request-ID: 1703423400000-abc12345
X-Timestamp: 2025-12-24T20:00:00.000Z
Content-Type: application/json
Accept: application/json
X-Platform: mobile
X-App-Version: 1.0.0
```

---

## 📋 Models

### BaseRequest

Abstract class untuk request dengan field shared.

```dart
// Buat request class dengan extend BaseRequest
class LoginRequest extends BaseRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
    super.deviceId,
    super.platform,
    super.appVersion,
  }) {
    timestamp = DateTime.now();
  }

  @override
  Map<String, dynamic> toJson() => {
    ...baseFields,  // Sertakan field dari BaseRequest
    'email': email,
    'password': password,
  };
}

// Penggunaan
final request = LoginRequest(
  email: 'user@example.com',
  password: 'password123',
  deviceId: 'device_abc123',
  platform: 'android',
  appVersion: '1.0.0',
);

// Hasil toJson():
// {
//   "device_id": "device_abc123",
//   "timestamp": "2025-12-24T20:00:00.000Z",
//   "platform": "android",
//   "app_version": "1.0.0",
//   "email": "user@example.com",
//   "password": "password123"
// }
```

### BaseResponse

Wrapper standar untuk API response.

```dart
// Parse response
final response = BaseResponse<User>.fromJson(
  jsonData,
  (json) => User.fromJson(json),
);

if (response.success) {
  final user = response.data;
  print('User: ${user?.name}');
} else {
  print('Error: ${response.message}');
}

// Akses metadata
print('Status: ${response.statusCode}');
print('Error Code: ${response.errorCode}');
print('Meta: ${response.meta}');
```

### PaginatedResponse

Untuk response dengan pagination.

```dart
final response = PaginatedResponse<Product>.fromJson(
  jsonData,
  (json) => Product.fromJson(json),
);

print('Items: ${response.data?.length}');
print('Page: ${response.currentPage}/${response.lastPage}');
print('Has Next: ${response.hasNextPage}');
print('Total: ${response.total}');
```

---

## 🏗️ Repository Pattern

### BaseRepository

Base class yang menyediakan method HTTP standar.

```dart
abstract class BaseRepository {
  // GET request
  Future<BaseResponse<T>> get<T>(String endpoint, {...});

  // POST request
  Future<BaseResponse<T>> post<T>(String endpoint, {...});

  // PUT request
  Future<BaseResponse<T>> put<T>(String endpoint, {...});

  // PATCH request
  Future<BaseResponse<T>> patch<T>(String endpoint, {...});

  // DELETE request
  Future<BaseResponse<T>> delete<T>(String endpoint, {...});

  // File upload
  Future<BaseResponse<T>> uploadFile<T>(String endpoint, {...});

  // File download
  Future<void> downloadFile(String url, String savePath, {...});

  // Bot protection detection & retry
  Future<Response> fetchWithCloudflareRetry(Future<Response> Function() fetchFunction, {...});
  bool isCloudflareResponse(Response response);
  bool isImunify360Response(Response response);
  bool isBotProtectedResponse(Response response);
  String detectBotProtection(Response response);
}
```

### 🛡️ Bot Protection Detection

BaseRepository menyediakan method untuk mendeteksi dan menangani berbagai jenis bot protection:

#### Jenis Bot Protection yang Dideteksi

| Type | Konstanta | Penanganan |
|------|-----------|------------|
| Cloudflare | `protectionCloudflare` | Auto-retry dengan delay |
| Imunify360 | `protectionImunify360` | Fail immediately (IP-based blocking) |
| Generic Access Denied | `protectionGeneric` | Auto-retry dengan delay |
| None | `protectionNone` | Normal processing |

#### Penggunaan `fetchWithCloudflareRetry`

```dart
// Untuk API yang sering kena bot protection
Future<List<Banner>> getBanners() async {
  try {
    final response = await fetchWithCloudflareRetry(
      () => dio.get('https://api.example.com/banners'),
      apiName: 'Banner API',     // Untuk logging
      maxRetries: 3,             // Default: 3
      retryDelayMs: 2000,        // Default: 2000ms
    );

    // Parse response jika berhasil
    final data = response.data as List;
    return data.map((e) => Banner.fromJson(e)).toList();

  } on DioException catch (e) {
    // Handle error - bisa gunakan fallback data
    debugPrint('Failed to fetch banners: ${e.message}');
    return _getFallbackBanners();
  }
}
```

#### Manual Detection

```dart
// Deteksi manual jika diperlukan
final response = await dio.get('/endpoint');

if (isCloudflareResponse(response)) {
  print('Cloudflare challenge detected');
}

if (isImunify360Response(response)) {
  print('Blocked by Imunify360 - IP-based blocking');
}

// Atau gunakan detectBotProtection untuk hasil detail
final protectionType = detectBotProtection(response);
switch (protectionType) {
  case protectionCloudflare:
    print('Cloudflare detected');
    break;
  case protectionImunify360:
    print('Imunify360 detected');
    break;
  case protectionGeneric:
    print('Generic access denied');
    break;
  case protectionNone:
    print('No bot protection');
    break;
}
```

### Membuat Repository Baru

```dart
// 1. Buat model
class Product {
  final String id;
  final String name;
  final double price;

  Product({required this.id, required this.name, required this.price});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    price: (json['price'] as num).toDouble(),
  );
}

// 2. Buat repository
class ProductRepository extends BaseRepository {
  ProductRepository({required super.apiClient});

  /// Ambil semua produk
  Future<BaseResponse<List<Product>>> getProducts({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await get<Map<String, dynamic>>(
      '/products',
      queryParameters: {'page': page, 'limit': limit},
    );

    if (response.success && response.data != null) {
      final items = (response.data!['items'] as List)
          .map((e) => Product.fromJson(e))
          .toList();
      return BaseResponse.success(data: items);
    }
    return BaseResponse.error(message: response.message);
  }

  /// Ambil produk by ID
  Future<BaseResponse<Product>> getProductById(String id) async {
    return get<Product>(
      '/products/$id',
      parser: Product.fromJson,
    );
  }

  /// Buat produk baru
  Future<BaseResponse<Product>> createProduct({
    required String name,
    required double price,
  }) async {
    return post<Product>(
      '/products',
      data: {'name': name, 'price': price},
      parser: Product.fromJson,
    );
  }

  /// Update produk
  Future<BaseResponse<Product>> updateProduct(
    String id, {
    String? name,
    double? price,
  }) async {
    return patch<Product>(
      '/products/$id',
      data: {
        if (name != null) 'name': name,
        if (price != null) 'price': price,
      },
      parser: Product.fromJson,
    );
  }

  /// Hapus produk
  Future<BaseResponse<void>> deleteProduct(String id) async {
    return delete('/products/$id');
  }

  /// Upload gambar produk
  Future<BaseResponse<Product>> uploadProductImage(
    String id,
    String imagePath,
  ) async {
    return uploadFile<Product>(
      '/products/$id/image',
      filePath: imagePath,
      fieldName: 'image',
      parser: Product.fromJson,
    );
  }
}

// 3. Buat provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(apiClient: ref.watch(apiClientProvider));
});
```

### Penggunaan di Widget

```dart
class ProductListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productRepo = ref.watch(productRepositoryProvider);

    return FutureBuilder(
      future: productRepo.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error;
          if (error is ApiException) {
            return Text('Error: ${error.message}');
          }
          return Text('Unknown error');
        }

        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final response = snapshot.data!;
        if (!response.success) {
          return Text('Failed: ${response.message}');
        }

        final products = response.data ?? [];
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('\$${product.price}'),
            );
          },
        );
      },
    );
  }
}
```

---

## ⚠️ Error Handling

### ApiException

Semua network error dikonversi menjadi `ApiException`.

```dart
try {
  final response = await repository.getProducts();
  // Handle success
} on ApiException catch (e) {
  print('Message: ${e.message}');
  print('Status Code: ${e.statusCode}');
  print('Error Code: ${e.errorCode}');

  if (e.isAuthError) {
    // Redirect ke login
  } else if (e.isNetworkError) {
    // Tampilkan pesan "No internet"
  } else if (e.isServerError) {
    // Tampilkan pesan "Server error"
  }
}
```

### Error Types

| Property | Description |
|----------|-------------|
| `isAuthError` | Status 401 atau 403 |
| `isNetworkError` | Connection timeout atau error |
| `isServerError` | Status 5xx |
| `isClientError` | Status 4xx |

### Factory Methods

```dart
// Dari status code
final error = ApiException.fromStatusCode(404);

// No connection
final error = ApiException.noConnection();

// Timeout
final error = ApiException.timeout();

// Unknown
final error = ApiException.unknown('Something went wrong');
```

---

## 🔄 Retrofit API Service

### Definisi Endpoint

Edit `lib/core/network/services/api_service.dart`:

```dart
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @GET('/users')
  Future<HttpResponse<Map<String, dynamic>>> getUsers({
    @Query('page') int? page,
    @Query('limit') int? limit,
  });

  @GET('/users/{id}')
  Future<HttpResponse<Map<String, dynamic>>> getUserById(
    @Path('id') String id,
  );

  @POST('/users')
  Future<HttpResponse<Map<String, dynamic>>> createUser(
    @Body() Map<String, dynamic> body,
  );

  @PUT('/users/{id}')
  Future<HttpResponse<Map<String, dynamic>>> updateUser(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/users/{id}')
  Future<HttpResponse<void>> deleteUser(
    @Path('id') String id,
  );

  @POST('/upload')
  @MultiPart()
  Future<HttpResponse<Map<String, dynamic>>> uploadFile(
    @Part(name: 'file') List<int> file,
    @Part(name: 'filename') String filename,
  );
}
```

### Generate Code

Setelah mengubah `api_service.dart`, jalankan:

```bash
dart run build_runner build --delete-conflicting-outputs
```

### Penggunaan

```dart
// Buat instance
final apiService = ApiService(ref.watch(dioProvider));

// Panggil endpoint
final response = await apiService.getUsers(page: 1, limit: 20);
print('Status: ${response.response.statusCode}');
print('Data: ${response.data}');
```

---

## 📝 Best Practices

### ✅ DO

```dart
// 1. Gunakan repository pattern
final response = await userRepository.getProfile();

// 2. Extend BaseRequest untuk request dengan field shared
class MyRequest extends BaseRequest {
  @override
  Map<String, dynamic> toJson() => {...baseFields, 'field': value};
}

// 3. Handle error dengan ApiException
try {
  await repository.doSomething();
} on ApiException catch (e) {
  showError(e.message);
}

// 4. Gunakan providers untuk dependency injection
final repo = ref.watch(userRepositoryProvider);
```

### ❌ DON'T

```dart
// 1. Jangan passing headers manual di setiap request
// ❌ SALAH
dio.get('/users', options: Options(headers: {'Authorization': 'Bearer...'}));

// ✅ BENAR - Interceptor otomatis menambahkan headers
dio.get('/users');

// 2. Jangan buat instance Dio baru
// ❌ SALAH
final dio = Dio();

// ✅ BENAR - Gunakan provider
final dio = ref.watch(dioProvider);

// 3. Jangan handle error di setiap request
// ❌ SALAH
try {
  await dio.get('/users');
} on DioException catch (e) {
  // Handle setiap error
}

// ✅ BENAR - Gunakan BaseRepository yang sudah handle
final response = await repository.getUsers();
if (!response.success) {
  showError(response.message);
}
```

---

## 🔐 Token Storage

### Custom Implementation

Untuk production, gunakan secure storage:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage implements TokenStorage {
  final _storage = FlutterSecureStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    }
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
```

Gunakan di ApiClient:

```dart
final apiClient = ApiClient(
  tokenStorage: SecureTokenStorage(),
);
```

---

## 📊 Response Format

### Expected API Response Format

```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": {
    "id": "123",
    "name": "John Doe"
  },
  "meta": {
    "current_page": 1,
    "last_page": 10,
    "per_page": 20,
    "total": 200
  }
}
```

### Error Response Format

```json
{
  "success": false,
  "message": "Validation failed",
  "error_code": "VALIDATION_ERROR",
  "data": null
}
```

---

## 🧪 Testing

### Mock Repository

```dart
class MockUserRepository extends BaseRepository {
  MockUserRepository() : super(apiClient: ApiClient());

  @override
  Future<BaseResponse<User>> getProfile() async {
    return BaseResponse.success(
      data: User(
        id: '1',
        name: 'Test User',
        email: 'test@example.com',
      ),
    );
  }
}
```

### Override Provider

```dart
testWidgets('should display user profile', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(MockUserRepository()),
      ],
      child: MyApp(),
    ),
  );
});
```

---

## 📚 Referensi

- [Dio Documentation](https://pub.dev/packages/dio)
- [Retrofit Documentation](https://pub.dev/packages/retrofit)
- [Flutter Riverpod](https://riverpod.dev/)
- [Dio Cookie Manager](https://pub.dev/packages/dio_cookie_manager)
- [Cookie Jar](https://pub.dev/packages/cookie_jar)

---

*Dibuat: 4 Mei 2025*
*Diperbarui: 23 Januari 2026*
*Versi: 1.5.0*

