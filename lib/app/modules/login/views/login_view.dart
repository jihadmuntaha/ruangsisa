import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart'; // Jalur import controller bawaan GetX CLI kamu

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🛠️ SINKRONISASI NYATA: Dibungkus GestureDetector agar keyboard otomatis turun saat area kosong diketuk
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(
          0xFFE8FFF0,
        ), // Warna latar hijau lembut khas RuangSisa
        body: Stack(
          children: [
            // 1. PERBAIKAN: Dibungkus IgnorePointer agar lingkaran hiasan tidak memblokir sentuhan jari pada tombol
            Positioned(
              top: -100,
              right: -100,
              child: IgnorePointer(
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF95D4B3).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  // 🛠️ SINKRONISASI NYATA: Keyboard otomatis turun saat layar mulai di-scroll
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AutofillGroup(
                    // 🚨 TAMBAHAN SASIS: Membungkus form agar Google mengenali satu rumpun paket Autofill
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Brand Identity
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D6A4F),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.eco,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'RuangSisa',
                          style: TextStyle(
                            color: Color(0xFF0F5238),
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Berkontribusi untuk bumi dengan sirikulasi ekonomi yang bijak.',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Login Card Box
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // Input Email (Sudah dicolok hints email Google)
                              _buildInputField(
                                'Email atau Nama Pengguna',
                                Icons.person_outline,
                                'nama@email.com',
                                textController: controller.emailController,
                              ),
                              const SizedBox(height: 16),

                              // Input Password (Sudah dicolok hints password Google)
                              _buildInputField(
                                'Kata Sandi',
                                Icons.lock_outline,
                                '••••••••',
                                isPassword: true,
                                textController: controller.passwordController,
                              ),

                              // 🚨 PERBAIKAN SINKRONISASI: Menyatukan Simpan Password (Ingat Saya) dan Lupa Password
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Sisi Kiri: Checkbox Simpan Password (Dibungkus Obx agar interaksinya reaktif real-time)
                                  Obx(() {
                                    return Row(
                                      children: [
                                        SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: Checkbox(
                                            activeColor: const Color(
                                              0xFF2D6A4F,
                                            ),
                                            value: controller.rememberMe.value,
                                            onChanged: (value) {
                                              controller.rememberMe.value =
                                                  value ?? false;
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Ingat Saya',
                                          style: TextStyle(
                                            color: Color(0xFF404943),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    );
                                  }),

                                  // Sisi Kanan: Tombol Lupa Password bawaan visual kelompokmu
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Lupa Password?',
                                      style: TextStyle(
                                        color: Color(0xFF2D6A4F),
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Tombol Masuk Utama (Reactive)
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: Obx(() {
                                  return controller.isLoading.value
                                      ? const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF2D6A4F),
                                          ),
                                        )
                                      : ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFF2D6A4F,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: () =>
                                              controller.loginUser(),
                                          child: const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Masuk Ke Akun',
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
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        );
                                }),
                              ),
                              const SizedBox(height: 20),

                              // Pembatas Atau
                              const Row(
                                children: [
                                  Expanded(child: Divider()),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    child: Text(
                                      'Atau masuk dengan',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // BIOMETRIC FACE ID BUTTON
                              GestureDetector(
                                onTap: () {
                                  Get.snackbar(
                                    'Face ID',
                                    'Memindai wajah kontributor RuangSisa...',
                                    backgroundColor: Colors.white,
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8FFF0),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.face_unlock_rounded,
                                          color: Color(0xFF2D6A4F),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      const Text(
                                        'Login dengan Face ID',
                                        style: TextStyle(
                                          color: Color(0xFF404943),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer Navigation Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum punya akun?',
                              style: TextStyle(color: Colors.grey),
                            ),
                            GestureDetector(
                              onTap: () => Get.toNamed('/register'),
                              child: const Text(
                                ' Daftar Sekarang',
                                style: TextStyle(
                                  color: Color(0xFF2D6A4F),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. PERBAIKAN: Mengintegrasikan Obx lokal agar icon mata berfungsi penuh secara independen
  Widget _buildInputField(
    String label,
    IconData icon,
    String hint, {
    bool isPassword = false,
    required TextEditingController textController,
  }) {
    final isHidden = isPassword.obs;

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
        Obx(() {
          return TextField(
            controller: textController,
            obscureText: isHidden.value,

            // 🚨 SUNTIKAN MANANTRA SAKTI NATIVE AUTOFILL GOOGLE KASTA TERTINGGI 🚨
            autofillHints: isPassword
                ? const [AutofillHints.password]
                : const [AutofillHints.email, AutofillHints.username],

            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Icon(icon, color: Colors.grey[600]),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isHidden.value
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () => isHidden.value = !isHidden.value,
                    )
                  : null,
              filled: true,
              fillColor: const Color(0xFFF8F9FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          );
        }),
      ],
    );
  }
}
