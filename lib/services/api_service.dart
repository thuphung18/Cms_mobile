import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/auth_model.dart';
import '../models/post_model.dart';

class ApiService {
  late final Dio _dio;

  final _storage = const FlutterSecureStorage();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://quartered-monthly-unable.ngrok-free.dev/',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print("========== REQUEST ==========");
          print("METHOD: ${options.method}");
          print("URL: ${options.uri}");
          print("HEADERS: ${options.headers}");
          print("DATA: ${options.data}");
          print("=============================");

          return handler.next(options);
        },

        onResponse: (response, handler) {
          print("========== RESPONSE ==========");
          print("STATUS CODE: ${response.statusCode}");
          print("DATA: ${response.data}");
          print("==============================");

          return handler.next(response);
        },

        onError: (DioException e, handler) {
          print("========== DIO ERROR ==========");
          print("TYPE: ${e.type}");
          print("MESSAGE: ${e.message}");
          print("STATUS: ${e.response?.statusCode}");
          print("DATA: ${e.response?.data}");
          print("===============================");

          return handler.next(e);
        },
      ),
    );
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'api/admin/auth',
        data: {
          'username': username,
          'password': password,
        },
      );

      final isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (isSuccess) {
        final result = AuthenticatedResult.fromJson(response.data);

        if (result.token != null && result.token!.isNotEmpty) {
          await _storage.write(
            key: 'access_token',
            value: result.token,
          );

          await _storage.write(
            key: 'refresh_token',
            value: result.refreshToken,
          );

          print("✅ LOGIN SUCCESS");
          return true;
        }
      }

      print("❌ LOGIN FAILED");
      return false;

    } catch (e) {
      print("❌ LOGIN ERROR: $e");
      return false;
    }
  }

  // =========================================================
  // GET PUBLIC POSTS
  // =========================================================

  Future<PostPagingResult?> getPostsPaging({
    String keyword = '',
    String? categoryId,
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        'api/posts/paging',
        queryParameters: {
          'keyword': keyword,
          if (categoryId != null) 'categoryId': categoryId,
          'pageIndex': pageIndex,
          'pageSize': pageSize,
        },
      );

      final isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (isSuccess) {
        return PostPagingResult.fromJson(response.data);
      }

    } catch (e) {
      print("❌ GET POSTS ERROR: $e");
    }

    return null;
  }

  // =========================================================
  // GET ADMIN POSTS
  // =========================================================

  Future<PostPagingResult?> getAdminPostsPaging({
    String keyword = '',
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.get(
        'api/admin/posts/paging',
        queryParameters: {
          'keyword': keyword,
          'pageIndex': pageIndex,
          'pageSize': pageSize,
        },
      );

      final isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (isSuccess) {
        return PostPagingResult.fromJson(response.data);
      }

    } catch (e) {
      print("❌ GET ADMIN POSTS ERROR: $e");
    }

    return null;
  }

  // =========================================================
  // DELETE POST
  // =========================================================

  Future<bool> deletePost(String id) async {
    try {
      final response = await _dio.delete(
        'api/admin/posts',
        queryParameters: {
          'ids': id,
        },
        options: Options(
          listFormat: ListFormat.multi,
        ),
      );

      final isSuccess = response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      print("🗑 DELETE RESULT: $isSuccess");

      return isSuccess;

    } catch (e) {
      print("❌ DELETE POST ERROR: $e");
      return false;
    }
  }

  // =========================================================
  // CREATE POST
  // =========================================================
// 5. Hàm Tạo mới bài viết dành cho Admin (Cấu trúc Flat JSON chuẩn hóa)
  Future<bool> createPost({
    required String name,
    required String slug,
    required String description,
    String? thumbnail,
    String? content,
    String? categoryId,
    String? source,
    String? tag,
    String? seoDescription,
  }) async {
    try {
      // Ép về chuỗi định dạng Guid rỗng thay vì truyền null để .NET Core không báo lỗi chuyển đổi hệ thống
      final String safeCategoryId = (categoryId == null || categoryId.trim().isEmpty)
          ? '00000000-0000-0000-0000-000000000000'
          : categoryId.trim();

      // Đưa dữ liệu về dạng phẳng (Không bọc đối tượng request nữa)
      final response = await _dio.post(
        'api/admin/posts',
        data: {
          'name': name,
          'slug': slug,
          'description': description,
          'thumbnail': thumbnail,
          'content': content,
          'categoryId': safeCategoryId, // Đảm bảo truyền chuỗi Guid thực tế
          'source': source,
          'tag': tag,
          'seoDescription': seoDescription,
        },
      );

      print("📊 HTTP STATUS CODE TẠO BÀI VIẾT: ${response.statusCode}");
      return response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300;
    } catch (e) {
      print("❌ LỖI GẶP PHẢI KHI GỌI API: $e");
      return false;
    }

  }
  // =========================================================
  // TOKEN
  // =========================================================

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}