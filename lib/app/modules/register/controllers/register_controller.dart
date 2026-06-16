import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart'; // Jalur import provider

class RegisterController extends GetxController {
  // 🎯 SEKARANG SUDAH SAMA! Memakai gerbang AuthProvider yang terpusat
  final AuthProvider _authProvider = AuthProvider();

  // State Controller untuk menangkap teks input form
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State loading reactive
  var isLoading = false.obs;
  var ispasswordHidden = true.obs;

  void togglePasswordVisibility() {
    ispasswordHidden.value = !ispasswordHidden.value;
  }

  void registerUser() async {
    final name = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Semua kolom input wajib diisi!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        "Peringatan",
        "Kata sandi minimal harus 6 karakter!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading(true);

      // Siapkan payload JSON sesuai kontrak FastAPI backend kita
      Map<String, dynamic> payload = {
        "name": name,
        "email": email,
        "password": password,
      };

      // 🚀 Tembak menggunakan AuthProvider terpusat
      final response = await _authProvider.registerUser(payload);

      if (response.statusCode == 201 || response.statusCode == 200) {
        Get.snackbar(
          "Sukses",
          "Akun kontributor RuangSisa berhasil dibuat! Silakan login.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Lempar balik ke halaman login setelah sukses mendaftar
        Get.offAllNamed('/login');
      } else {
        print("Response error: ${response.statusCode} - ${response.body}");
        String errMsg =
            response.body?['detail'] ?? "Gagal melakukan registrasi";

        Get.snackbar(
          "Gagal Daftar",
          errMsg,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Gagal terhubung ke server: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
