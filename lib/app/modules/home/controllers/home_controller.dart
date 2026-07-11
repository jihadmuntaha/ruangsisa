import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/post_provider.dart';
// 🟢 1. TAMBAHKAN IMPORT CONTROLLER NOTIFIKASI LU
import '../../notification/controllers/notification_controller.dart';
import '../../../data/services/notification_service.dart';

class HomeController extends GetxController {
  final PostProvider _postProvider = Get.put(PostProvider());

  // 🟢 2. SUNTIKKAN NOTIFICATION CONTROLLER DI SINI
  final NotificationController _notificationController = Get.put(
    NotificationController(),
  );

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
