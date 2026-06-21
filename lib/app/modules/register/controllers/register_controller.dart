import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';

class RegisterController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var ispasswordHidden = true.obs;
  var _isProcessing = false;

  var tempUserData = <String, dynamic>{}.obs;
  var tempEmail = ''.obs;

  void togglePasswordVisibility() {
    if (!Get.isRegistered<RegisterController>()) return;
    ispasswordHidden.value = !ispasswordHidden.value;
  }

  void registerUser() async {
    if (_isProcessing || isLoading.value) return;
    if (!Get.isRegistered<RegisterController>()) return;

    try {
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

      _isProcessing = true;
      isLoading(true);

      Map<String, dynamic> payload = {
        "name": name,
        "email": email,
        "password": password,
      };

      print("BaseURL testing path: 172.24.243.45:8000");
      print("BaseURL path match method: /auth/register");
      print("📡 [REGISTER] Menembak data pendaftaran ke laptop: $payload");
      final response = await _authProvider.registerUser(payload);

      if (!Get.isRegistered<RegisterController>()) return;

      isLoading(false);
      _isProcessing = false;

      if (response.statusCode == 201 || response.statusCode == 200) {
        tempUserData.value = {
          'name': name,
          'email': email,
          'password': password,
        };
        tempEmail.value = email;

        FocusManager.instance.primaryFocus?.unfocus();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            "Langkah Kedua, Beh! 📨",
            "Akun sukses dibuat! Silakan cek email lu buat ambil kode OTP rahasia.",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 4),
          );

          // 🚀 ALUR AMAN: Amankan OTP dulu, nanti dari OTPController baru dilempar ke /face-scan
          Get.toNamed(
            '/otpverification',
            arguments: {'email': email, 'purpose': 'register'},
          );
        });
      } else {
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
      if (Get.isRegistered<RegisterController>()) {
        isLoading(false);
        _isProcessing = false;
        Get.snackbar(
          "Error",
          "Gagal terhubung ke server: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  void onClose() {
    print("🔴 RegisterController onClose dipanggil secara bersih");
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _isProcessing = false;
    super.onClose();
  }
}
