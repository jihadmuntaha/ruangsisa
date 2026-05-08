import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mulai Langkah Lestari',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
            ),
            const SizedBox(height: 8),
            const Text('Bergabunglah dengan komunitas RuangSisa untuk mengelola dampak lingkungan Anda.'),
            const SizedBox(height: 32),
            
            // Input Nama
            _buildInputLabel("Nama Lengkap"),
            _buildTextField("Masukkan nama sesuai KTP"),
            
            const SizedBox(height: 16),
            
            // Input Email
            _buildInputLabel("Email"),
            _buildTextField("contoh@email.com"),
            
            const SizedBox(height: 32),
            
            // Tombol Daftar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => Get.toNamed('/login'), // Navigasi GetX
                child: const Text('Buat Akun', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Widget _buildTextField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}