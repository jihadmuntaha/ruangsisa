import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/add_post_controller.dart';

class AddPostView extends StatelessWidget {
  const AddPostView({super.key});

  @override
  Widget build(BuildContext context) {
    final AddPostController controller = Get.put(AddPostController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Post Barang Sisa',
          style: TextStyle(
            color: Color(0xFF2D6A4F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // 📸 BOX PICKER FOTO
            const Text(
              'Foto Kondisi Barang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF002114),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Get.bottomSheet(
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.camera_alt,
                            color: Color(0xFF2D6A4F),
                          ),
                          title: const Text('Jepret Kamera Langsung'),
                          onTap: () {
                            Get.back();
                            controller.pickImageFromCamera();
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.photo_library,
                            color: Color(0xFF2D6A4F),
                          ),
                          title: const Text('Ambil dari Galeri HP'),
                          onTap: () {
                            Get.back();
                            controller.pickImageFromGallery();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Obx(() {
                if (controller.selectedImagePath.value.isEmpty) {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withAlpha(128),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 40,
                          color: Color(0xFF2D6A4F),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tambahkan Foto Barang',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                } else {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(controller.selectedImagePath.value),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  );
                }
              }),
            ),
            const SizedBox(height: 20),

            // 🏷️ JENIS KONTRIBUSI (Donasi / Dijual)
            const Text(
              'Jenis Kontribusi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF002114),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedType.value,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'donation', child: Text('Donasi')),
                    DropdownMenuItem(value: 'sale', child: Text('Dijual')),
                    DropdownMenuItem(value: 'barter', child: Text('Barter')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.changePostType(value);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🆕 DROPDOWN KATEGORI (PILIHAN, BUKAN INPUT TEXT!)
            const Text(
              'Kategori Barang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF002114),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: Obx(() {
                  // Tampilkan loading kalau kategori belum ke-load
                  if (controller.categories.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }

                  return DropdownButton<int>(
                    value: controller.selectedCategoryId.value,
                    isExpanded: true,
                    hint: const Text('Pilih Kategori'),
                    items: controller.categories.map((category) {
                      return DropdownMenuItem<int>(
                        value: category['id'],
                        child: Row(
                          children: [
                            Icon(
                              _getIconForCategory(category['name']),
                              size: 20,
                              color: Color(0xFF2D6A4F),
                            ),
                            const SizedBox(width: 10),
                            Text(category['name']),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        controller.selectedCategoryId.value = value;
                      }
                    },
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // ✍️ JUDUL BARANG
            const Text(
              'Nama / Judul Barang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF002114),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.titleController,
              decoration: InputDecoration(
                hintText: 'Misal: Sisa Kain Katun Premium',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 📝 DESKRIPSI
            const Text(
              'Deskripsi & Kondisi Barang',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF002114),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.descController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Jelaskan kondisi, volume sisa, atau pemakaian...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // FIELD DINAMIS (HARGA untuk SALE)
            if (controller.selectedType.value == 'sale') ...[
              const Text(
                'Harga (Rp)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002114),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Masukkan harga, misal: 50000',
                  fillColor: Colors.white,
                  filled: true,
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // TOMBOL POST
            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D6A4F),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.submitPost(),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Post Material Sisa',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // Helper function untuk icon berdasarkan kategori
  IconData _getIconForCategory(String categoryName) {
    switch (categoryName) {
      case 'Fashion':
        return Icons.checkroom;
      case 'Elektronik':
        return Icons.phone_android;
      case 'Furnitur':
        return Icons.chair;
      case 'Buku':
        return Icons.menu_book;
      default:
        return Icons.category;
    }
  }
}
