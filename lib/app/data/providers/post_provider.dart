import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:ruang_sisa/app_config.dart';

class PostProvider extends GetConnect {
  final String baseUrlAddress = "${AppConfig.baseUrl}/api";

  @override
  void onInit() {
    httpClient.baseUrl = baseUrlAddress;
    httpClient.timeout = const Duration(seconds: 30);

    httpClient.addRequestModifier<dynamic>((request) async {
      final box = GetStorage();
      String? token = await box.read('access_token');

      request.headers['Accept'] = 'application/json';

      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      return request;
    });

    super.onInit();
  }

  // ✅ GET POSTS - Perbaiki tanpa mengubah body langsung
  Future<Response> getPosts({int? categoryId, String? search}) async {
    try {
      Map<String, dynamic> query = {};
      if (categoryId != null) query['category_id'] = categoryId.toString();
      if (search != null) query['search'] = search;

      final response = await get('/posts', query: query);
      print("📡 [GET POSTS] Status: ${response.statusCode}");

      // ✅ Jika response body adalah Map dengan key 'data', ambil datanya
      if (response.statusCode == 200 && response.body != null) {
        if (response.body is Map && response.body['data'] is List) {
          // ✅ Buat response baru dengan body yang sudah diproses
          return Response(
            statusCode: response.statusCode,
            statusText: response.statusText,
            body: response.body['data'], // ← Ambil data-nya
          );
        }
      }

      return response;
    } catch (e) {
      print("❌ Error: $e");
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  // 📦 GET CATEGORIES
  Future<Response> getCategories() async {
    try {
      final response = await get('/categories');
      print("📡 [GET CATEGORIES] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      print("❌ Error: $e");
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  // 📤 CREATE POST
  Future<Response> createPost(
    Map<String, String> fields,
    String imagePath,
  ) async {
    try {
      final box = GetStorage();
      String? token = await box.read('access_token');

      Map<String, String> headers = {'Accept': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // Buat FormData
      // 🟢 UBAY PARADIGMA: Kirim string URL, bukan file fisik lagi!
      var formData = FormData({
        'title': fields['title'] ?? '',
        'description': fields['description'] ?? '',
        'user_id': fields['user_id'] ?? '',
        'post_type': fields['post_type'] ?? '',
        'category_id': fields['category_id'] ?? '',

        // 🟢 Ganti 'image' MultipartFile menjadi field string 'image_url' biasa
        'image_url': imagePath,
      });

      // Tambah field opsional
      if (fields.containsKey('price')) {
        formData.fields.add(MapEntry('price', fields['price']!));
      }
      if (fields.containsKey('barter_wishlist')) {
        formData.fields.add(
          MapEntry('barter_wishlist', fields['barter_wishlist']!),
        );
      }

      final response = await post('/posts', formData, headers: headers);
      print("📡 [CREATE POST] Status: ${response.statusCode}");

      return response;
    } catch (e) {
      print("❌ Error: $e");
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  // 💬 GET COMMENTS
  Future<Response> getComments(int postId) async {
    try {
      final response = await get('/posts/$postId/comments');
      print("💬 [GET COMMENTS] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      print("❌ Error: $e");
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  // 📝 SEND COMMENT - Perbaiki format data
  Future<Response> sendComment(Map<String, dynamic> data) async {
    try {
      final box = GetStorage();
      String? token = await box.read('access_token');

      Map<String, String> headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // ✅ Buat FormData, bukan Map biasa
      final formData = FormData({
        'post_id': data['post_id'].toString(),
        'user_id': data['user_id'].toString(),
        'content': data['content'].toString(),
      });

      print("📝 [SEND COMMENT] Sending: ${formData.fields}");

      final response = await post(
        '/posts/comments',
        formData,
        headers: headers,
      );
      print("📝 [SEND COMMENT] Status: ${response.statusCode}");
      print("📝 [SEND COMMENT] Body: ${response.body}");
      return response;
    } catch (e) {
      print("❌ Error send comment: $e");
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  // 🗑️ DELETE COMMENT
  Future<Response> deleteComment(int commentId, int userId) async {
    try {
      final box = GetStorage();
      String? token = await box.read('access_token');

      Map<String, String> headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final response = await delete(
        '/posts/comments/$commentId',
        headers: headers,
        query: {'user_id': userId.toString()},
      );
      print("🗑️ [DELETE COMMENT] Status: ${response.statusCode}");
      return response;
    } catch (e) {
      print("❌ Error: $e");
      return Response(statusCode: 500, statusText: e.toString());
    }
  }
}
