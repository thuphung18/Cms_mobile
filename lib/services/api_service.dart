import 'package:cms_mobile/Dto/PostDto.dart';
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
        baseUrl: 'http://192.168.1.110:5000/', // local host
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

  //login

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'api/admin/auth',
        data: {'username': username, 'password': password},
      );

      final isSuccess =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (isSuccess) {
        final result = AuthenticatedResult.fromJson(response.data);

        if (result.token != null && result.token!.isNotEmpty) {
          await _storage.write(key: 'access_token', value: result.token);

          await _storage.write(
            key: 'refresh_token',
            value: result.refreshToken,
          );

          print("LOGIN SUCCESS");
          return true;
        }
      }

      print("LOGIN FAILED");
      return false;
    } catch (e) {
      print("LOGIN ERROR: $e");
      return false;
    }
  }
  // Hàm lấy chi tiết bài viết dành riêng cho Admin (Gọi endpoint của Admin - Không tăng view)
  Future<PostDto?> getAdminPostById(String id) async {
    try {
      final response = await _dio.get('api/admin/posts/$id');
      if (response.statusCode == 200) {
        return PostDto.fromJson(response.data);
      }
    } catch (e) {
      print("LỖI LẤY CHI TIẾT ADMIN: $e");
    }
    return null;
  }

  // user public get
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
          'categoryId': ?categoryId,
          'pageIndex': pageIndex,
          'pageSize': pageSize,
        },
      );

      final isSuccess =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (isSuccess) {
        return PostPagingResult.fromJson(response.data);
      }
    } catch (e) {
      print("GET POSTS ERROR: $e");
    }

    return null;
  }

  // get post Admin

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

      final isSuccess =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      if (isSuccess) {
        return PostPagingResult.fromJson(response.data);
      }
    } catch (e) {
      print(" GET ADMIN POSTS ERROR: $e");
    }

    return null;
  }

  //delete post

  Future<bool> deletePost(String id) async {
    try {
      final response = await _dio.delete(
        'api/admin/posts',
        queryParameters: {'ids': id},
        options: Options(listFormat: ListFormat.multi),
      );

      final isSuccess =
          response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;

      print("DELETE RESULT: $isSuccess");

      return isSuccess;
    } catch (e) {
      print("DELETE POST ERROR: $e");
      return false;
    }
  }
  // Hàm lấy chi tiết bài viết bằng ID dành cho user
  Future<PostDto?> getPostById(String id) async{
    try{
      // dùng $ để chèn giá trị  của id vào url path
      final respone= await _dio.get(
        'api/posts/$id'

      );
      // kieemr tra nếu trạng thái HTTP thành công 200
      final isSuccess=respone.statusCode!=null&&
    respone.statusCode!>=200&&respone.statusCode!<300;
      if(isSuccess)
        {
          return PostDto.fromJson(respone.data);
        }
    }
    catch(e){
      print("lỗi tải chi tiết bài viêt $e");
    }
    // trả về null nếu xảy ra lỗi mạng || lỗi hệ thống
    return null;
  }

  //create post
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
      final String safeCategoryId =
          (categoryId == null || categoryId.trim().isEmpty)
          ? '00000000-0000-0000-0000-000000000000'
          : categoryId.trim();

      // Không bọc đối tượng request nữa
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

      print(" HTTP STATUS CODE TẠO BÀI VIẾT: ${response.statusCode}");
      return response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300;
    } catch (e) {
      print("LỖI GẶP PHẢI KHI GỌI API: $e");
      return false;
    }
  }
  //token

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }
}
