import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruang_sisa/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final _connect = GetConnect(timeout: const Duration(seconds: 15));

  // URL Backend RuangSisa Vercel kamu yang sudah live
  final String baseUrl = "https://ruangsisa-backend.vercel.app";

  // State Controller untuk menangkap teks input form
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State loading reactive
  var isLoading = false.obs;

  void registerUser() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Validasi dasar di sisi Frontend
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar("Peringatan", "Semua kolom input wajib diisi!");
      return;
    }

    if (password.length < 6) {
      Get.snackbar("Peringatan", "Kata sandi minimal harus 6 karakter!");
      return;
    }

    try {
      isLoading(true);

      // Menembak endpoint register FastAPI Vercel
      final response = await _connect.post(
        '$baseUrl/api/auth/register',
        {
          "name": username,
          "username": username,
          "email": email,
          "password": password,
        },
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          "Sukses",
          "Akun kontributor RuangSisa berhasil dibuat! Silakan login.",
          backgroundColor: Colors.white,
        );

        // r
        // Tendang user balik ke halaman login setelah sukses
        Get.offAllNamed(Routes.LOGIN);
      } else {
        print("Response error: ${response.statusCode} - ${response.body}");

        String errMsg = "Gagal melakukan registrasi";

        if (response.body != null && response.body['detail'] != null) {
          final detail = response.body['detail'];

          // Jika detail berupa String biasa (HTTPException manual)
          if (detail is String) {
            errMsg = detail;
          }
          // Jika detail berupa List (Validasi otomatis Pydantic)
          else if (detail is List && detail.isNotEmpty) {
            errMsg = detail[0]['msg'] ?? "Format data tidak valid";
          }
        }

        Get.snackbar("Gagal Daftar", errMsg);
      }
    } catch (e, stacktrace) {
      // Baris keramat untuk melacak posisi error murni di terminal
      print("🚨 TERJADI ERROR JARINGAN FLUTTER: $e");
      print("📌 STACKTRACE: $stacktrace");

      Get.snackbar("Error", "Gagal terhubung ke server: $e");
    } finally {
      isLoading(false);
    }
  }

  var ispasswordHidden = true.obs;

  void togglePasswordVisibility() {
    ispasswordHidden.value = !ispasswordHidden.value;
  }

  @override
  void onClose() {
    // Menghapus controller dari memori biar gak bocor (memory leak)
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
