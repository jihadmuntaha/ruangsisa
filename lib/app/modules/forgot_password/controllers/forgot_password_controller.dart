import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController {
  // Controller untuk menangkap input teks
  late TextEditingController emailController;
  late TextEditingController otpController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  // Status Loading indikator
  var isLoading = false.obs;

  // Melacak tahapan form saat ini: 1 = Input Email, 2 = Input OTP, 3 = Input Password Baru
  var currentStep = 1.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    otpController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // ================= TAHAP 1: KIRIM OTP =================
  void sendOtpEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      Get.snackbar('Input Tidak Valid', 'Silakan masukkan alamat email yang benar.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      // TODO: Hubungkan dengan API backend RuangSisa untuk generate & kirim OTP
      await Future.delayed(const Duration(seconds: 2)); 
      isLoading.value = false;

      Get.snackbar('OTP Dikirim', 'Kode verifikasi telah dikirim ke email $email.',
          snackPosition: SnackPosition.BOTTOM);
      
      // Pindah ke tahap verifikasi OTP
      currentStep.value = 2;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Gagal mengirim OTP.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ================= TAHAP 2: VERIFIKASI OTP =================
  void verifyOtp() async {
    // final otp = otpController.text.trim();

    // if (otp.isEmpty || otp.length < 4) { // Asumsi kode OTP 4-6 digit
    //   Get.snackbar('OTP Salah', 'Silakan masukkan kode OTP yang valid.',
    //       snackPosition: SnackPosition.BOTTOM);
    //   return;
    // }

    try {
      isLoading.value = true;
      // TODO: Hubungkan dengan API backend untuk validasi kecocokan kode OTP
      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;

      Get.snackbar('Verifikasi Sukses', 'Kode OTP cocok. Silakan atur kata sandi baru.',
          snackPosition: SnackPosition.BOTTOM);
      
      // Pindah ke tahap ganti password baru
      currentStep.value = 3;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Kode OTP tidak cocok atau kadaluwarsa.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ================= TAHAP 3: PERBARUI PASSWORD =================
  void updatePassword() async {
    final newPass = newPasswordController.text;
    final confirmPass = confirmPasswordController.text;

    if (newPass.isEmpty || newPass.length < 8) {
      Get.snackbar('Sandi Lemah', 'Kata sandi minimal harus 8 karakter.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar('Tidak Cocok', 'Konfirmasi kata sandi tidak sama.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;
      // TODO: Hubungkan dengan API backend untuk menyimpan kata sandi baru ke database
      await Future.delayed(const Duration(seconds: 2));
      isLoading.value = false;

      Get.snackbar('Sukses', 'Kata sandi berhasil diperbarui! Silakan masuk kembali.',
          snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));

      // Kembalikan pengguna langsung ke layar login
      Future.delayed(const Duration(seconds: 3), () => Get.back());
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Gagal memperbarui kata sandi.', snackPosition: SnackPosition.BOTTOM);
    }
  }
}