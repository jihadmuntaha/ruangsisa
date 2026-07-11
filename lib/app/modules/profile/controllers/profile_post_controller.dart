import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // 🟢 Tambahkan impor GetStorage agar fungsi box bisa jalan
import 'package:http/http.dart' as http;
import 'package:ruang_sisa/app/modules/profile/controllers/profile_controller.dart';
import '../../../data/models/my_post_model.dart';

class ProfilePostController extends GetxController {
  var myPosts = <MyPostModel>[].obs;
  var isLoading = false.obs;

  // URL Backend Vercel RuangSisa lu
  final String baseUrl = "https://ruangsisa-backend-livid.vercel.app/api";

  @override
  void onInit() {
    fetchMyPosts();
    super.onInit();
  }

  // 📥 1. AMBIL LIST POSTINGAN SAYA (DENGAN TOKEN ASLI)
  Future<void> fetchMyPosts() async {
    try {
      isLoading.value = true;

      // 🔑 AMBIL TOKEN DINAMIS DARI STORAGE SESUAI STRUKTUR RUANGSISA LU
      final box = GetStorage();
      String activeToken = box.read('token') ?? box.read('access_token') ?? '';

      if (activeToken.isEmpty) {
        Get.snackbar(
          "Akses Ditolak",
          "Token login lu gak ketemu atau udah expired, Beh! 🔑❌",
        );
        return;
      }

      final response = await http
          .get(
            Uri.parse("$baseUrl/my-posts"),
            headers: {
              'Authorization':
                  'Bearer $activeToken', // 🔒 Kirim token asli kontributor
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        myPosts.assignAll(data.map((x) => MyPostModel.fromJson(x)).toList());
      } else {
        print("Gagal fetchMyPosts, Status Code: ${response.statusCode}");
      }
    } catch (e) {
      Get.snackbar("Eror", "Gagal mengambil postingan lu, Beh: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🗑️ 2. HAPUS POSTINGAN (DENGAN TOKEN ASLI)
  Future<bool> deletePost(int postId) async {
    try {
      isLoading.value = true;
      print("🗑️ Mencoba hapus postingan dengan ID: $postId");

      // 🔑 AMBIL TOKEN DINAMIS DARI STORAGE SESUAI STRUKTUR RUANGSISA LU
      final box = GetStorage();
      String activeToken = box.read('token') ?? box.read('access_token') ?? '';

      if (activeToken.isEmpty) {
        Get.snackbar(
          "Akses Ditolak",
          "Token login lu gak ketemu atau udah expired, Beh! 🔑❌",
        );
        return false;
      }

      final response = await http
          .delete(
            Uri.parse("$baseUrl/posts/$postId"),
            headers: {
              'Authorization':
                  'Bearer $activeToken', // 🔒 Kirim token asli kontributor
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        Get.snackbar(
          "Sukses",
          "Postingan berhasil didepak dari RuangSisa! 🗑️",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2D6A4F),
          colorText: Color.fromARGB(255, 255, 255, 255),
          duration: const Duration(seconds: 2),
        );

        // 🔄 1. Refresh list profil utama
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().onInit();
        }

        // 🔄 2. Refresh list internal tab ini
        await fetchMyPosts();

        // 🚀 3. KUNCI FIX: Cek rute aktif menggunakan Get.routing.current murni
        print(
          "LOG ROUTE SEKARANG: ${Get.routing.current}",
        ); // Buat mastiin di console lu

        if (Get.routing.current == '/post-detail' ||
            Get.routing.current.contains('detail')) {
          Get.back(); // Paksa nutup halaman detail murni
        }

        return true;
      } else {
        Get.snackbar(
          "Gagal",
          "Akses ditolak atau server sedang sibuk (Status: ${response.statusCode}).",
        );
        return false;
      }
    } catch (e) {
      Get.snackbar("Eror", "Gagal menghapus: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
