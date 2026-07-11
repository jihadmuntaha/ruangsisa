import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ruang_sisa/app/routes/app_pages.dart';
import 'package:ruang_sisa/app_config.dart';
import '../../../data/providers/notification_provider.dart';

class NotificationController extends GetxController {
  var notifications = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  // Tetap sediakan untuk method PUT/DELETE internal controller
  final GetConnect _connect = GetConnect();
  final String baseUrl = '${AppConfig.baseUrl}/api';

  // 1. Inisialisasi Provider secara rapi
  final notificationProvider = Get.put(NotificationProvider());

  @override
  void onInit() {
    super.onInit();
    _initForegroundNotificationSettings();
    fetchNotifications();
    _listenIncomingFcm();
  }

  void _initForegroundNotificationSettings() async {
    try {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      print("⚠️ Gagal set foreground presentation options: $e");
    }
  }

  // 🛠️ FUNGSI REFRESH / AMBIL NOTIFIKASI YANG SUDAH DIREPARASI TOTAL
  void fetchNotifications() async {
    try {
      isLoading.value = true;
      final box = GetStorage();
      final tokenAuth = box.read('token');

      if (tokenAuth == null) {
        print("⚠️ [GET NOTIF] Token kosong, batal memuat.");
        return;
      }

      print("📡 FE sedang memicu penarikan riwayat notifikasi via Provider...");
      final response = await notificationProvider.getMyNotifications();

      // 🟢 PEMBENARAN SAKLI: Cek properti statusCode murni untuk deteksi timeout/jaringan terputus
      if (response.statusCode == null) {
        print(
          "🚨 [GET NOTIF ERROR] Server Vercel drop atau GetConnect mengalami masalah jabat tangan SSL!",
        );
        return;
      }

      if (response.statusCode == 200 && response.body != null) {
        if (response.body is List) {
          final List<dynamic> data = response.body;

          // Mencegah error tipe data sewaktu parsing
          notifications.assignAll(
            data.map((item) {
              final mapItem = Map<String, dynamic>.from(item);

              // 🟢 PENGAMAN ZONA WAKTU MUTLAK:
              // Jika dari backend sudah mengirim string waktu (misal: created_at),
              // langsung konversi ke waktu lokal HP saat dimasukkan ke memori RX.
              if (mapItem['created_at'] != null) {
                try {
                  DateTime utcTime = DateTime.parse(
                    mapItem['created_at'].toString(),
                  );
                  // .toLocal() otomatis mengubah UTC jam server ke WIB jam HP lu
                  mapItem['time_display'] = utcTime
                      .toLocal()
                      .toString()
                      .substring(11, 16);
                } catch (_) {
                  mapItem['time_display'] = "Baru saja";
                }
              } else {
                mapItem['time_display'] = mapItem['time'] ?? "Baru saja";
              }

              return mapItem;
            }).toList(),
          );

          print(
            "✅ Berhasil memuat ${notifications.length} riwayat notifikasi dari DB SQLite Cloud!",
          );
        }
      } else {
        print(
          "⚠️ [GET NOTIF] Ditolak Server. Status: ${response.statusCode} | Body: ${response.body}",
        );
      }
    } catch (e) {
      print("❌ Error fetch notifications di Controller: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void _listenIncomingFcm() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        // Ambil jam sekarang murni dari jam internal HP lu
        final now = DateTime.now();
        final String formattedLocalTime =
            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

        final Map<String, dynamic> newNotif = {
          "id":
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          "title": notification.title ?? "Pesan Baru",
          "body": notification.body ?? "",
          "time_display": formattedLocalTime, // Jam lokal instan
          "time": "Just now",
          "is_read": "false",
          "type": message.data['type']?.toString(),
          "reference_id":
              message.data['chat_id']?.toString() ??
              message.data['post_id']?.toString() ??
              "1",
        };

        notifications.insert(0, newNotif);

        Get.snackbar(
          notification.title ?? "📩 Pesan Baru",
          notification.body ?? "Cek aplikasi RuangSisa sekarang!",
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFF1B4332),
          colorText: Colors.white,
          borderRadius: 12,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          icon: const Icon(Icons.mark_chat_unread_rounded, color: Colors.white),
          duration: const Duration(seconds: 4),
          shouldIconPulse: true,
          barBlur: 10,
          dismissDirection: DismissDirection.horizontal,
          onTap: (_) {
            onNotificationTap(0, newNotif);
          },
        );
      }
    });
  }

  void onNotificationTap(int index, Map<String, dynamic>? notif) {
    if (notif == null) {
      print("⚠️ [NAVIGASI SKIP] Data notifikasi murni null.");
      return;
    }

    print("🎯 [LIST NOTIF CLICK] Mengolah aksi klik untuk: $notif");
    String notifId = (notif['id'] ?? DateTime.now().millisecondsSinceEpoch)
        .toString();

    if (notifications.isNotEmpty && index < notifications.length) {
      markAsRead(index, notifId);
    }

    String type = notif['type']?.toString() ?? '';
    String referenceId = notif['reference_id']?.toString() ?? '';

    if (referenceId.isEmpty || referenceId == "null") {
      print(
        "⚠️ [NAVIGASI SKIP] Reference ID kosong murni, navigasi dibatalkan.",
      );
      return;
    }

    if (type == 'chat') {
      print(
        "➡️ [NAVIGASI CHAT] Meluncur aman lewat jalur User ID, ID: $referenceId",
      );

      String cleanName =
          notif['title']
              ?.toString()
              .replaceAll('📩 Pesan Baru dari ', '')
              .replaceAll('!', '') ??
          'Kontributor RuangSisa';

      Get.toNamed(
        Routes.CHAT,
        arguments: {
          'user_id': referenceId,
          'name': cleanName,
          'avatar': notif['avatar'] ?? "",
        },
      );
    } else if (type == 'comment') {
      print(
        "➡️ [NAVIGASI KOMENTAR] Meluncur murni ke Detail Postingan ID: $referenceId",
      );
      Get.toNamed('/post-detail', arguments: {'post_id': referenceId});
    }
  }

  void markAsRead(int index, String notifId) async {
    try {
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
