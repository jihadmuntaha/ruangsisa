import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruang_sisa/app/data/providers/auth_provider.dart';

class ForgotPasswordController extends GetxController {
  final AuthProvider authProvider = AuthProvider();

  // Text Editing Controller untuk menangkap input user
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();

  var isLoading = false.obs;
  var isOtpSent = false.obs; // State untuk memantau apakah OTP sudah dikirim

  // 🚀 Fungsi Kirim OTP (Halaman Pertama)
  void sendOtpCode() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Email tidak boleh kosong!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await authProvider.requestOtp(
        emailController.text.trim(),
      );

      if (response.statusCode == 200) {
        isOtpSent.value = true; // Pindah ke form input OTP & Password Baru
        Get.snackbar(
          "Sukses",
          response.body['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Gagal",
          response.body['detail'] ?? "Terjadi kesalahan",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // 🚀 Fungsi Eksekusi Password Baru (Halaman Kedua / Form Lanjutan)
  void verifyAndResetPassword() async {
    if (otpController.text.isEmpty || newPasswordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Semua kolom wajib diisi!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      final response = await authProvider.resetPassword(
        emailController.text.trim(),
        otpController.text.trim(),
        newPasswordController.text.trim(),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Sukses",
          response.body['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Password sukses diubah, langsung tendang user balik ke halaman Login
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          "Gagal",
          response.body['detail'] ?? "Terjadi kesalahan",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }
}
