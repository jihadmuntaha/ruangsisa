import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 PERBAIKAN KRUSIAL: Reset controller dengan aman
    // Hapus controller lama jika ada dan tidak sedang loading
    if (Get.isRegistered<LoginController>()) {
      final existingController = Get.find<LoginController>();
      if (!existingController.isLoading.value) {
        // Hapus controller lama
        Get.delete<LoginController>();
      }
    }

    // Buat controller baru jika belum ada
    if (!Get.isRegistered<LoginController>()) {
      Get.put(LoginController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              // Header Hijau
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
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
                      'Masuk ke akun Anda untuk melanjutkan\nberkontribusi pada ekonomi sirkular.',
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

              // Form Login
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang Kembali',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002114),
                      ),
                    ),
                    const Text(
                      'Masuk untuk melanjutkan perjalanan hijau Anda.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 32),

                    // 🔥 PERBAIKAN: Gunakan Obx untuk rebuild saat controller berubah
                    Obx(() {
                      // Jika controller sudah di-dispose, tampilkan loading
                      if (!Get.isRegistered<LoginController>()) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF2D6A4F),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          _buildEmailField(controller.emailController),
                          const SizedBox(height: 16),
                          _buildPasswordField(controller.passwordController),
                          const SizedBox(height: 8),

                          // Remember Me & Lupa Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(
                                () => Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: controller.rememberMe.value,
                                        onChanged: (value) {
                                          controller.rememberMe.value =
                                              value ?? false;
                                        },
                                        activeColor: const Color(0xFF2D6A4F),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Ingat Saya',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigasi ke lupa password
                                },
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    color: Color(0xFF2D6A4F),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Login Button
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
                                      if (Get.isRegistered<LoginController>()) {
                                        controller.login();
                                      }
                                    },
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Masuk',
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
                          const SizedBox(height: 24),

                          const Center(
                            child: Text(
                              'atau masuk dengan',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey[300]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (Get.isRegistered<LoginController>()) {
                                      controller.loginWithGoogle();
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.g_mobiledata_rounded,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  label: const Text(
                                    'Google',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.grey[300]!),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                  ),
                                  onPressed: () {
                                    // Facebook Sign In
                                  },
                                  icon: const Icon(
                                    Icons.facebook,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                  label: const Text(
                                    'Facebook',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // Link ke Register
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                // 🔥 PERBAIKAN: Hapus controller dengan aman
                                if (Get.isRegistered<LoginController>()) {
                                  final ctrl = Get.find<LoginController>();
                                  if (!ctrl.isLoading.value) {
                                    Get.delete<LoginController>();
                                  }
                                }
                                Future.delayed(
                                  const Duration(milliseconds: 50),
                                  () {
                                    Get.offAllNamed('/register');
                                  },
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Belum punya akun? ',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    'Daftar Sekarang',
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
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField(TextEditingController textController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: Color(0xFF404943),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: textController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'nama@email.com',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: Icon(
              Icons.mail_outline_rounded,
              color: Colors.grey[600],
              size: 20,
            ),
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

  Widget _buildPasswordField(TextEditingController textController) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHidden = true;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kata Sandi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF404943),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: textController,
              obscureText: isHidden,
              textInputAction: TextInputAction.done,
              style: const TextStyle(fontSize: 14),
              onSubmitted: (_) {
                if (Get.isRegistered<LoginController>()) {
                  Get.find<LoginController>().login();
                }
              },
              decoration: InputDecoration(
                hintText: '••••••••',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.grey[600],
                  size: 20,
                ),
                // suffixIcon: IconButton(
                //   icon: Icon(
                //     isHidden
                //         ? Icons.visibility_off_outlined
                //         : Icons.visibility_outlined,
                //     color: Colors.grey,
                //     size: 20,
                //   ),
                //   onPressed: () {
                //     setState(() {
                //       isHidden = !isHidden;
                //     });
                //   },
                // ),
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
      },
    );
  }
}
