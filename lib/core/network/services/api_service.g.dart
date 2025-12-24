// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// NOTE: This is a placeholder file.
// Run the following command to generate the actual implementation:
//
//   dart run build_runner build --delete-conflicting-outputs
//
// This file will be overwritten with the actual generated code.

class _ApiService implements ApiService {
  _ApiService(this._dio, {this.baseUrl});

  final Dio _dio;
  String? baseUrl;

  @override
  Future<HttpResponse<Map<String, dynamic>>> login(
      Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/login', data: body);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> register(
      Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/register', data: body);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<void>> logout() async {
    final response = await _dio.post('/auth/logout');
    return HttpResponse(null, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> refreshToken(
      Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/refresh', data: body);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> forgotPassword(
      Map<String, dynamic> body) async {
    final response = await _dio.post('/auth/forgot-password', data: body);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> getProfile() async {
    final response = await _dio.get('/users/me');
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> updateProfile(
      Map<String, dynamic> body) async {
    final response = await _dio.patch('/users/me', data: body);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<void>> deleteAccount() async {
    final response = await _dio.delete('/users/me');
    return HttpResponse(null, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> getUserById(String id) async {
    final response = await _dio.get('/users/$id');
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> getUsers({
    int? page,
    int? limit,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (search != null) 'search': search,
    };
    final response = await _dio.get('/users', queryParameters: queryParameters);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> uploadAvatar(
      List<int> file, String filename) async {
    final formData = FormData.fromMap({
      'avatar': MultipartFile.fromBytes(file, filename: filename),
      'filename': filename,
    });
    final response = await _dio.post('/users/me/avatar', data: formData);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> getItems({
    int? page,
    int? limit,
    String? category,
  }) async {
    final queryParameters = <String, dynamic>{
      if (page != null) 'page': page,
      if (limit != null) 'limit': limit,
      if (category != null) 'category': category,
    };
    final response = await _dio.get('/items', queryParameters: queryParameters);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> getItemById(String id) async {
    final response = await _dio.get('/items/$id');
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> createItem(
      Map<String, dynamic> body) async {
    final response = await _dio.post('/items', data: body);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<Map<String, dynamic>>> updateItem(
      String id, Map<String, dynamic> body) async {
    final response = await _dio.put('/items/$id', data: body);
    return HttpResponse(response.data, response);
  }

  @override
  Future<HttpResponse<void>> deleteItem(String id) async {
    final response = await _dio.delete('/items/$id');
    return HttpResponse(null, response);
  }
}
