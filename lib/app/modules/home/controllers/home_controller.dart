import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/post_provider.dart';

class HomeController extends GetxController {
  final PostProvider _postProvider = Get.put(PostProvider());

  late ScrollController scrollController;
  var isLoading = false.obs;
  var postsList = <Map<String, dynamic>>[].obs;
  var userData = Rxn<Map<String, dynamic>>();

  var selectedCategoryId = Rx<int?>(null);
  var unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    loadUserData();
    fetchTimelinePosts();
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
        // ✅ Response body sudah berupa List dari provider
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

  Future<void> refreshData() async {
    await fetchTimelinePosts();
    loadUserData();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
