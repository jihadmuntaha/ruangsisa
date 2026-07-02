import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart'; // ◄ Tambah import ini
import 'app/routes/app_pages.dart';
import 'app/data/services/notification_service.dart'; // ◄ Tambah import service baru lu

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi GetStorage
  await GetStorage.init();

  // 2. 🟢 SUNTIKKAN INI: Jalankan Firebase murni sebelum aplikasi start
  try {
    await Firebase.initializeApp();
    // Jalankan Notification Service GetX
    await Get.putAsync(() => NotificationService().init());
  } catch (e) {
    print("🚨 [FIREBASE INIT ERROR] Gagal inisialisasi Firebase: $e");
  }

  // 3. Ambil sensor kamera bawaan lu
  try {
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
