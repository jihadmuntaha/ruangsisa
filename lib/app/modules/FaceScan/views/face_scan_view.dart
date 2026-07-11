import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/face_scan_controller.dart';

class FaceScanView extends GetView<FaceScanController> {
  const FaceScanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF002114),
      appBar: AppBar(
        title: Text(
          controller.mode == 'register' ? 'Daftar Face ID' : 'Pemindai Wajah',
        ),
        backgroundColor: const Color(0xFF2D6A4F),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            // 🍏 1. INDIKATOR STEP LANGKAH (Hanya muncul saat mode registrasi)
            if (controller.mode == 'register')
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D6A4F).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Langkah ${controller.currentStep.value} dari 3",
                    style: const TextStyle(
                      color: Color(0xFF52B788),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 🍏 2. FIX TEXT UTAMA: Sekarang dinamis mengikuti pergerakan muka lu!
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Obx(
                () => Text(
                  controller.stepInstruction.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),
            Text(
              "Pastikan pencahayaan cukup terang!",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 30),

            // 🟢 AREA KAMERA BULAT ANTI-GEPENG & ANTI-BLACK SCREEN (Udah Mantap)
            Center(
              child: Obx(() {
                if (!controller.isCameraInitialized.value ||
                    controller.cameraController == null) {
                  return const SizedBox(
                    width: 280,
                    height: 280,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2D6A4F),
                      ),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: controller.isLoading.value
                          ? const Color(0xFF52B788)
                          : const Color(0xFF2D6A4F),
                      width: 4,
                    ),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 272,
                      height: 272,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width:
                                  controller
                                      .cameraController!
                                      .value
                                      .previewSize
                                      ?.height ??
                                  1080,
                              height:
                                  controller
                                      .cameraController!
                                      .value
                                      .previewSize
                                      ?.width ??
                                  1920,
                              child: CameraPreview(
                                controller.cameraController!,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),

            const Spacer(),

            // TOMBOL EKSEKUSI JEP RET BIOMETRIK
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: controller.isLoading.value
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D6A4F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => controller.captureAndSendFace(),
                          icon: const Icon(
                            Icons.face_unlock_outlined,
                            color: Colors.white,
                          ),
                          // 🍏 Teks tombol dinamis menyesuaikan alur eksekusi
                          label: Text(
                            controller.mode == 'register'
                                ? (controller.currentStep.value == 3
                                      ? "Kunci Data Wajah"
                                      : "Ambil Foto Sudut Ini")
                                : "Mulai Pindai Wajah",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
