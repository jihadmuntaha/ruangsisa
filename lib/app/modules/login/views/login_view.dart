import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Jalur lokal untuk melacak status penyamaran kata sandi
    final isPasswordHidden = true.obs;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(
          0xFFE8FFF0,
        ), // Latar hijau lembut khas RuangSisa
        body: Stack(
          children: [
            // Lingkaran hiasan background
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
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: AutofillGroup(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Brand Identity RuangSisa
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
                          'Berkontribusi untuk bumi dengan sirkulasi ekonomi yang bijak.',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 📥 1. INPUT EMAIL (Tanpa Obx, Anti Layar Merah)
                              const Text(
                                'Email atau Nama Pengguna',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF404943),
                                ),
                              ),
                              const SizedBox(height: 6),
                              TextField(
                                controller: controller.emailController,
                                autofillHints: const [
                                  AutofillHints.email,
                                  AutofillHints.username,
                                ],
                                decoration: InputDecoration(
                                  hintText: 'nama@email.com',
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Colors.grey[600],
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9FA),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 📥 2. INPUT PASSWORD (Obx hanya membungkus bagian yang berubah)
                              const Text(
                                'Kata Sandi',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF404943),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Obx(
                                () => TextField(
                                  controller: controller.passwordController,
                                  obscureText: isPasswordHidden.value,
                                  autofillHints: const [AutofillHints.password],
                                  decoration: InputDecoration(
                                    hintText: '••••••••',
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.grey[600],
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        isPasswordHidden.value
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () => isPasswordHidden.value =
                                          !isPasswordHidden.value,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF8F9FA),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Row Simpan Password & Lupa Password
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(width: 24, height: 24),
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
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // AKTIF: Berpindah ke Halaman Forgot Password
                                      Get.toNamed('/forgot-password');
                                    },
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

                              // Tombol Masuk Form Manual
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
                                          onPressed: () => controller.login(),
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

                              // Pembatas Atau Masuk Dengan
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

                              // TOMBOL GOOGLE SIGN-IN
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: Obx(() {
                                  return controller.isLoading.value
                                      ? const SizedBox.shrink()
                                      : OutlinedButton.icon(
                                          icon: const Icon(
                                            Icons.g_mobiledata_rounded,
                                            size: 30,
                                            color: Colors.redAccent,
                                          ),
                                          label: const Text(
                                            'Masuk dengan Google',
                                            style: TextStyle(
                                              color: Color(0xFF404943),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            side: BorderSide(
                                              color: Colors.grey[300]!,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          onPressed: () =>
                                              controller.loginWithGoogle(),
                                        );
                                }),
                              ),
                              const SizedBox(height: 12),

                              // TOMBOL BIOMETRIC FACE ID
                              Obx(() {
                                return controller.isLoading.value
                                    ? const SizedBox.shrink()
                                    : GestureDetector(
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
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey[300]!,
                                            ),
                                          ),
                                          child: const Column(
                                            children: [
                                              Icon(
                                                Icons.face_unlock_rounded,
                                                color: Color(0xFF2D6A4F),
                                                size: 24,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Login dengan Face ID',
                                                style: TextStyle(
                                                  color: Color(0xFF404943),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Footer Menuju Halaman Register
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
}