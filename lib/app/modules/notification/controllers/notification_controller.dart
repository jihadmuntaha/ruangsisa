import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationController extends GetxController {
  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  final GetConnect _connect = GetConnect();
  final String baseUrl = 'http://10.20.166.45:8000/api';

  @override
  void onInit() {
    super.onInit();
    _initForegroundNotificationSettings(); // 🟢 1. AKTIFKAN OPSI PRESENTASI OS ANDROID
    fetchNotifications();
    _listenIncomingFcm();
  }

  // 🟢 FUNGSI BARU: Paksa OS Android biar tetep ngijinin banner & suara masuk walau aplikasi lagi dibuka
  void _initForegroundNotificationSettings() async {
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true, // Heads-up banner tetep nongol di atas layar
            badge: true, // Counter angka di icon HP terupdate
            sound: true, // Suara notif tetep bunyi nyaring
          );
    } catch (e) {
      print("⚠️ Gagal set foreground presentation options: $e");
    }
  }

  void fetchNotifications() async {
    try {
      isLoading.value = true;
      final box = GetStorage();
      final tokenAuth = box.read('token');

      if (tokenAuth != null) {
        final response = await _connect.get(
          '$baseUrl/notifications',
          headers: {'Authorization': 'Bearer $tokenAuth'},
        );

        if (response.statusCode == 200 && response.body != null) {
          if (response.body is List) {
            final List<dynamic> data = response.body;
            notifications.assignAll(
              data.map((item) => Map<String, dynamic>.from(item)).toList(),
            );
          }
        } else {
          print(
            "⚠️ [GET NOTIF] Gagal memuat dari server: ${response.statusCode}",
          );
        }
      }
    } catch (e) {
      print("❌ Error fetch notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 2. 🟢 LISTENER REAL-TIME DENGAN AUTO HEADS-UP POP UP BANNER
  void _listenIncomingFcm() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        final Map<String, dynamic> newNotif = {
          "id":
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          "title": notification.title ?? "Pesan Baru",
          "body": notification.body ?? "",
          "time": "Just now",
          "is_read": "false",
          "type": message.data['type']?.toString(),
          "reference_id":
              message.data['chat_id']?.toString() ??
              message.data['post_id']?.toString() ??
              "1",
        };

        // 1. Masukkan ke tumpukan list halaman notifikasi
        notifications.insert(0, newNotif);

        // 2. 🔥 JURUS UTAMA: Letupkan Banner Pop-Up WhatsApp Style secara Real-Time pakai GetX!
        Get.snackbar(
          notification.title ?? "📩 Pesan Baru",
          notification.body ?? "Cek aplikasi RuangSisa sekarang, Beh!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(
            0xFF1B4332,
          ), // Hijau tua berkelas RuangSisa
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          icon: const Icon(Icons.mark_chat_unread_rounded, color: Colors.white),
          duration: const Duration(seconds: 4),
          shouldIconPulse: true,
          barBlur: 10,
          dismissDirection: DismissDirection.horizontal,
          // 🎯 BISA DI-TAP LANGSUNG: Kalau banner-nya di-klik pas melayang, otomatis langsung lompat ke room chat!
          onTap: (_) {
            onNotificationTap(0, newNotif);
          },
        );
      }
    });
  }

  // 3. 🟢 FUNGSI KLIK DINAMIS: DIJAMIN 100% BEBAS DARI NULL CHECK OPERATOR CRASH!
  void onNotificationTap(int index, Map<String, dynamic>? notif) {
    // 1. Validasi awal jika objek notif murni null
    if (notif == null) {
      print("⚠️ [NAVIGASI SKIP] Data notifikasi murni null.");
      return;
    }

    print("🎯 [LIST NOTIF CLICK] Mengolah aksi klik untuk: $notif");

    // 2. Amankan ID Notifikasi secara null-safe tanpa tanda seru kaku
    String notifId = (notif['id'] ?? DateTime.now().millisecondsSinceEpoch)
        .toString();

    // Amankan pengecekan index sebelum panggil markAsRead
    if (notifications.isNotEmpty && index < notifications.length) {
      markAsRead(index, notifId);
    }

    // 3. Amankan data tipe dan reference secara null-safe murni
    String type = notif['type']?.toString() ?? '';
    String referenceId = notif['reference_id']?.toString() ?? '';

    if (referenceId.isEmpty || referenceId == "null") {
      print(
        "⚠️ [NAVIGASI SKIP] Reference ID kosong murni, navigasi spesifik dibatalkan.",
      );
      return;
    }

    // 🎯 ALUR A: KLIK NOTIFIKASI CHAT (Lompat ke Room Chat bawa data chat_id)
    if (type == 'chat') {
      print("➡️ [NAVIGASI CHAT] Meluncur murni ke Room Chat ID: $referenceId");

      // Ekstrak nama partner secara aman untuk dioper ke ChatController
      String cleanName =
          notif['title']
              ?.toString()
              .replaceAll('📩 Pesan Baru dari ', '')
              .replaceAll('!', '') ??
          'Kontributor RuangSisa';

      Get.toNamed(
        '/chat-room',
        arguments: {'chat_id': referenceId, 'name': cleanName},
      );
    }
    // 🎯 ALUR B: KLIK NOTIFIKASI KOMENTAR (Lompat ke Detail Postingan bawa data post_id)
    else if (type == 'comment') {
      print(
        "➡️ [NAVIGASI KOMENTAR] Meluncur murni ke Detail Postingan ID: $referenceId",
      );
      Get.toNamed('/post-detail', arguments: {'post_id': referenceId});
    }
  }

  void markAsRead(int index, String notifId) async {
    try {
      // Validasi indeks array secara ketat agar tidak memicu Out of Bounds / Null Exception
      if (notifications.isEmpty || index >= notifications.length) return;

      var updatedItem = Map<String, dynamic>.from(notifications[index]);
      updatedItem['is_read'] = 'true';
      notifications[index] = updatedItem;

      if (notifId.contains(':') || notifId.contains('%')) {
        print(
          "💡 [MARK READ] Notif real-time lokal, tidak perlu sinkronisasi ke DB SQLite.",
        );
        return;
      }

      final box = GetStorage();
      final tokenAuth = box.read('token');
      if (tokenAuth != null) {
        await _connect.put(
          '$baseUrl/notifications/$notifId/read',
          {},
          headers: {'Authorization': 'Bearer $tokenAuth'},
        );
      }
    } catch (e) {
      print("❌ Gagal sinkron status baca ke server: $e");
    }
  }

  void deleteNotification(int index, String notifId) async {
    if (index >= notifications.length) return;
    notifications.removeAt(index);
    Get.snackbar("Sukses 🗑️", "Notifikasi berhasil dihapus murni!");

    try {
      final box = GetStorage();
      final tokenAuth = box.read('token');
      if (tokenAuth != null) {
        await _connect.delete(
          '$baseUrl/notifications/$notifId',
          headers: {'Authorization': 'Bearer $tokenAuth'},
        );
      }
    } catch (e) {
      print("❌ Gagal menghapus notifikasi di server: $e");
    }
  }
}
