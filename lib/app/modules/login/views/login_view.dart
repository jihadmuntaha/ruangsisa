import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruang_sisa/app/routes/app_pages.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RuangSisa',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Color(0xFF2D6A4F),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Masuk untuk melanjutkan kontribusi\nlestarimu hari ini.',
              style: TextStyle(fontSize: 16, color: Colors.grey, height: 1.5),
            ),
            const SizedBox(height: 48),

            _buildTextField(
              "Email",
              Icons.email_outlined,
              "Masukkan email kamu",
            ),
            const SizedBox(height: 20),
            _buildTextField(
              "Kata Sandi",
              Icons.lock_outline,
              "••••••••",
              isObscure: true,
            ),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Lupa Kata Sandi?',
                  style: TextStyle(color: Color(0xFF2D6A4F)),
                ),
              ),
            ),

            const SizedBox(height: 32),
            // Tombol Masuk Utama
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Get.offAllNamed(Routes.MAIN_WRAPPER),
                child: const Text(
                  'Masuk Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- PEMBATAS ATAU ---
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "atau",
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              ],
            ),

            const SizedBox(height: 24),

            // --- TOMBOL GOOGLE SIGN IN ---
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: Colors.white,
                  elevation: 0,
                ),
                onPressed: () {
                  // Sementara untuk slicing dialihkan ke Main Wrapper atau tampilkan feedback
                  Get.offAllNamed(Routes.MAIN_WRAPPER);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon Google Tiruan menggunakan Icons bawaan Flutter (Nanti bisa diganti Image.asset jika ada logonya)
                    const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 36,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Masuk dengan Google',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Belum punya akun? "),
                GestureDetector(
                  onTap: () => Get.toNamed('/register'),
                  child: const Text(
                    "Daftar di sini",
                    style: TextStyle(
                      color: Color(0xFF2D6A4F),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    String hint, {
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: isObscure,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF2D6A4F)),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
