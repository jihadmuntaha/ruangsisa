import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:camera/camera.dart'; // ◄ FIXED: Tambah titik koma (;) biar gak eror syntaks
import 'app/routes/app_pages.dart';

// 🟢 VARIABEL GLOBAL: Menampung daftar hardware kamera HP Realme lu
List<CameraDescription> cameras = [];

void main() async {
  // 1. Pastikan binding Flutter sudah siap sebelum inisialisasi library pihak ketiga
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi GetStorage untuk session token login lokal
  await GetStorage.init();

  try {
    // 3. FIXED: Ambil semua list sensor kamera (Depan & Belakang) saat aplikasi pertama start
    cameras = await availableCameras();
    print(
      "📸 [CAMERA] Sukses mendeteksi ${cameras.length} sensor kamera perangkat.",
    );
  } catch (e) {
    print("🚨 [CAMERA INIT ERROR] Gagal meload sensor kamera: $e");
  }

  runApp(
    GetMaterialApp(
      title: "RuangSisa",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D6A4F),
        scaffoldBackgroundColor: Colors.white,
      ),
    ),
  );
}
