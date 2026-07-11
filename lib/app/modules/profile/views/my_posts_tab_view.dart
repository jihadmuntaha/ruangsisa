import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_post_controller.dart';

class MyPostsTabView extends StatelessWidget {
  const MyPostsTabView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller GetX
    final ProfilePostController controller = Get.put(ProfilePostController());

    return Scaffold(
      backgroundColor: const Color(0xFF002114), // Tema Gelap RuangSisa
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
          );
        }

        if (controller.myPosts.isEmpty) {
          return const Center(
            child: Text(
              "Lu belum pernah buat postingan!",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.myPosts.length,
          itemBuilder: (context, index) {
            final post = controller.myPosts[index];

            return Card(
              color: const Color(0xFF0B2F20),
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF1E4632), width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.images,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.white38,
                    ),
                  ),
                ),
                title: Text(
                  post.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  post.postType == "Dijual"
                      ? "Rp ${post.price}"
                      : "Barter: ${post.barterWishlist}",
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🟡 TOMBOL EDIT (UPDATE)
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amber),
                      onPressed: () {
                        // TODO: Arahkan ke halaman Form Edit dengan membawa data 'post'
                        Get.snackbar(
                          "Info",
                          "Fitur form edit dipanggil di sini",
                        );
                      },
                    ),
                    // 🔴 TOMBOL HAPUS (DELETE)
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        Get.defaultDialog(
                          title: "Hapus Postingan",
                          middleText: "Yakin mau hapus '${post.title}'?",
                          textConfirm: "Ya, Hapus",
                          textCancel: "Batal",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.redAccent,
                          onConfirm: () {
                            controller.deletePost(post.id);
                            Get.back(); // Tutup dialog
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
