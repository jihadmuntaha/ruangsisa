import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // ◄ Pastikan sudah tambah di pubspec.yaml
import 'package:ruang_sisa/app/data/providers/post_provider.dart';
import '../../home/controllers/home_controller.dart';

class AddPostController extends GetxController {
  final PostProvider _postProvider = Get.find<PostProvider>();
  final ImagePicker _picker =
      ImagePicker(); // ◄ Instansiasi alat pencari gambar

  late TextEditingController titleController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late TextEditingController wishlistController;

  var isLoading = false.obs;
  var selectedType = 'Donasi'.obs;
  var selectedCategoryId = 1.obs;

  // 🟢 State menampung jalur file gambar hasil foto/pilihan galeri
  var selectedImagePath = ''.obs;

  final List<String> postTypes = ['Donasi', 'Barter', 'Dijual'];

  @override
  void onInit() {
    super.onInit();
    titleController = TextEditingController();
    descController = TextEditingController();
    priceController = TextEditingController();
    wishlistController = TextEditingController();
  }

  // 🟢 Fungsi memicu Kamera atau Galeri di HP Lu
  void pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImagePath.value = image.path; // Simpan path gambarnya
      }
    } catch (e) {
      Get.snackbar("Gagal Ambil Gambar", e.toString());
    }
  }

  void submitPost() async {
    if (titleController.text.isEmpty || descController.text.isEmpty) {
      Get.snackbar(
        "Form Kosong",
        "Judul dan Deskripsi wajib diisi, Beh!",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    // Siapkan bodi payload JSON ke backend laptop
    Map<String, dynamic> payload = {
      "category_id": selectedCategoryId.value,
      "title": titleController.text.trim(),
      "description": descController.text.trim(),
      // 🟢 Jika ada foto pakai nama fotonya, jika kosongan beri default string
      "images": selectedImagePath.value.isNotEmpty
          ? selectedImagePath.value.split('/').last
          : "foto_barang_default.png",
      "post_type": selectedType.value,
      "price": selectedType.value == 'Dijual'
          ? int.tryParse(priceController.text) ?? 0
          : 0,
      "barter_wishlist": selectedType.value == 'Barter'
          ? wishlistController.text.trim()
          : null,
      "status": "pending",
    };

    try {
      isLoading(true);
      final response = await _postProvider.uploadPost(payload);

      if (response.statusCode == 201) {
        Get.snackbar(
          "Sukses",
          "Barang sisa berhasil diposting ke timeline!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _clearForm();
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().fetchTimelinePosts();
        }
        Get.offAllNamed('/main-wrapper');
      } else {
        String errorDetail =
            response.body?['detail'] ?? "Gagal memproses aturan postingan.";
        Get.snackbar(
          "Gagal",
          errorDetail,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Eror Exception",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  void _clearForm() {
    titleController.clear();
    descController.clear();
    priceController.clear();
    wishlistController.clear();
    selectedType('Donasi');
    selectedImagePath(''); // Clean gambar lama
  }

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    priceController.dispose();
    wishlistController.dispose();
    super.onClose();
  }
}
