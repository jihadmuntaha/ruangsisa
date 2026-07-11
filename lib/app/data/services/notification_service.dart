import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ruang_sisa/app_config.dart';

// 🔥 TOP-LEVEL HANDLER: Wajib ada di luar class untuk menangani pesan saat aplikasi mati total/background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
    "💤 [FCM BACKGROUND] Menerima pesan di latar belakang: ${message.messageId}",
  );
}

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // 🟢 SUNTIKKAN: Pemicu notifikasi lokal sistem Android
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // 🟢 SUNTIKKAN: Konfigurasi Android Channel dengan Importance MAX (Wajib buat Redmi/Realme banner atas)
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'ruangsisa_notification_channel', // ID Channel
    'Notifikasi RuangSisa', // Nama Channel di Setelan HP
    description: 'Channel utama push notification aplikasi RuangSisa',
    importance: Importance.max, // Bikin banner meletup di atas layar murni!
    playSound: true,
    enableVibration: true,
  );

  Future<NotificationService> init() async {
    // Daftarkan background handler pertama kali
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await _requestPermission();
    await _initLocalNotifications(); // Inisialisasi plugin notifikasi lokal
    await _initFcmListeners();
    await getDeviceToken();
    return this;
  }

  // 1. Minta izin memunculkan notifikasi di HP lu
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );
    print('🔔 [FCM PERMISSION] Status Izin: ${settings.authorizationStatus}');
  }

  // 🟢 LENGKAP: Handler klik untuk notifikasi Lokal (Aplikasi sedang Foreground / Terbuka)
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("🚀 [LOCAL NOTIF CLICK] User mengklik banner notifikasi!");

        // Amankan pengecekan payload
        if (response.payload == null || response.payload!.isEmpty) {
          print("⚠️ Payload kosong, langsung lempar ke notifikasi umum.");
          Get.toNamed('/notification');
          return;
        }

        try {
          Map<String, dynamic> data = jsonDecode(response.payload!);
          String? type = data['type']?.toString();

          // 🎯 A. JALUR NOTIFIKASI CHAT
          if (type == 'chat' && data.containsKey('chat_id')) {
            String chatId = data['chat_id'].toString();
            print("➡️ [NAVIGASI] Lompat langsung ke Room Chat ID: $chatId");

            // Pindah halaman dengan penanganan argument yang aman
            Get.toNamed('/chat_room', arguments: {'chat_id': chatId});
            return; // 🛑 BERHENTI DI SINI MURNI!
          }
          // 🎯 B. JALUR NOTIFIKASI KOMENTAR
          else if (type == 'comment' && data.containsKey('post_id')) {
            String postId = data['post_id'].toString();
            print(
              "➡️ [NAVIGASI] Lompat langsung ke Detail Postingan ID: $postId",
            );
            Get.toNamed('/post-detail', arguments: {'post_id': postId});
            return; // 🛑 BERHENTI DI SINI MURNI!
          }
        } catch (e) {
          print("🚨 [PAYLOAD ERROR] Gagal bongkar payload klik: $e");
        }

        // 🟢 MASUKKAN KODE INI KE DALAM BLOK ELSE JIKA TIDAK MENEMUKAN TYPE APAPUN
        print("💡 Tipe notif tidak spesifik, lempar ke halaman umum.");
        Get.toNamed('/notification');
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);

    print("✅ [FCM LOCAL] Android Notification Channel Berhasil Dikunci!");
  }

  // 2. Ambil Token FCM unik dari HP lu dan sinkronisasikan ke FastAPI
  Future<String?> getDeviceToken() async {
    String? token = await _fcm.getToken();
    print('\n==================================================');
    print('🔑 [FCM TOKEN HP LU] Sukses Tergenerate:');
    print('$token');
    print('==================================================\n');

    if (token != null) {
      await _updateTokenToBackend(token);
    }

    return token;
  }

  // Fungsi pembantu nembak API FastAPI laptop lu (SUDAH DI-REPAIR TOTAL)
  Future<void> _updateTokenToBackend(String token) async {
    try {
      final box = GetStorage();
      final tokenAuth = box.read('token');

      if (tokenAuth != null) {
        final String apiUrl = '${AppConfig.baseUrl}/api/users/fcm-token';
        print("📡 Menghubungkan token FCM ke Backend Vercel: $apiUrl");

        // 🟢 MENGGUNAKAN HTTP CLIENT STANDARD AGAR REKONSILIASI HEADER LEBIH STABIL & PASTI TEMBUS
        final response = await http.put(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $tokenAuth',
          },
          body: jsonEncode({'fcm_token': token}),
        );

        if (response.statusCode == 200) {
          print(
            "✅ [FCM BACKEND] Token sukses disinkronkan ke DB SQLite backend, Jihad!",
          );
        } else {
          print(
            "⚠️ [FCM BACKEND] Server merespon, tapi gagal simpan token. Status: ${response.statusCode} | Body: ${response.body}",
          );
        }
      } else {
        print(
          "⚠️ [FCM BACKEND] Sinkronisasi ditunda karena user belum login (Token Auth null).",
        );
      }
    } catch (e) {
      print(
        "🚨 [FCM BACKEND ERROR] Gagal total menghubungkan token ke server: $e",
      );
    }
  }

  // 3. Listener saat aplikasi terbuka (Foreground) atau di background
  Future<void> _initFcmListeners() async {
    // =======================================================================
    // Jalur 1: Pas aplikasi lagi dibuka (Foreground)
    // =======================================================================
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 [FCM FOREGROUND] Ada pesan masuk murni!');

      final notification = message.notification;
      if (notification != null) {
        // Ambil map data payload asli dari backend FastAPI
        Map<String, dynamic> dataPayload = message.data;

        _localNotificationsPlugin.show(
          id: notification.hashCode,
          title: notification.title ?? 'Notifikasi Baru',
          body: notification.body ?? '',
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channel.id,
              _channel.name,
              channelDescription: _channel.description,
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
              playSound: true,
            ),
          ),
          // Menggunakan jsonEncode agar format string payload-nya valid JSON murni pas dibaca lokal click
          payload: jsonEncode(dataPayload),
        );

        // Snackbar GetX pelengkap estetika di app
        Get.snackbar(
          notification.title ?? 'Notifikasi Baru',
          notification.body ?? '',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    });

    // =======================================================================
    // Jalur 2: Pas aplikasi diklik dari status BACKGROUND atau MATI (Terminated)
    // =======================================================================
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🚀 [FCM OPENED] User mengklik notifikasi dari background!');

      String? type = message.data['type']?.toString();

      // 🎯 A. JALUR NOTIFIKASI CHAT VIA BACKGROUND
      if (type == 'chat' && message.data.containsKey('chat_id')) {
        String chatId = message.data['chat_id'].toString();
        print(
          "➡️ [NAVIGASI BACKGROUND] Langsung lompat ke Chat Room ID: $chatId",
        );
        Get.toNamed('/chat_room', arguments: {'chat_id': chatId});
      }
      // 🎯 B. JALUR NOTIFIKASI KOMENTAR VIA BACKGROUND
      else if (type == 'comment' && message.data.containsKey('post_id')) {
        String postId = message.data['post_id'].toString();
        print(
          "➡️ [NAVIGASI BACKGROUND] Langsung lompat ke Detail Post ID: $postId",
        );
        Get.toNamed('/post-detail', arguments: {'post_id': postId});
      } else {
        Get.toNamed('/notification');
      }
    });
  }
}
