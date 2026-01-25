import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth_interface.dart';
import '../constants/app_info.dart';

/// Singleton service untuk refresh JWT token
/// Bisa diakses dari mana saja (main app, modules, dll)
class TokenRefreshService {
  // Singleton instance
  static final TokenRefreshService _instance = TokenRefreshService._internal();
  static TokenRefreshService get instance => _instance;

  TokenRefreshService._internal();

  // Mutex flag untuk mencegah concurrent refresh
  bool _isRefreshing = false;

  // Callback untuk update token di auth provider
  void Function(String newJwt)? _onTokenRefreshed;

  /// Set callback yang dipanggil ketika token berhasil di-refresh
  void setOnTokenRefreshed(void Function(String newJwt) callback) {
    _onTokenRefreshed = callback;
  }

  /// Cek apakah sedang dalam proses refresh
  bool get isRefreshing => _isRefreshing;

  /// Refresh JWT token yang sudah expired
  ///
  /// Returns new JWT jika berhasil, null jika gagal
  ///
  /// Parameter [currentJwt] adalah token yang akan di-refresh.
  /// Jika null, akan mencoba mengambil dari SharedPreferences.
  Future<String?> refreshToken({String? currentJwt}) async {
    // Mutex protection: prevent concurrent token refresh
    if (_isRefreshing) {
      debugPrint('[TOKEN-REFRESH] Token refresh already in progress, skipping...');
      return null;
    }

    _isRefreshing = true;
    debugPrint('[TOKEN-REFRESH] ============================================');
    debugPrint('[TOKEN-REFRESH] >>> Starting Token Refresh');

    try {
      // Jika currentJwt tidak diberikan, ambil dari SharedPreferences
      String? jwt = currentJwt;
      if (jwt == null || jwt.isEmpty) {
        jwt = await _getStoredJwt();
      }

      if (jwt == null || jwt.isEmpty) {
        debugPrint('[TOKEN-REFRESH] ERROR: No current JWT token to refresh');
        return null;
      }

      // Build URL - support both AppInfo constant and env variable
      String refreshUrl = AppInfo.authRefreshTokenUrl;
      if (refreshUrl.isEmpty) {
        refreshUrl = dotenv.env['AUTH_TOKEN_REFRESH_URL'] ?? '';
      }

      if (refreshUrl.isEmpty) {
        debugPrint('[TOKEN-REFRESH] ERROR: AUTH_TOKEN_REFRESH_URL not configured');
        return null;
      }

      // Replace {JWT} placeholder with actual token
      refreshUrl = refreshUrl.replaceAll('{JWT}', jwt);

      // Get method from AppInfo or env
      String method = AppInfo.authRefreshTokenMethod;
      if (method.isEmpty) {
        method = dotenv.env['AUTH_TOKEN_REFRESH_METHOD'] ?? 'POST';
      }
      method = method.toUpperCase();

      debugPrint('[TOKEN-REFRESH] URL: $refreshUrl');
      debugPrint('[TOKEN-REFRESH] Method: $method');

      final dio = Dio();
      Response response;

      final headers = <String, dynamic>{
        'Authorization': 'Bearer $jwt',
        'Accept': 'application/json',
      };

      // Make request based on configured method
      if (method == 'GET') {
        response = await dio.get(
          refreshUrl,
          options: Options(headers: headers),
        );
      } else {
        // Default: POST
        headers['Content-Type'] = 'application/json';
        response = await dio.post(
          refreshUrl,
          options: Options(headers: headers),
          data: {'jwt': jwt},
        );
      }

      debugPrint('[TOKEN-REFRESH] Response Status: ${response.statusCode}');
      debugPrint('[TOKEN-REFRESH] Response Data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data as Map<String, dynamic>;

        // Extract new JWT from response - support various structures
        String? newJwt;
        if (responseData.containsKey('data') && responseData['data'] is Map) {
          final data = responseData['data'] as Map<String, dynamic>;
          newJwt = data['jwt']?.toString() ??
              data['token']?.toString() ??
              data['access_token']?.toString();
        }
        newJwt ??= responseData['jwt']?.toString() ??
            responseData['token']?.toString() ??
            responseData['access_token']?.toString();

        if (newJwt != null && newJwt.isNotEmpty) {
          debugPrint('[TOKEN-REFRESH] New JWT obtained (${newJwt.length} chars)');

          // Update stored token
          await _updateStoredToken(newJwt);

          // Notify callback if set
          if (_onTokenRefreshed != null) {
            _onTokenRefreshed!(newJwt);
          }

          debugPrint('[TOKEN-REFRESH] <<< Token refresh SUCCESS');
          debugPrint('[TOKEN-REFRESH] ============================================');
          return newJwt;
        }
      }

      debugPrint('[TOKEN-REFRESH] ERROR: Failed to extract new JWT from response');
      return null;
    } on DioException catch (e) {
      debugPrint('[TOKEN-REFRESH] DIO ERROR: ${e.type}');
      debugPrint('[TOKEN-REFRESH] Message: ${e.message}');
      if (e.response != null) {
        debugPrint('[TOKEN-REFRESH] Status: ${e.response?.statusCode}');
        debugPrint('[TOKEN-REFRESH] Data: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      debugPrint('[TOKEN-REFRESH] ERROR: $e');
      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Get stored JWT from SharedPreferences
  Future<String?> _getStoredJwt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('app_saved_user');

      if (savedUserJson != null && savedUserJson.isNotEmpty) {
        final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
        return userMap['jwt'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('[TOKEN-REFRESH] Error getting stored JWT: $e');
      return null;
    }
  }

  /// Update stored JWT token in SharedPreferences
  Future<void> _updateStoredToken(String newJwt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('app_saved_user');

      if (savedUserJson != null && savedUserJson.isNotEmpty) {
        final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
        userMap['jwt'] = newJwt;
        await prefs.setString('app_saved_user', jsonEncode(userMap));
        debugPrint('[TOKEN-REFRESH] Stored token updated in SharedPreferences');
      }
    } catch (e) {
      debugPrint('[TOKEN-REFRESH] Error updating stored token: $e');
    }
  }

  /// Get current stored user with updated JWT
  Future<AuthUser?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserJson = prefs.getString('app_saved_user');

      if (savedUserJson != null && savedUserJson.isNotEmpty) {
        final userMap = jsonDecode(savedUserJson) as Map<String, dynamic>;
        return AuthUser.fromJson(userMap);
      }
      return null;
    } catch (e) {
      debugPrint('[TOKEN-REFRESH] Error getting stored user: $e');
      return null;
    }
  }
}
