import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // 🟢 1. TAMBAH IMPORT LOCAL NOTIF INI
import 'app/routes/app_pages.dart';
import 'app/data/services/notification_service.dart';

// 🟢 2. CONFIG CHANNEL SAKTI: Set importance ke max agar Android maksa nampilin banner pop-up
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'ruangsisa_high_channel', // ◄ Kunci ID Channel (Bebas, tapi catat ini buat backend nanti!)
  'Notifikasi Penting RuangSisa',
  description:
      'Channel ini digunakan untuk meletupkan notifikasi chat, like, dan komen secara real-time.',
  importance: Importance.max,
  playSound: true,
  enableVibration: true,
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi GetStorage
  await GetStorage.init();

  // 2. Inisialisasi Firebase & Notification Channel
  try {
    await Firebase.initializeApp();

    // 🟢 3. DAFTARKAN CHANNEL KE SISTEM OPERASI ANDROID
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    print("🔔 [FCM CHANNEL] Android Notification Channel sukses terdaftar!");

    // Jalankan Notification Service GetX lu
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
