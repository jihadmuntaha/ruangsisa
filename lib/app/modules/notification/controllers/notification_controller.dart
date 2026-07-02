import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationController extends GetxController {
  var notifications =
      <Map<String, dynamic>>[].obs; // Ubah jadi dynamic biar fleksibel
  var isLoading = false.obs;

  // Instance GetConnect buat nembak FastAPI laptop lu
  final GetConnect _connect = GetConnect();
  // Alamat IP local laptop lu
  final String baseUrl = 'http://10.20.166.45:8000/api';

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _listenIncomingFcm(); // 🟢 SUNTIKKAN LISTENER: Biar notifikasi masuk langsung nongol di UI
  }

  // 1. Tarik riwayat notifikasi asli dari database backend lu
  void fetchNotifications() async {
    try {
      isLoading.value = true;
      final box = GetStorage();
      final tokenAuth = box.read('token'); // Token JWT login lu

      if (tokenAuth != null) {
        // Nembak endpoint riwayat notifikasi asli di FastAPI lu
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

  // 2. 🟢 LISTENER REAL-TIME: Menangkap data FCM dan langsung menyuntikkannya ke dalam List UI
  void _listenIncomingFcm() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        // Rakit data notifikasi baru dari payload Google FCM secara dinamis
        final Map<String, dynamic> newNotif = {
          "id":
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          "title": notification.title ?? "Pesan Baru",
          "body": notification.body ?? "",
          "time": "Just now",
          "is_read": "false",
          // 🟢 AMANKAN PAYLOAD: Ambil parameter routing tipe & reference_id secara langsung pas live chat/komen masuk
          "type": message.data['type']?.toString(),
          "reference_id":
              message.data['chat_id']?.toString() ??
              message.data['post_id']?.toString(),
        };

        // Sisipkan ke tumpukan paling atas list secara reaktif! UI otomatis berubah murni
        notifications.insert(0, newNotif);
      }
    });
  }

  // 3. 🟢 FUNGSI KLIK DINAMIS: Dipanggil pas baris item notifikasi di-tap oleh user
  void onNotificationTap(int index, Map<String, dynamic> notif) {
    print("🎯 [LIST NOTIF CLICK] Mengolah aksi klik untuk: $notif");

    // Otomatis tandai sebagai sudah dibaca pas di-klik
    String notifId = notif['id'].toString();
    markAsRead(index, notifId);

    // Ambil data tipe dan reference target dari database SQLite backend lu
    String? type = notif['type']?.toString();
    String? referenceId = notif['reference_id']?.toString();

    if (referenceId == null || referenceId.isEmpty || referenceId == "null") {
      print(
        "⚠️ [NAVIGASI SKIP] Reference ID kosong murni, navigasi spesifik dibatalkan.",
      );
      return;
    }

    // 🎯 ALUR A: KLIK NOTIFIKASI CHAT (Lompat ke Room Chat bawa data chat_id)
    if (type == 'chat') {
      print("➡️ [NAVIGASI CHAT] Meluncur murni ke Room Chat ID: $referenceId");

      // Sinkron dengan argument 'chat_id' milik ChatController lu tadi!
      Get.toNamed('/chat-room', arguments: {'chat_id': referenceId});
    }
    // 🎯 ALUR B: KLIK NOTIFIKASI KOMENTAR (Lompat ke Detail Postingan bawa data post_id)
    else if (type == 'comment') {
      print(
        "➡️ [NAVIGASI KOMENTAR] Meluncur murni ke Detail Postingan ID: $referenceId",
      );

      // Sinkron dengan parameter detail postingan RuangSisa lu!
      Get.toNamed('/post-detail', arguments: {'post_id': referenceId});
    }
  }

  void markAsRead(int index, String notifId) async {
    var updatedItem = Map<String, dynamic>.from(notifications[index]);
    updatedItem['is_read'] = 'true';
    notifications[index] = updatedItem;

    // 🟢 FIX SAKTI: Kalau ID notifikasi mengandung karakter bawaan Google FCM, skip tembak ke DB SQLite
    if (notifId.contains(':') || notifId.contains('%')) {
      print(
        "💡 [MARK READ] Notif real-time lokal, tidak perlu sinkronisasi ke DB SQLite.",
      );
      return;
    }

    try {
      final box = GetStorage();
      final tokenAuth = box.read('token');
      if (tokenAuth != null) {
        // Hanya tembak kalau ID-nya berupa integer murni dari DB backend
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

  // Menghapus notifikasi dari daftar (Swipe to Dismiss)
  void deleteNotification(int index, String notifId) async {
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
