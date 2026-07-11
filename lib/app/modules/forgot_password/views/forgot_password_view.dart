import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final isPassHidden = true.obs;
    final isConfirmPassHidden = true.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER (Tetap Konsisten) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
              decoration: const BoxDecoration(
                color: Color(0xFF2D6A4F),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.security_rounded,
                    color: Colors.white,
                    size: 56,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'RuangSisa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    // Deskripsi dinamis mengikuti langkah proses
                    if (controller.currentStep.value == 1) {
                      return Text(
                        'Masukkan email Anda untuk menerima kode OTP pemulihan.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      );
                    } else if (controller.currentStep.value == 2) {
                      return Text(
                        'Masukkan 4 digit kode OTP yang telah dikirim ke kotak masuk email Anda.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      );
                    } else {
                      return Text(
                        'Buat kata sandi baru yang kuat dan mudah Anda ingat.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                  }),
                ],
              ),
            ),

            // --- FORM DINAMIS MENGGUNAKAN OBX ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Obx(() {
                switch (controller.currentStep.value) {
                  // TAHAP 1: FORM INPUT EMAIL
                  case 1:
                    return _buildEmailStep();
                  // TAHAP 2: FORM INPUT OTP
                  case 2:
                    return _buildOtpStep();
                  // TAHAP 3: FORM INPUT PASSWORD BARU
                  case 3:
                    return _buildNewPasswordStep(
                      isPassHidden,
                      isConfirmPassHidden,
                    );
                  default:
                    return _buildEmailStep();
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LAYER UTK TAHAP 1 =================
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pulihkan Akun',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002114),
          ),
        ),
        const Text(
          'Langkah 1 dari 3: Verifikasi Identitas',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 32),
        _buildInputField(
          'Alamat Email',
          Icons.mail_outline_rounded,
          'nama@email.com',
          textController: controller.emailController,
        ),
        const SizedBox(height: 32),
        _buildActionButton('Kirim Kode OTP', () => controller.sendOtpEmail()),
        const SizedBox(height: 40),
        _buildBackToLoginLink(),
      ],
    );
  }

  // ================= LAYER UTK TAHAP 2 =================
  Widget _buildOtpStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Verifikasi OTP',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002114),
          ),
        ),
        const Text(
          'Langkah 2 dari 3: Masukkan Kode Keamanan',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 32),
        _buildInputField(
          'Kode OTP',
          Icons.pin_rounded,
          '• • • •',
          textController: controller.otpController,
          isOtp: true,
        ),
        const SizedBox(height: 32),
        _buildActionButton('Verifikasi Kode', () => controller.verifyOtp()),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () => controller.currentStep.value =
                1, // Berikan akses kembali ke tahap 1 jika email keliru
            child: const Text(
              'Ganti alamat email?',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= LAYER UTK TAHAP 3 =================
  Widget _buildNewPasswordStep(
    RxBool isPassHidden,
    RxBool isConfirmPassHidden,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sandi Baru',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF002114),
          ),
        ),
        const Text(
          'Langkah 3 dari 3: Atur Ulang Keamanan',
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 32),
        _buildInputField(
          'Kata Sandi Baru',
          Icons.lock_outline_rounded,
          '••••••••',
          textController: controller.newPasswordController,
          isSecure: true,
          hideStatus: isPassHidden,
        ),
        const SizedBox(height: 16),
        _buildInputField(
          'Konfirmasi Kata Sandi Baru',
          Icons.lock_clock_outlined,
          '••••••••',
          textController: controller.confirmPasswordController,
          isSecure: true,
          hideStatus: isConfirmPassHidden,
        ),
        const SizedBox(height: 32),
        _buildActionButton(
          'Perbarui Kata Sandi',
          () => controller.updatePassword(),
        ),

        // TAMBAHKAN BARIS INI (Beri jarak lalu pasang link manual ke login)
        const SizedBox(height: 24),
        _buildBackToLoginLink(),
      ],
    );
  }

  // ================= UTILITAS REUSABLE WIDGETS =================
  Widget _buildInputField(
    String label,
    IconData icon,
    String hint, {
    required TextEditingController textController,
    bool isSecure = false,
    RxBool? hideStatus,
    bool isOtp = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF404943),
          ),
        ),
        const SizedBox(height: 6),
        hideStatus != null
            ? Obx(
                () => TextField(
                  controller: textController,
                  obscureText: hideStatus.value,
                  style: const TextStyle(fontSize: 14),
                  decoration: _inputDecoration(
                    hint,
                    icon,
                    isSecure: isSecure,
                    hideStatus: hideStatus,
                  ),
                ),
              )
            : TextField(
                controller: textController,
                style: const TextStyle(fontSize: 14),
                keyboardType: isOtp
                    ? TextInputType.number
                    : TextInputType.emailAddress,
                decoration: _inputDecoration(hint, icon),
              ),
      ],
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    bool isSecure = false,
    RxBool? hideStatus,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
      suffixIcon: isSecure && hideStatus != null
          ? IconButton(
              icon: Icon(
                hideStatus.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () => hideStatus.value = !hideStatus.value,
            )
          : null,
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Obx(() {
        return controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
              )
            : ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: action,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              );
      }),
    );
  }

  Widget _buildBackToLoginLink() {
    return Center(
      child: GestureDetector(
        onTap: () => Get.back(),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF2D6A4F),
              size: 12,
            ),
            SizedBox(width: 6),
            Text(
              'Kembali ke halaman Masuk',
              style: TextStyle(
                color: Color(0xFF2D6A4F),
                fontWeight: FontWeight.bold,
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
