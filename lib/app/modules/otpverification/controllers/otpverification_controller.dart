import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../.././data/providers/auth_provider.dart'; // ◄ Sudah pas mengarah ke AuthProvider baru lu

class OtpVerificationController extends GetxController {
  // Inisialisasi AuthProvider yang tadi sudah kita benahi
  final AuthProvider _authProvider = Get.isRegistered<AuthProvider>()
      ? Get.find<AuthProvider>()
      : Get.put(AuthProvider());

  // 4 Controller untuk masing-masing kotak angka OTP
  final List<TextEditingController> otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  String get otpCode => otpControllers.map((c) => c.text).join();

  var isLoading = false.obs;
  var emailUser = ''.obs;
  var purpose = 'register'.obs; // 'register' atau 'forgot_password'

  @override
  void onInit() {
    super.onInit();
    // 📨 Tangkap argumen email dan tujuan yang dilempar dari halaman Register / Forgot Password
    if (Get.arguments != null) {
      emailUser.value = Get.arguments['email'] ?? '';
      purpose.value = Get.arguments['purpose'] ?? 'register';
      print(
        "📬 [OTP CONTROLLER] Mengamankan email target: ${emailUser.value} untuk keperluan: ${purpose.value}",
      );
    }
  }

  // 📡 FUNGSI UTAMA: Kirim 4 Angka OTP ke FastAPI Laptop Lu
  void verifyOtpAction() async {
    // Gabungkan 4 kotak teks terpisah menjadi 1 string utuh (misal: "8842")
    String otpCode = otpControllers.map((c) => c.text.trim()).join();

    if (otpCode.length < 6) {
      Get.snackbar(
        "Form Kurang",
        "Silakan isi semua kotak OTP",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading(true);

      Map<String, dynamic> payload = {
        "email": emailUser.value,
        "otp_code": otpCode,
        "purpose": purpose.value,
      };

      print("📡 [OTP] Menembak kode verifikasi ke backend laptop lu: $payload");

      // 🚀 SEKARANG NYATA HIT KE BACKEND LAPTOP LU, BEH!
      Response response = await _authProvider.verifyOtpProvider(payload);

      print("📡 [OTP] Response Status Backend: ${response.statusCode}");
      print("📡 [OTP] Response Body Backend: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Verifikasi Sukses",
          purpose.value == 'register'
              ? "Akun lu sudah aktif! Silakan masuk, Beh."
              : "Verifikasi berhasil! Silakan ubah password lu.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        // Tutup soft keyboard biar gak macet pas pindah rute
        FocusManager.instance.primaryFocus?.unfocus();

        // 🔄 LOGIKA PERPINDAHAN RUTIN
        if (purpose.value == 'register') {
          // Kalau kelar register, sapu bersih stack halaman dan suruh dia login
          Get.offAllNamed('/login');
        } else {
          // Kalau dari lupa password, tendang dia ke halaman ResetPasswordView bawa email-nya
          Get.offAllNamed(
            '/reset-password',
            arguments: {"email": emailUser.value},
          );
        }
      } else {
        String errorDetail =
            response.body?['detail'] ?? "Kode OTP salah atau sudah kadaluarsa!";
        Get.snackbar(
          "Verifikasi Gagal",
          errorDetail,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("🚨 [OTP] Terjadi Exception Critical: $e");
      Get.snackbar(
        "Error",
        "Gagal terhubung ke laptop backend lu, Beh!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // 🔥 FUNGSI UTAMA KEDUA: Kirim Ulang OTP jika User Gak Nerima Email
  void resendOtpAction() async {
    if (emailUser.value.isEmpty) return;

    try {
      print("📡 [OTP] Mengirim ulang OTP untuk email: ${emailUser.value}");

      Map<String, dynamic> payload = {
        "email": emailUser.value,
        "purpose": purpose.value,
      };

      Response response = await _authProvider.resendOtpProvider(payload);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Kosongkan ulang kotak inputan yang lama biar user gak bingung
        for (var controller in otpControllers) {
          controller.clear();
        }
        focusNodes[0]
            .requestFocus(); // Kembalikan kursor fokus ke kotak pertama

        Get.snackbar(
          "OTP Dikirim Ulang",
          "Kode baru berhasil diledakkan ke email lu, coba cek berkala!",
          backgroundColor: Colors.blueAccent,
          colorText: Colors.white,
        );
      } else {
        String errorDetail =
            response.body?['detail'] ?? "Gagal memicu pengiriman ulang.";
        Get.snackbar(
          "Gagal Kirim",
          errorDetail,
          backgroundColor: Colors.orange,
        );
      }
    } catch (e) {
      print("🚨 [OTP] Gagal kirim ulang: $e");
    }
  }

  @override
  void onClose() {
    for (var c in otpControllers) {
      c.dispose();
    }
    for (var f in focusNodes) {
      f.dispose();
    }
    super.onClose();
  }
}
