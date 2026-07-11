import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../../profile/controllers/profile_post_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class EditPostController extends GetxController {
  var isLoading = false.obs;
  final String baseUrl = "https://ruangsisa-backend-livid.vercel.app/api";

  final formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController wishlistController;

  late int postId;
  late String postType;

  @override
  void onInit() {
    super.onInit();
    // 📥 Tangkap data argument 'post' yang dilempar dari view sebelumnya
    final Map<String, dynamic> args = Get.arguments['post'] ?? {};

    postId = args['id'] ?? 0;
    postType = args['post_type'] ?? 'Donasi';

    titleController = TextEditingController(text: args['title'] ?? '');
    descController = TextEditingController(text: args['description'] ?? '');
    priceController = TextEditingController(
      text: args['price']?.toString() ?? '',
    );
    wishlistController = TextEditingController(
      text: args['barter_wishlist'] ?? '',
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    priceController.dispose();
    wishlistController.dispose();
    super.onClose();
  }

  Future<bool> updatePost() async {
    try {
      isLoading.value = true;

      final box = GetStorage();
      String activeToken = box.read('token') ?? box.read('access_token') ?? '';

      // Susun body payload sesuai kebutuhan API Vercel lu
      Map<String, dynamic> bodyData = {
        'title': titleController.text,
        'description': descController.text,
        'price': postType == 'Dijual'
            ? int.tryParse(priceController.text) ?? 0
            : null,
        'barter_wishlist': postType == 'Barter'
            ? wishlistController.text
            : null,
      };

      final response = await http
          .put(
            Uri.parse("$baseUrl/posts/$postId"),
            headers: {
              'Authorization': 'Bearer $activeToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(bodyData),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        Get.snackbar(
          "Sukses",
          "Postingan berhasil diperbarui di RuangSisa! 📝✨",
        );

        // 🔄 REFRESH SEMUA INSTANCE HALAMAN BIAR SINKRON
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().onInit();
        }
        if (Get.isRegistered<ProfilePostController>()) {
          Get.find<ProfilePostController>().fetchMyPosts();
        }

        return true;
      } else {
        Get.snackbar(
          "Gagal",
          "Gagal update postingan (Status: ${response.statusCode})",
        );
        return false;
      }
    } catch (e) {
      Get.snackbar("Eror", "Koneksi backend bermasalah: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
