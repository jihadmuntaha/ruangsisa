import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../routes/app_pages.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 FIX: Buat/panggil controller secara aman tanpa ada logika hapus paksa (delete) yang merusak state memori
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

                    Obx(() {
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
                          _buildPasswordField(),
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
                                  // 🟢 TERBANG KE HALAMAN KHUSUS LU: Langsung arahkan ke view 3-step yang lu buat
                                  Get.toNamed('/forgot-password');
                                },
                                child: const Text(
                                  'Lupa Password?',
                                  style: TextStyle(
                                    color: Color(
                                      0xFF2D6A4F,
                                    ), // Warna hijau khas RuangSisa lu
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

                          // GOOGLE & FACE RECOGNITION OPTIONS
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
                                    // 🟢 FIX JALUR POPUP: Jauh lebih aman untuk mengantisipasi form input email utama yang kosong
                                    final TextEditingController
                                    dialogEmailCtrl = TextEditingController();

                                    // Set default text popup jika input field di form utama sudah terlanjur diisi user
                                    if (controller
                                        .emailController
                                        .text
                                        .isNotEmpty) {
                                      dialogEmailCtrl.text = controller
                                          .emailController
                                          .text
                                          .trim();
                                    }

                                    Get.defaultDialog(
                                      title: "Verifikasi Face ID",
                                      titleStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D6A4F),
                                      ),
                                      backgroundColor: Colors.white,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 10,
                                          ),
                                      content: Column(
                                        children: [
                                          const Text(
                                            "Masukkan email akun RuangSisa Anda untuk mulai memindai wajah!",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: dialogEmailCtrl,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              hintText:
                                                  "contoh: user@gmail.com",
                                              prefixIcon: const Icon(
                                                Icons.email,
                                                color: Color(0xFF2D6A4F),
                                              ),
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      textConfirm: "Mulai Pindai",
                                      confirmTextColor: Colors.white,
                                      buttonColor: const Color(0xFF2D6A4F),
                                      textCancel: "Batal",
                                      cancelTextColor: Colors.grey,
                                      onConfirm: () {
                                        String finalEmail = dialogEmailCtrl.text
                                            .trim();
                                        if (finalEmail.isEmpty) {
                                          Get.snackbar(
                                            "Eror ❌",
                                            "Email wajib diisi untuk verifikasi biometrik!",
                                          );
                                          return;
                                        }
                                        Get.back(); // Tutup popup dialog

                                        // 🚀 TERBANG LANGSUNG KE HALAMAN UTAMA FACE RECOGNITION
                                        Get.toNamed(
                                          Routes.FACE_SCAN,
                                          arguments: {
                                            'mode': 'login',
                                            'email': finalEmail,
                                          },
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.face_rounded,
                                    color: Color(0xFF2D6A4F),
                                    size: 20,
                                  ),
                                  label: const Text(
                                    'Face Scan',
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
                                Get.offAllNamed('/register');
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
          // 🟢 KUNCI TOBAT: Diarahkan tegas ke emailController milik LoginController lewat GetView
          controller: controller.emailController,
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

  Widget _buildPasswordField() {
    final isHiddenLocal = true.obs;

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
        Obx(
          () => TextField(
            controller: controller.passwordController,
            obscureText: isHiddenLocal.value,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 14),
            onSubmitted: (_) {
              if (Get.isRegistered<LoginController>()) {
                controller.login();
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
              suffixIcon: IconButton(
                icon: Icon(
                  isHiddenLocal.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () => isHiddenLocal.value = !isHiddenLocal.value,
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
        ),
      ],
    );
  }
}
