import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'api_service.g.dart';

/// Retrofit API Service
/// Type-safe API definitions with code generation
/// 
/// After modifications, run:
/// dart run build_runner build --delete-conflicting-outputs
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // ============================================
  // AUTH ENDPOINTS
  // ============================================

  @POST('/auth/login')
  Future<HttpResponse<Map<String, dynamic>>> login(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/register')
  Future<HttpResponse<Map<String, dynamic>>> register(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/logout')
  Future<HttpResponse<void>> logout();

  @POST('/auth/refresh')
  Future<HttpResponse<Map<String, dynamic>>> refreshToken(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/forgot-password')
  Future<HttpResponse<Map<String, dynamic>>> forgotPassword(
    @Body() Map<String, dynamic> body,
  );

  // ============================================
  // USER ENDPOINTS
  // ============================================

  @GET('/users/me')
  Future<HttpResponse<Map<String, dynamic>>> getProfile();

  @PATCH('/users/me')
  Future<HttpResponse<Map<String, dynamic>>> updateProfile(
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/users/me')
  Future<HttpResponse<void>> deleteAccount();

  @GET('/users/{id}')
  Future<HttpResponse<Map<String, dynamic>>> getUserById(
    @Path('id') String id,
  );

  @GET('/users')
  Future<HttpResponse<Map<String, dynamic>>> getUsers({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('search') String? search,
  });

  // ============================================
  // FILE UPLOAD ENDPOINTS
  // ============================================

  @POST('/users/me/avatar')
  @MultiPart()
  Future<HttpResponse<Map<String, dynamic>>> uploadAvatar(
    @Part(name: 'avatar') List<int> file,
    @Part(name: 'filename') String filename,
  );

  // ============================================
  // GENERIC ENDPOINTS (Example)
  // ============================================

  @GET('/items')
  Future<HttpResponse<Map<String, dynamic>>> getItems({
    @Query('page') int? page,
    @Query('limit') int? limit,
    @Query('category') String? category,
  });

  @GET('/items/{id}')
  Future<HttpResponse<Map<String, dynamic>>> getItemById(
    @Path('id') String id,
  );

  @POST('/items')
  Future<HttpResponse<Map<String, dynamic>>> createItem(
    @Body() Map<String, dynamic> body,
  );

  @PUT('/items/{id}')
  Future<HttpResponse<Map<String, dynamic>>> updateItem(
    @Path('id') String id,
    @Body() Map<String, dynamic> body,
  );

  @DELETE('/items/{id}')
  Future<HttpResponse<void>> deleteItem(
    @Path('id') String id,
  );
}
