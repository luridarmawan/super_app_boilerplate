import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api_client.dart';
import '../repository/base_repository.dart';
import '../models/base_response.dart';
import '../models/base_request.dart';

/// Example: User Model
class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar': avatar,
      };
}

/// Example: Login Request
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
        ...baseFields,
        'email': email,
        'password': password,
      };
}

/// Example: User Repository
/// Demonstrates how to extend BaseRepository
class UserRepository extends BaseRepository {
  UserRepository({required super.apiClient});

  /// Get current user profile
  Future<BaseResponse<User>> getProfile() async {
    return get<User>(
      '/users/me',
      parser: User.fromJson,
    );
  }

  /// Get user by ID
  Future<BaseResponse<User>> getUserById(String id) async {
    return get<User>(
      '/users/$id',
      parser: User.fromJson,
    );
  }

  /// Login
  Future<BaseResponse<User>> login(LoginRequest request) async {
    return post<User>(
      '/auth/login',
      data: request.toJson(),
      parser: User.fromJson,
      skipAuth: true, // Login doesn't need auth header
    );
  }

  /// Register
  Future<BaseResponse<User>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return post<User>(
      '/auth/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
      },
      parser: User.fromJson,
      skipAuth: true,
    );
  }

  /// Update profile
  Future<BaseResponse<User>> updateProfile({
    String? name,
    String? avatar,
  }) async {
    return patch<User>(
      '/users/me',
      data: {
        if (name != null) 'name': name,
        if (avatar != null) 'avatar': avatar,
      },
      parser: User.fromJson,
    );
  }

  /// Upload avatar
  Future<BaseResponse<User>> uploadAvatar(String filePath) async {
    return uploadFile<User>(
      '/users/me/avatar',
      filePath: filePath,
      fieldName: 'avatar',
      parser: User.fromJson,
    );
  }

  /// Delete account
  Future<BaseResponse<void>> deleteAccount() async {
    return delete('/users/me');
  }
}

/// User Repository Provider
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(apiClient: ref.watch(apiClientProvider));
});
