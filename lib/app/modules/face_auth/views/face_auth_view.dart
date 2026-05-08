import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FaceAuthView extends StatelessWidget {
  const FaceAuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Verifikasi Wajah', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
            const SizedBox(height: 12),
            const Text('Dekatkan wajah ke area lingkaran', textAlign: TextAlign.center),
            const SizedBox(height: 60),
            
            // Frame Face Recognition
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2D6A4F), width: 2),
                  ),
                ),
                ClipOval(
                  child: Container(
                    width: 260,
                    height: 260,
                    color: Colors.grey[200],
                    child: const Icon(Icons.person, size: 150, color: Colors.white),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 60),
            const CircularProgressIndicator(color: Color(0xFF2D6A4F)),
            const SizedBox(height: 24),
            const Text('Sedang Memverifikasi...', 
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D6A4F))),
            
            const SizedBox(height: 40),
            // Simulasi kalau berhasil
            TextButton(
              onPressed: () => Get.offAllNamed('/home'), 
              child: const Text('Simulasi Berhasil (Lewati)'),
            )
          ],
        ),
      ),
    );
  }
}