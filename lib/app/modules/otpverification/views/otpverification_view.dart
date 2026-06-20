import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/otpverification_controller.dart';

class OtpVerificationView extends StatelessWidget {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final OtpVerificationController controller = Get.put(
      OtpVerificationController(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFE8FFF0), // Nuansa hijau RuangSisa
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Color(0xFF2D6A4F)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Ikon Surat/Keamanan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 48,
                  color: Color(0xFF2D6A4F),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verifikasi Kode OTP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F5238),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  'Kami telah mengirimkan 6 digit kode rahasia ke alamat email:\n${controller.emailUser.value}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),

              // 🟢 6 KOTAK INPUT OTP HORIZONTAL (SUDAH DISESUAIKAN, BEH!)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width:
                        50, // ◄ Sedikit dikecilkan dari 60 ke 50 biar muat dan estetik di layar HP
                    height: 55,
                    child: TextField(
                      controller: controller.otpControllers[index],
                      focusNode: controller.focusNodes[index],
                      onChanged: (value) {
                        // 🟢 FIXED: Otomatis lompat ke kotak kanan sampai kotak terakhir (index 5)
                        if (value.isNotEmpty && index < 5) {
                          controller.focusNodes[index + 1].requestFocus();
                        }
                        // 🔴 Otomatis balik ke kotak kiri kalau di-backspace/hapus
                        if (value.isEmpty && index > 0) {
                          controller.focusNodes[index - 1].requestFocus();
                        }
                      },
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D6A4F),
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          1,
                        ), // Cuma boleh 1 angka per kotak
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets
                            .zero, // Biar angkanya pas di tengah-tengah kotak
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF2D6A4F),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // 🚀 TOMBOL VERIFIKASI ANTI-SPAM
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
                            backgroundColor: const Color(0xFF2D6A4F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            controller.verifyOtpAction();
                          },
                          child: const Text(
                            'Verifikasi Kode',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
