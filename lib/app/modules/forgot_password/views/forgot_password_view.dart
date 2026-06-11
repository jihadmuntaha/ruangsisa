import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi Palet Warna Estetik RuangSisa ♻️
    const primaryGreen = Color(0xFF2D6A4F);
    const lightGreenBg = Color(0xFFF4F9F4);
    const darkTextColor = Color(0xFF1B4332);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pemulihan Akun',
          style: TextStyle(
            color: darkTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: darkTextColor,
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Obx(() {
              // 1. STATE LOADING: Tampilkan Indikator Berputar
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryGreen),
                  ),
                );
              }

              // 2. KONTEN UTAMA HALAMAN
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon Ilustrasi Kunci Keamanan
                  Container(
                    height: 100,
                    width: 100,
                    decoration: const BoxDecoration(
                      color: lightGreenBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      controller.isOtpSent.value
                          ? Icons.mark_email_read_rounded
                          : Icons.lock_reset_rounded,
                      size: 54,
                      color: primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Judul Dinamis Tergantung Alur State OTP
                  Text(
                    controller.isOtpSent.value
                        ? 'Verifikasi Kode OTP'
                        : 'Lupa Kata Sandi?',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Deskripsi Pendukung Dinamis
                  Text(
                    controller.isOtpSent.value
                        ? 'Kami telah mengirimkan 6 digit kode OTP ke email Anda. Silakan periksa kotak masuk atau folder spam.'
                        : 'Masukkan email kontributor RuangSisa Anda di bawah ini untuk menerima kode verifikasi OTP.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 📝 FIELD INPUT UTAMA
                  // Kolom Email (Selalu tampil, terkunci otomatis jika OTP sudah dikirim)
                  TextField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !controller.isOtpSent.value,
                    decoration: InputDecoration(
                      labelText: 'Email Kontributor',
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: primaryGreen,
                      ),
                      filled: controller.isOtpSent.value,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: primaryGreen,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // ⏳ FORM LANJUTAN: Muncul menggunakan Spread Operator (...) jika OTP Terkirim
                  if (controller.isOtpSent.value) ...[
                    const SizedBox(height: 16),
                    // Input OTP Code
                    TextField(
                      controller: controller.otpController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      style: const TextStyle(
                        letterSpacing: 8,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Kode OTP 6 Digit',
                        counterText: "",
                        prefixIcon: const Icon(
                          Icons.pin_outlined,
                          color: primaryGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Input Password Baru
                    TextField(
                      controller: controller.newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Kata Sandi Baru',
                        prefixIcon: const Icon(
                          Icons.vpn_key_outlined,
                          color: primaryGreen,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: primaryGreen,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),

                  // 🚀 TOMBOL AKSI DINAMIS
                  ElevatedButton(
                    onPressed: () {
                      if (controller.isOtpSent.value) {
                        controller.verifyAndResetPassword();
                      } else {
                        controller.sendOtpCode();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      controller.isOtpSent.value
                          ? 'Perbarui Kata Sandi'
                          : 'Kirim Kode OTP',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Opsi Tombol Batal / Kembali ke Login jika salah ketik email
                  if (controller.isOtpSent.value) ...[
                    TextButton(
                      onPressed: () {
                        controller.isOtpSent.value = false;
                        controller.otpController.clear();
                        controller.newPasswordController.clear();
                      },
                      child: const Text(
                        'Salah Email? Kirim Ulang',
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
