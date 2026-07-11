import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/post_provider.dart';
// 🟢 1. TAMBAHKAN IMPORT CONTROLLER NOTIFIKASI LU
import '../../notification/controllers/notification_controller.dart';
import '../../../data/services/notification_service.dart';
import 'package:ruang_sisa/app/modules/chat/controllers/chat_controller.dart';
import 'package:ruang_sisa/app/modules/main_wrapper/controllers/main_wrapper_controller.dart'; // Sesuaikan dengan path file asli lu

class HomeController extends GetxController {
  final PostProvider _postProvider = Get.put(PostProvider());

  // 🟢 2. SUNTIKKAN NOTIFICATION CONTROLLER DI SINI
  final NotificationController _notificationController = Get.put(
    NotificationController(),
  );
  final int currentUserId =
      2; // Sesuaikan dengan cara lu mengambil ID user login (misal dari GetStorage)

  late ScrollController scrollController;
  var isLoading = false.obs;
  var postsList = <Map<String, dynamic>>[].obs;
  var userData = Rxn<Map<String, dynamic>>();

  var selectedCategoryId = Rx<int?>(null);

  // 🟢 3. IKAT UNREAD COUNT KE DAFTAR NOTIFIKASI YANG BELUM DIBACA ('is_read' == 'false')
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    Get.find<NotificationService>().getDeviceToken();
    scrollController = ScrollController();
    loadUserData();
    fetchTimelinePosts();

    // 🟢 4. LISTEN PERUBAHAN SECARA REAL-TIME
    // Setiap kali list notifications berubah, hitung ulang jumlah yang belum dibaca
    ever(_notificationController.notifications, (_) {
      unreadCount.value = _notificationController.notifications
          .where((notif) => notif['is_read'] == 'false')
          .length;
    });
  }

  // Di dalam class HomeController extends GetxController:

  void goToChatFromHome(Map<String, dynamic> post) {
    final int ownerId = int.tryParse(post['user_id'].toString()) ?? 0;

    // Ekstrak nama pemilik secara aman (baik berupa string maupun map)
    String ownerName = 'Pemilik Material';
    if (post['user_name'] != null) {
      ownerName = post['user_name'] is Map
          ? post['user_name']['name']?.toString() ?? 'Pemilik Material'
          : post['user_name'].toString();
    } else if (post['author'] != null) {
      ownerName = post['author'] is Map
          ? post['author']['name']?.toString() ?? 'Pemilik Material'
          : post['author'].toString();
    }

    final String postTitle = post['title']?.toString() ?? 'Material';
    final String type = post['post_type']?.toString() ?? '';

    // Set pesan otomatis berdasarkan type postingan
    String templateMessage =
        "Halo $ownerName, saya tertarik dengan donasi material '$postTitle' ini. Apakah masih tersedia?";
    if (type == 'Dijual') {
      templateMessage =
          "Halo $ownerName, saya tertarik untuk membeli material '$postTitle'. Apakah barangnya masih ada?";
    } else if (type == 'Barter') {
      templateMessage =
          "Halo $ownerName, saya ingin mengajukan penawaran barter untuk material '$postTitle'. Boleh nego tipis?";
    }

    // 🟢 1. Geser Tab Menu Utama Aplikasi secara halus ke Index 3 (Menu Pesan)
    if (Get.isRegistered<MainWrapperController>()) {
      Get.find<MainWrapperController>().changeTabIndex(3);
    }

    // 🟢 2. Akses memori ChatController, suntik data, lalu paksa buka pipa API room-nya
    if (Get.isRegistered<ChatController>()) {
      final chatCtrl = Get.find<ChatController>();
      chatCtrl.setChatPartner(ownerId, ownerName);
      chatCtrl.chatRoomId.value =
          0; // Reset ke 0 agar memicu trigger pembuatan room baru di backend
      chatCtrl.messageController.text =
          templateMessage; // Suntik pesan otomatis lu

      chatCtrl.initiateChatRoom();
    } else {
      // Jalur cadangan aman jika controller belum ter-inject murni
      Get.toNamed(
        '/chat',
        arguments: {
          'user_id': ownerId.toString(),
          'name': ownerName,
          'post_id': post['id'].toString(),
        },
      );
    }

    // 🟢 NOTE: Di sini KITA TIDAK MENGGUNAKAN Get.back();
    // Biar aplikasi langsung fokus pindah ke tab chat tanpa menutup halaman utama (Home).
  }

  void loadUserData() {
    final box = GetStorage();
    final user = box.read('user');
    if (user != null) {
      userData.value = user;
      print("👤 [HOME] User loaded: ${user['name']}");
    }
  }

  void handleHomeTap() {
    if (scrollController.hasClients && scrollController.offset > 0) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
    fetchTimelinePosts();
  }

  Future<void> fetchTimelinePosts({int? categoryId}) async {
    try {
      isLoading(true);

      final activeCategoryId = categoryId ?? selectedCategoryId.value;
      print("🔄 Fetching posts with category: ${activeCategoryId ?? 'Semua'}");

      final response = await _postProvider.getPosts(
        categoryId: activeCategoryId,
      );

      if (response.statusCode == 200 && response.body != null) {
        if (response.body is List) {
          final List<dynamic> data = response.body;
          postsList.assignAll(
            data.map((item) => Map<String, dynamic>.from(item)).toList(),
          );
          print("✅ Loaded ${postsList.length} posts");
        } else {
          print("⚠️ Unexpected response format: ${response.body.runtimeType}");
          postsList.clear();
        }
      } else if (response.statusCode == 401) {
        Get.offAllNamed('/login');
        Get.snackbar("Sesi Habis", "Silakan login kembali");
      } else {
        print("⚠️ Failed to load posts: ${response.statusCode}");
        postsList.clear();
      }
    } catch (e) {
      print("❌ Error fetching posts: $e");
      postsList.clear();
    } finally {
      isLoading(false);
    }
  }

  // 🟢 5. SINKRONKAN PADA METHOD REFRESH DATA
  Future<void> refreshData() async {
    await fetchTimelinePosts();
    loadUserData();
    // Tarik data notifikasi terbaru juga pas user melakukan pull-to-refresh
    _notificationController.fetchNotifications();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
