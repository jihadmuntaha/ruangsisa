import 'package:flutter/material.dart'; // ◄ 1. FIXED: Ganti ke material.dart biar Color & Snackbar aman
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthProvider extends GetConnect {
  // 🟢 2. FIXED: Satukan kiblat alamat IP laptop lu ke satu variabel global provider
  final String baseUrlAuth = "http://10.20.166.45:8000/auth";

  @override
  void onInit() {
    super.onInit();

    // Set default baseUrl bawaan GetConnect biar panggil rutenya gak usah ditulis panjang lagi
    baseUrl = baseUrlAuth;

    // ✅ INTERCEPTOR UNTUK SEMUA REQUEST (Suntik Token Otomatis)
    httpClient.addRequestModifier<dynamic>((request) async {
      final box = GetStorage();
      final token = box.read(
        'access_token',
      ); // Gak perlu pake 'await' untuk GetStorage biasa

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
        print("🔑 [INTERCEPTOR] Token Bearer otomatis disuntikkan ke header");
      }
      return request;
    });

    // ✅ RESPONSE INTERCEPTOR UNTUK HANDLE 401 (Auto Logout)
    // Di AuthProvider - tambahkan di response interceptor
    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        print("⚠️ [INTERCEPTOR] Token expired atau tidak valid!");

        // Coba refresh token atau logout
        final box = GetStorage();
        final refreshToken = box.read('refresh_token');

        if (refreshToken != null) {
          // Coba refresh token (jika ada endpoint refresh)
          // _refreshToken(refreshToken);
        } else {
          // Logout otomatis
          _handleLogout();
        }
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
      backgroundColor: const Color.fromARGB(255, 220, 53, 69),
      colorText: const Color.fromARGB(255, 255, 255, 255),
    );
  }

  // 📡 =============== ENDPOINT ROUTER PIPELINES ===============

  Future<Response> registerUser(Map<String, dynamic> data) {
    return post('$baseUrlAuth/register', data);
  }

  Future<Response> loginUser(Map<String, dynamic> data) {
    return post('$baseUrlAuth/login', data);
  }

  Future<Response> loginWithGoogleProvider(Map<String, dynamic> data) async {
    final response = await post('$baseUrlAuth/google', data);
    print("📡 [GOOGLE PROVIDER] STATUS: ${response.statusCode}");
    print("📡 [GOOGLE PROVIDER] BODY: ${response.body}");
    return response;
  }

  // 🟢 FIXED TOTAL: Buang semua variabel URL lengkap, CUKUP BUNTUTNYA DOANG!
  Future<Response> verifyOtpProvider(Map<String, dynamic> payload) async {
    print("📡 [PROVIDER OTP] Menembak rute murni ke: $baseUrl/verify-otp");
    return await post(
      '/verify-otp',
      payload,
    ); // ◄ HANYA TULIS INI, JANGAN DIUBAH!
  }

  // 🔥 FIXED TOTAL: Untuk kirim ulang juga sama, cukup buntutnya
  Future<Response> resendOtpProvider(Map<String, dynamic> payload) async {
    print("📡 [PROVIDER OTP] Minta kirim ulang murni ke: $baseUrl/resend-otp");
    return await post(
      '/resend-otp',
      payload,
    ); // ◄ HANYA TULIS INI, JANGAN DIUBAH!
  }
}
