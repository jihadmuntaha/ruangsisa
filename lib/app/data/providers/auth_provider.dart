import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthProvider extends GetConnect {
  final String baseUrlAuth = "http://172.24.243.45:8000/auth";

  @override
  void onInit() {
    super.onInit();

    // ✅ TAMBAHKAN INTERCEPTOR UNTUK SEMUA REQUEST
    httpClient.addRequestModifier<dynamic>((request) async {
      final box = GetStorage();
      final token = await box.read('access_token');

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print("🔑 [INTERCEPTOR] Token ditambahkan ke header");
      }

      return request;
    });

    // ✅ TAMBAHKAN RESPONSE INTERCEPTOR UNTUK HANDLE 401
    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        print("⚠️ [INTERCEPTOR] Token expired! Logout otomatis");
        _handleLogout();
      }
      return response;
    });
  }

  void _handleLogout() async {
    final box = GetStorage();
    await box.remove('access_token');
    await box.remove('user');
    await box.remove('user_data');

    Get.offAllNamed('/login');
    Get.snackbar(
      "Sesi Habis",
      "Silakan login kembali",
      backgroundColor: Color.fromARGB(255, 220, 53, 69),
      colorText: Color.fromARGB(255, 255, 255, 255),
    );
  }

  // Fungsi lainnya tetap sama...
  Future<Response> registerUser(Map<String, dynamic> data) {
    return post('$baseUrlAuth/register', data);
  }

  Future<Response> loginUser(Map<String, dynamic> data) {
    return post('$baseUrlAuth/login', data);
  }

  Future<Response> loginWithGoogleProvider(Map<String, dynamic> data) async {
    final response = await post('$baseUrlAuth/google', data);
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    return response;
  }
}
