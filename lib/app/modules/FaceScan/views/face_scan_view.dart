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
            const SizedBox(height: 40),
            const Text(
              "Posisikan Wajah di Dalam Lingkaran",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Pastikan pencahayaan cukup terang, Beh!",
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 40),

            // 🟢 AREA KAMERA BULAT ANTI-GEPENG & ANTI-BLACK SCREEN
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

                return ClipOval(
                  child: SizedBox(
                    width: 280,
                    height: 280,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.center,
                        child: FittedBox(
                          fit: BoxFit
                              .cover, // Memotong bagian luar sensor agar aspek rasio wajah tetap 1:1 normal
                          child: SizedBox(
                            // Mengambil nilai dimensi render asli dari aspek fisik sensor HP Realme lu
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
                            child: CameraPreview(controller.cameraController!),
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
                          label: const Text(
                            "Mulai Pindai Wajah",
                            style: TextStyle(
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
