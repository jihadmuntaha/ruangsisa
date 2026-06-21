import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.isRegistered<RegisterController>()) {
      final controller = Get.find<RegisterController>();
      if (!controller.isLoading.value) {
        Get.delete<RegisterController>();
      }
    }

    if (!Get.isRegistered<RegisterController>()) {
      Get.put(RegisterController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            // HEADER - RuangSisa Theme
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
                  const Icon(Icons.eco, color: Colors.white, size: 56),
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
                  Text(
                    'Bergabunglah dalam komunitas ekonomi sirkular.\nBeri kehidupan baru untuk barang lama Anda.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // FORM UTAMA REGISTRASI LOKAL
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Buat Akun',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002114),
                    ),
                  ),
                  const Text(
                    'Mulai langkah keberlanjutan Anda hari ini.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 32),

                  Obx(() {
                    if (!Get.isRegistered<RegisterController>()) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2D6A4F),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        _buildFormInput(
                          'Nama Pengguna (Username)',
                          Icons.person_outline_rounded,
                          'jihadmuntaha',
                          textController: controller.usernameController,
                        ),
                        const SizedBox(height: 16),
                        _buildFormInput(
                          'Email',
                          Icons.mail_outline_rounded,
                          'nama@email.com',
                          textController: controller.emailController,
                        ),
                        const SizedBox(height: 16),
                        _buildFormInput(
                          'Kata Sandi',
                          Icons.lock_outline_rounded,
                          '••••••••',
                          isSecure: !controller
                              .ispasswordHidden
                              .value, // 🔥 FIXED: Sinkronisasi toggle mata
                          textController: controller.passwordController,
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: controller.isLoading.value
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF2D6A4F),
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2D6A4F),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (Get.isRegistered<
                                      RegisterController
                                    >()) {
                                      controller.registerUser();
                                    }
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Daftar Sekarang',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(
                    height: 32,
                  ), // Spacing penyeimbang setelah tombol sosial media dibuang
                  // Link Kembali ke Halaman Login
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (Get.isRegistered<RegisterController>()) {
                          final ctrl = Get.find<RegisterController>();
                          if (!ctrl.isLoading.value) {
                            Get.delete<RegisterController>();
                          }
                        }
                        Future.delayed(const Duration(milliseconds: 50), () {
                          Get.offAllNamed('/login');
                        });
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sudah punya akun? ',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          Text(
                            'Masuk',
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormInput(
    String label,
    IconData icon,
    String hint, {
    bool isSecure = false,
    required TextEditingController textController,
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
        TextField(
          controller: textController,
          obscureText: isSecure,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
            suffixIcon:
                isSecure ||
                    label ==
                        'Kata Sandi' // 🔥 FIXED: Suffix icon eye hanya tampil di input Sandi
                ? Obx(() {
                    if (!Get.isRegistered<RegisterController>()) {
                      return const SizedBox.shrink();
                    }
                    final ctrl = Get.find<RegisterController>();
                    return IconButton(
                      icon: Icon(
                        ctrl.ispasswordHidden.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: () {
                        if (Get.isRegistered<RegisterController>()) {
                          ctrl.togglePasswordVisibility();
                        }
                      },
                    );
                  })
                : null,
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
