import 'package:get/get.dart';

class PostProvider extends GetConnect {
  // 🌟 Ganti dengan IP IPv4 laptop lu hasil dari ipconfig CMD tadi!
  final String baseUrlAddress = "http://192.168.1.5:8000/api";

  @override
  void onInit() {
    httpClient.baseUrl = baseUrlAddress;
    httpClient.timeout = const Duration(seconds: 10);

    // Satpam Interceptor: Otomatis nempel token kalau user udah login
    httpClient.addRequestModifier<dynamic>((request) {
      request.headers['Accept'] = 'application/json';
      return request;
    });
    super.onInit();
  }

  // 📦 Ambil Feed Postingan Beranda
  Future<Response> getPosts({int? categoryId, String? search}) async {
    Map<String, dynamic> query = {};
    if (categoryId != null) query['category_id'] = categoryId.toString();
    if (search != null) query['search'] = search;
    return await get('/posts', query: query);
  }

  // 📤 Buat Postingan Barang Baru (Menu Add Post)
  Future<Response> uploadPost(Map<String, dynamic> data) async {
    return await post('/posts', data);
  }

  // 💬 Ambil List Komentar Nego per Postingan
  Future<Response> getComments(int postId) async {
    return await get('/posts/$postId/comments');
  }

  // 📝 Kirim Komentar Nego Terbuka
  Future<Response> sendComment(Map<String, dynamic> data) async {
    return await post('/posts/comments', data);
  }
}
