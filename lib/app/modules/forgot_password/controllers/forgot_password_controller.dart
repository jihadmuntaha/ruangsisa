import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:ruang_sisa/app_config.dart';

class ForgotPasswordController extends GetxController {
  // --- STATE & UTILLITIES ---
  var currentStep = 1.obs;
  var isLoading = false.obs;

  // --- TEXT CONTROLLERS ---
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // --- API BASE URL ---
  final String baseUrl = AppConfig.baseUrl;

  // ================= TAHAP 1: KIRIM OTP EMAIL =================
  void sendOtpEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar(
        "Validasi Gagal ❌",
        "Masukkan alamat email yang valid!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/forgot-password/request"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        Get.snackbar(
          "OTP Terkirim 📩",
          "Kode OTP berhasil dikirim ke email $email.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        currentStep.value = 2;
      } else {
        final data = jsonDecode(response.body);
        // 🟢 AMAN: Tambahkan .toString() agar tidak memicu type mismatch
        Get.snackbar(
          "Gagal ❌",
          data['detail']?.toString() ??
              data['message']?.toString() ??
              "Gagal mengirim OTP.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error ❌",
        "Tidak dapat terhubung ke server backend.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ================= TAHAP 2: VERIFIKASI KODE OTP =================
  void verifyOtp() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (otp.isEmpty || otp.length < 4) {
      Get.snackbar(
        "Validasi Gagal ❌",
        "Kode OTP wajib diisi lengkap!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/forgot-password/verify"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "otp": otp}),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        Get.snackbar(
          "Verifikasi Sukses 🎉",
          "Kode OTP valid. Silakan atur kata sandi baru Anda.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        currentStep.value = 3;
      } else {
        final data = jsonDecode(response.body);
        // 🟢 AMAN: Tambahkan .toString() agar tidak memicu type mismatch
        Get.snackbar(
          "OTP Salah ❌",
          data['detail']?.toString() ?? "Kode OTP tidak valid/kedaluwarsa.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error ❌",
        "Gagal memverifikasi OTP ke server.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ================= TAHAP 3: UPDATE PASSWORD BARU =================
  void updatePassword() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();
    final newPassword = newPasswordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        "Validasi Gagal ❌",
        "Kedua kolom kata sandi wajib diisi!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassword.length < 8) {
      Get.snackbar(
        "Validasi Gagal ❌",
        "Kata sandi baru minimal harus 8 karakter!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        "Mismatched ❌",
        "Konfirmasi kata sandi tidak cocok!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final response = await http.post(
        Uri.parse("$baseUrl/api/auth/forgot-password/reset"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "otp": otp,
          "new_password": newPassword,
        }),
      );

      isLoading.value = false;

      if (response.statusCode == 200) {
        // Tutup keyboard bawaan biar gak ganjal animasi transisi
        FocusManager.instance.primaryFocus?.unfocus();

        // 🟢 AMAN & STERIL: Langsung tendang ke login, gak usah panggil _resetForm() lagi!
        Get.offAllNamed('/login');

        // Munculkan snackbar setelah perintah pindah jalan
        Get.snackbar(
          "Sukses 🎉",
          "Kata sandi berhasil diperbarui! Silakan masuk kembali.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      } else {
        final data = jsonDecode(response.body);
        // 🟢 AMAN: Tambahkan .toString() agar tidak memicu type mismatch
        Get.snackbar(
          "Gagal ❌",
          data['detail']?.toString() ?? "Gagal memperbarui kata sandi.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error ❌",
        "Terjadi kesalahan sistem saat memperbarui sandi.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
