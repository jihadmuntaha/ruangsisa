import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/contributor_profile_controller.dart';

class ContributorProfileView extends GetView<ContributorProfileController> {
  const ContributorProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller biar aman
    final ContributorProfileController controller = Get.put(
      ContributorProfileController(),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profil Kontributor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xFF2D6A4F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CARD PROFIL ATAS
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // 🟢 FIX JALUR AVATAR KONTRIBUTOR: Biar gak salah belok ke folder barang!
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: const Color(0xFF2D6A4F),
                      backgroundImage: () {
                        String contAvatar = controller.contributorAvatar.value;
                        if (contAvatar.isEmpty) return null;

                        if (contAvatar.startsWith('http')) {
                          return NetworkImage(contAvatar);
                        } else if (contAvatar.startsWith('/static/')) {
                          // Jika dari backend sudah lengkap membawa /static/avatars/...
                          return NetworkImage(
                            '${controller.baseUrl}$contAvatar',
                          );
                        } else {
                          // Jaga-jaga jika di DB lu hanya tersimpan nama filenya doang
                          return NetworkImage(
                            '${controller.baseUrl}/static/avatars/$contAvatar',
                          );
                        }
                      }(),
                      child: controller.contributorAvatar.value.isEmpty
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.contributorName.value,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002114),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Kontributor Aktif Lingkungan 🌿",
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF2D6A4F),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // DAFTAR POSTINGAN MEREKA
              Text(
                'Material Milik ${controller.contributorName.value}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF002114),
                ),
              ),
              const SizedBox(height: 12),

              if (controller.contributorPosts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      "Kontributor ini belum memposting material!",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: controller.contributorPosts.length,
                  itemBuilder: (context, index) {
                    final post = controller.contributorPosts[index];
                    String title = post['title'] ?? 'Material';
                    String postType = post['post_type'] ?? 'Gratis';
                    String imageUrl = post['images'] ?? '';

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                              ),
                              child: imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        imageUrl.startsWith('http')
                                            ? imageUrl
                                            : '${controller.baseUrl}$imageUrl',
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  postType,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF2D6A4F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
