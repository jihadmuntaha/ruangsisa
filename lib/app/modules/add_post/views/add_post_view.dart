import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart'; // ◄ Import source kamera/galeri
import '../controllers/add_post_controller.dart';

class AddPostView extends StatelessWidget {
  const AddPostView({Key? key}) : super(key: key);

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
            // 📸 🟢 BARU: COMPONENT BOX PICKER FOTO BARANG (Paling Atas)
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
                // Muncukin pilihan ambil gambar dari bawah layar HP
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
                            controller.pickImage(ImageSource.camera);
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
                            controller.pickImage(ImageSource.gallery);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Obx(() {
                // Jika belum pilih foto, tampilkan placeholder abu-abu minimalis
                if (controller.selectedImagePath.value.isEmpty) {
                  return Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.5),
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
                  // Jika foto sudah dipilih, render preview foto aslinya di kotak form!
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

            // 🏷️ 1. PILIH JENIS KONTRIBUSI (Donasi / Barter / Dijual)
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
                  items: controller.postTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) => controller.selectedType(value),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✍️ 2. INPUT JUDUL BARANG
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
                hintText: 'Misal: Sisa Kain Katun Rayon Premium',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✍️ 3. INPUT DESKRIPSI & KONDISI BARANG
            const Text(
              'Deskripsi & Minus Barang',
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
                hintText:
                    'Jelaskan volume sisa, kondisi fisik, atau pemakaian...',
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🌟 LOGIKA DINAMIS FIELD BERDASARKAN ATURAN BISNIS PLATFORM LU 🌟
            if (controller.selectedType.value == 'Dijual') ...[
              const Text(
                'Harga Nominal (Rp)',
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
                  hintText: 'Masukkan nominal, misal: 25000',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (controller.selectedType.value == 'Barter') ...[
              const Text(
                'Mau Barter Dengan Apa?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002114),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller.wishlistController,
                decoration: InputDecoration(
                  hintText: 'Misal: Tukar pakan kucing / tanaman hias',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // 📤 4. TOMBOL EKSEKUSI UTAMA
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () => controller.submitPost(),
              child: const Text(
                'Postkan ke RuangSisa',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
