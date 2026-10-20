import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_app/core/auth/carik_auth_provider.dart';
import 'package:super_app/core/auth/token_refresh_service.dart';

/// Server Carik palsu: mencatat request dan menjawab dengan envelope `{ success, data | error }`.
class _FakeCarik implements HttpClientAdapter {
  final List<RequestOptions> requests = [];
  final Map<String, (int, Map<String, dynamic>)> routes = {};

  void on(String method, String path, int status, Map<String, dynamic> body) {
    routes['$method $path'] = (status, body);
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final hit = routes['${options.method} ${options.uri.path}'];
    final (status, body) = hit ?? (404, {'success': false, 'error': {'code': 'not_found', 'message': 'nope'}});
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _grant(String token) => {
  'success': true,
  'data': {
    'accessToken': token,
    'tokenType': 'Bearer',
    'expiresAt': '2026-10-20T10:00:00.000Z',
    'refreshExpiresAt': '2026-10-21T22:00:00.000Z',
    'clientId': 'tenant-1',
    'user': {
      'id': 'user-1',
      'email': 'test@example.id',
      'name': 'Test User',
      'avatarUrl': '/v1/files/avatar-1',
      'emailVerifiedAt': '2026-10-01T00:00:00.000Z',
    },
  },
};

const _csrf = 'C1234567890123456789012345678901234567890ab';
const _base = 'https://carik.example.id';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _FakeCarik server;
  late CarikAuthProvider auth;

  setUp(() async {
    dotenv.testLoad(fileInput: 'APP_NAME=Test App\nCARIK_API_BASE_URL=$_base\n');
    SharedPreferences.setMockInitialValues({});
    server = _FakeCarik()
      ..on('GET', '/v1/auth/csrf-token', 200, {
        'success': true,
        'data': {'token': _csrf},
      });
    final dio = Dio(BaseOptions(validateStatus: (_) => true))..httpClientAdapter = server;
    auth = CarikAuthProvider(baseUrl: '$_base/', dio: dio);
    // Biarkan _loadSavedUser selesai.
    await Future<void>.delayed(Duration.zero);
  });

  test('sign-in sends the CSRF pair with our Origin and maps the grant', () async {
    server.on('POST', '/v1/auth/token', 200, _grant('tok-1'));
    final result = await auth.signInWithEmailAndPassword(email: ' test@example.id ', password: 'pw');

    expect(result.success, isTrue);
    final login = server.requests.firstWhere((r) => r.uri.path == '/v1/auth/token');
    expect(login.headers['Origin'], _base);
    expect(login.headers['Cookie'], 'crk_csrf=$_csrf');
    expect(login.headers['x-csrf-token'], _csrf);
    final body = login.data as Map<String, dynamic>;
    expect(body['email'], 'test@example.id');
    expect(body['device'], contains('Test App'));

    final user = auth.currentUser!;
    expect(user.uid, 'user-1');
    expect(user.displayName, 'Test User');
    expect(user.photoUrl, '$_base/v1/files/avatar-1');
    expect(user.isEmailVerified, isTrue);
    expect(auth.accessToken, 'tok-1');

    // Disimpan di kunci yang dibaca TokenRefreshService dan modul.
    final prefs = await SharedPreferences.getInstance();
    final saved = jsonDecode(prefs.getString('app_saved_user')!) as Map<String, dynamic>;
    expect(saved['jwt'], 'tok-1');
  });

  test('server errors surface their message; 2FA accounts are refused clearly', () async {
    server.on('POST', '/v1/auth/token', 401, {
      'success': false,
      'error': {'code': 'invalid_credentials', 'message': 'Email atau kata sandi salah'},
    });
    var result = await auth.signInWithEmailAndPassword(email: 'x@y.id', password: 'bad');
    expect(result.success, isFalse);
    expect(result.errorMessage, 'Email atau kata sandi salah');

    server.on('POST', '/v1/auth/token', 200, {
      'success': true,
      'data': {'mfaRequired': true, 'challenge': 'c'},
    });
    result = await auth.signInWithEmailAndPassword(email: 'x@y.id', password: 'pw');
    expect(result.success, isFalse);
    expect(result.errorMessage, contains('2FA'));
    expect(auth.currentUser, isNull);
  });

  test('refresh goes through TokenRefreshService and keeps the token', () async {
    server.on('POST', '/v1/auth/token', 200, _grant('tok-1'));
    await auth.signInWithEmailAndPassword(email: 'test@example.id', password: 'pw');
    server.on('POST', '/v1/auth/token/refresh', 200, _grant('tok-1'));

    final fresh = await TokenRefreshService.instance.refreshToken(currentJwt: 'tok-1');
    expect(fresh, 'tok-1');
    final call = server.requests.lastWhere((r) => r.uri.path == '/v1/auth/token/refresh');
    expect(call.headers['Authorization'], 'Bearer tok-1');
  });

  test('a refresh past the window signs the user out', () async {
    server.on('POST', '/v1/auth/token', 200, _grant('tok-1'));
    await auth.signInWithEmailAndPassword(email: 'test@example.id', password: 'pw');
    server.on('POST', '/v1/auth/token/refresh', 401, {
      'success': false,
      'error': {
        'code': 'token_expired',
        'message': 'Sesi berakhir — masuk lagi',
        'details': {'reason': 'refresh_expired'},
      },
    });
    server.on('DELETE', '/v1/auth/token', 401, {
      'success': false,
      'error': {'code': 'unauthorized', 'message': 'x'},
    });

    expect(await auth.refreshAccessToken(), isNull);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(auth.currentUser, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('app_is_logged_in'), isFalse);
  });

  test('profile and password calls use the bearer token', () async {
    server.on('POST', '/v1/auth/token', 200, _grant('tok-1'));
    await auth.signInWithEmailAndPassword(email: 'test@example.id', password: 'pw');
    server.on('PUT', '/v1/users/profile/me', 200, {
      'success': true,
      'data': {
        'user': {'id': 'user-1', 'email': 'test@example.id', 'name': 'Renamed', 'avatarUrl': null},
      },
    });
    server.on('PUT', '/v1/users/profile/password', 200, {
      'success': true,
      'data': {'changed': true, 'revokedOtherSessions': 0},
    });

    final profile = await auth.updateProfile(displayName: 'Renamed');
    expect(profile.success, isTrue);
    expect(auth.currentUser!.displayName, 'Renamed');
    expect(auth.accessToken, 'tok-1');

    final pw = await auth.changePassword(currentPassword: 'old', newPassword: 'new password 123');
    expect(pw.success, isTrue);
    final call = server.requests.lastWhere((r) => r.uri.path == '/v1/users/profile/password');
    expect(call.headers['Authorization'], 'Bearer tok-1');
    expect(call.data, {'currentPassword': 'old', 'newPassword': 'new password 123'});
  });

  test('sign-out revokes the token on the server and clears the session', () async {
    server.on('POST', '/v1/auth/token', 200, _grant('tok-1'));
    await auth.signInWithEmailAndPassword(email: 'test@example.id', password: 'pw');
    server.on('DELETE', '/v1/auth/token', 200, {
      'success': true,
      'data': {'loggedOut': true},
    });

    await auth.signOut();
    final call = server.requests.lastWhere((r) => r.method == 'DELETE');
    expect(call.headers['Authorization'], 'Bearer tok-1');
    expect(auth.currentUser, isNull);
  });

  test('live: against a real Carik server (CARIK_LIVE_URL)', () async {
    final url = Platform.environment['CARIK_LIVE_URL'];
    final email = Platform.environment['CARIK_LIVE_EMAIL'];
    final password = Platform.environment['CARIK_LIVE_PASSWORD'];
    if (url == null || email == null || password == null) {
      markTestSkipped('set CARIK_LIVE_URL, CARIK_LIVE_EMAIL and CARIK_LIVE_PASSWORD');
      return;
    }
    // flutter_test blocks real HTTP by default; this test opts out on purpose.
    HttpOverrides.global = null;
    final live = CarikAuthProvider(
      baseUrl: url,
      dio: Dio(BaseOptions(validateStatus: (_) => true)),
    );
    final result = await live.signInWithEmailAndPassword(email: email, password: password);
    expect(result.success, isTrue, reason: result.errorMessage);
    final token = live.accessToken!;
    expect(await live.refreshAccessToken(), token);
    final renamed = await live.updateProfile(displayName: 'Live Test');
    expect(renamed.success, isTrue, reason: renamed.errorMessage);
    await live.signOut();
    expect(live.currentUser, isNull);
    // The revoked token no longer refreshes.
    final after = await Dio(BaseOptions(validateStatus: (_) => true)).post(
      '$url/v1/auth/token/refresh',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    expect(after.statusCode, 401);
  });
}
