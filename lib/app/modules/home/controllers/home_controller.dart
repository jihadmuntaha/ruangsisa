import 'package:flutter/material.dart'; // ◄ Pastikan import ini ada untuk ScrollController
import 'package:get/get.dart';
import 'package:ruang_sisa/app/data/providers/post_provider.dart';

class HomeController extends GetxController {
  final PostProvider _postProvider = Get.put(PostProvider());

  // 🟢 Tambahkan ScrollController untuk mendeteksi pergerakan list barang
  late ScrollController scrollController;

  var isLoading = false.obs;
  var postsList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController(); // ◄ Hidupkan scroll controller
    fetchTimelinePosts();
  }

  // 🟢 Fungsi Sakti khusus saat Tombol Home Navbar diketuk
  void handleHomeTap() {
    if (scrollController.hasClients) {
      // Jika posisi screen lagi di bawah, tendang balik ke paling atas dengan animasi halus
      if (scrollController.offset > 0) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    }
    // Jalankan refresh data otomatis setelahnya
    fetchTimelinePosts();
  }

  // Fungsi narik data dari FastAPI (Tetap sama seperti bawaan lu)
  Future<void> fetchTimelinePosts({int? categoryId}) async {
    try {
      isLoading(true);
      final response = await _postProvider.getPosts(categoryId: categoryId);

      if (response.statusCode == 200) {
        if (response.body != null) {
          postsList.assignAll(response.body);
        }
      } else {
        Get.snackbar("Eror", "Gagal mengambil data dari server, Beh!");
      }
    } catch (e) {
      Get.snackbar("Eror Exception", e.toString());
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    scrollController.dispose(); // ◄ Matikan secara aman pas controller mati
    super.onClose();
  }
}
