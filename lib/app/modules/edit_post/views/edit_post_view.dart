import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/edit_post_controller.dart';

class EditPostView extends GetView<EditPostController> {
  const EditPostView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Edit Postingan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: controller.formKey,
          child: ListView(
            children: [
              Text(
                "Kategori: ${controller.postType}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF2D6A4F),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  labelText: 'Judul Postingan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Judul harus diisi' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: controller.descController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Deskripsi Material',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi isi dulu' : null,
              ),
              const SizedBox(height: 16),

              if (controller.postType == 'Dijual') ...[
                TextFormField(
                  controller: controller.priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Harga (Rp)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) => value!.isEmpty ? 'Harga berapa?' : null,
                ),
              ] else if (controller.postType == 'Barter') ...[
                TextFormField(
                  controller: controller.wishlistController,
                  decoration: InputDecoration(
                    labelText: 'Mau Barter Dengan Apa?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Isi target barternya!' : null,
                ),
              ],

              const SizedBox(height: 32),

              Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (controller.formKey.currentState!.validate()) {
                            bool success = await controller.updatePost();
                            if (success) {
                              Get.back(); // Pulang ke halaman sebelumnya
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D6A4F),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
