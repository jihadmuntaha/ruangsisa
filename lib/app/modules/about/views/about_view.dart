import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Aplikasi
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F3ED),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(Icons.eco, size: 80, color: Color(0xFF2D6A4F)),
              ),
              const SizedBox(height: 24),
              const Text('RuangSisa', 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF2D6A4F))),
              const Text('v1.0.0-alpha', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              const Text(
                'RuangSisa adalah platform ekonomi sirkular yang didesain untuk mengurangi limbah dengan memberikan kesempatan kedua bagi barang-barangmu melalui jual-beli dan donasi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.6, color: Color(0xFF404943)),
              ),
              const SizedBox(height: 60), // Jarak lebih luas ke bagian tim
              const Text('Dikembangkan oleh:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              
              // Susunan Menyamping
              IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Kolom Jihad
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Jihad Muntaha Amal', 
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('23090042', 
                            style: TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    
                    // Garis Pembatas Vertikal
                    VerticalDivider(
                      color: Colors.grey[300],
                      thickness: 1,
                      indent: 5,
                      endIndent: 5,
                    ),
                    
                    // Kolom Bayu
                    Expanded(
                      child: Column(
                        children: [
                          const Text('Bayu Rahmat N.', 
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text('23090106', 
                            style: TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}