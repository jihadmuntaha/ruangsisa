import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/post_provider.dart';

class AddPostController extends GetxController {
  final PostProvider _postProvider = Get.put(PostProvider());

  var isLoading = false.obs;

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priceController = TextEditingController();
  final wishlistController = TextEditingController();

  var selectedImagePath = ''.obs;
  var selectedImageFile = Rx<XFile?>(null);
  var selectedType = 'donation'.obs;
  final List<String> postTypes = ['donation', 'sale'];

  var selectedCategoryId = 0.obs;
  var categories = <Map<String, dynamic>>[].obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _postProvider.getCategories();

      if (response.statusCode == 200 && response.body != null) {
        List<dynamic> data = response.body;
        categories.value = data
            .map(
              (item) => {
                'id': item['id'],
                'name': item['category_name'],
                'icon': item['icon_name'],
              },
            )
            .toList();

        if (categories.isNotEmpty) {
          selectedCategoryId.value = categories[0]['id'];
        }
        print("✅ Loaded ${categories.length} categories");
      } else {
        _setFallbackCategories();
      }
    } catch (e) {
      print("❌ Fetch categories error: $e");
      _setFallbackCategories();
    }
  }

  void _setFallbackCategories() {
    categories.value = [
      {'id': 1, 'name': 'Fashion'},
      {'id': 2, 'name': 'Elektronik'},
      {'id': 3, 'name': 'Furnitur'},
      {'id': 4, 'name': 'Buku'},
      {'id': 5, 'name': 'Lainnya'},
    ];
    selectedCategoryId.value = 1;
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImagePath.value = image.path;
        selectedImageFile.value = image;
        Get.snackbar("Sukses", "Gambar berhasil diambil");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal mengambil gambar");
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        selectedImagePath.value = image.path;
        selectedImageFile.value = image;
        Get.snackbar("Sukses", "Gambar berhasil dipilih");
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal memilih gambar");
    }
  }

  void removeImage() {
    selectedImagePath.value = '';
    selectedImageFile.value = null;
  }

  Future<void> submitPost() async {
    // Validasi
    if (titleController.text.isEmpty) {
      Get.snackbar("Error", "Judul tidak boleh kosong");
      return;
    }
    if (descController.text.isEmpty) {
      Get.snackbar("Error", "Deskripsi tidak boleh kosong");
      return;
    }
    if (selectedImagePath.value.isEmpty) {
      Get.snackbar("Error", "Silakan pilih gambar");
      return;
    }
    if (selectedCategoryId.value == 0) {
      Get.snackbar("Error", "Silakan pilih kategori");
      return;
    }
    if (selectedType.value == 'sale' && priceController.text.isEmpty) {
      Get.snackbar("Error", "Harga tidak boleh kosong");
      return;
    }

    try {
      isLoading.value = true;

      final box = GetStorage();
      final userData = await box.read('user');
      final userId = userData?['id'] ?? userData?['user_id'];

      if (userId == null) {
        throw Exception("User tidak ditemukan");
      }

      // Konversi post_type
      String postTypeValue = selectedType.value == 'donation'
          ? 'Donasi'
          : 'Dijual';

      // ✅ Buat Map untuk fields
      Map<String, String> fields = {
        'title': titleController.text,
        'description': descController.text,
        'user_id': userId.toString(),
        'post_type': postTypeValue,
        'category_id': selectedCategoryId.value.toString(),
      };

      if (selectedType.value == 'sale' && priceController.text.isNotEmpty) {
        fields['price'] = priceController.text;
      }
      if (selectedType.value == 'donation' &&
          wishlistController.text.isNotEmpty) {
        fields['barter_wishlist'] = wishlistController.text;
      }

      print("📝 Fields: $fields");
      print("📸 Image path: ${selectedImagePath.value}");

      // ✅ Panggil API dengan fields dan image path
      final response = await _postProvider.createPost(
        fields,
        selectedImagePath.value,
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        _clearForm();
        Get.back(result: true);
        Get.snackbar("Sukses", "Postingan berhasil ditambahkan!");
      } else {
        String errorMsg =
            response.body?['detail'] ?? "Gagal menambahkan postingan";
        Get.snackbar("Gagal", errorMsg);
      }
    } catch (e) {
      isLoading.value = false;
      print("❌ Submit error: $e");
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
  }

  void _clearForm() {
    titleController.clear();
    descController.clear();
    priceController.clear();
    wishlistController.clear();
    selectedImagePath.value = '';
    selectedImageFile.value = null;
    selectedType.value = 'donation';
    if (categories.isNotEmpty) {
      selectedCategoryId.value = categories[0]['id'];
    }
  }

  void changePostType(String type) {
    selectedType.value = type;
    if (type == 'donation') {
      priceController.clear();
    }
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
