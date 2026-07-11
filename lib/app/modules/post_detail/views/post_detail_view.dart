import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/post_detail_controller.dart';
import '../../profile/controllers/profile_post_controller.dart';

class PostDetailView extends StatelessWidget {
  const PostDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostDetailController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Postingan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
        actions: [
          Obx(() {
            if (controller.post.value == null) return const SizedBox.shrink();
            final post = controller.post.value!;

            // 🔒 PROTEKSI AKSES: Hanya muncul jika postingan milik user itu sendiri
            if (post['user_id'] == controller.currentUserId) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) async {
                  if (value == 'edit') {
                    Get.toNamed('/edit-post', arguments: {'post': post});
                  } else // 🔍 Cari bagian ini di dalam AppBar actions -> PopupMenuButton -> 'delete'
                  if (value == 'delete') {
                    Get.defaultDialog(
                      title: "Hapus Postingan",
                      middleText:
                          "Yakin mau menghapus '${post['title']}' dari RuangSisa, Beh?",
                      textConfirm: "Ya, Hapus",
                      textCancel: "Batal",
                      confirmTextColor: Colors.white,
                      buttonColor: Colors.redAccent,
                      onConfirm: () async {
                        Get.back(); // 1. Tutup dialog konfirmasinya dulu

                        try {
                          // 2. Cari controller yang sudah aktif
                          final profilePostCtrl =
                              Get.find<ProfilePostController>();
                          // 3. Langsung eksekusi hapus (Navigasi mundur diurus internal oleh controller)
                          await profilePostCtrl.deletePost(post['id']);
                        } catch (e) {
                          // Jalur penyelamat jika controller belum terdaftar
                          final profilePostCtrl = Get.put(
                            ProfilePostController(),
                          );
                          await profilePostCtrl.deletePost(post['id']);
                        }
                      },
                    );
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.amber,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Edit',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Hapus',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.post.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
          );
        }

        if (controller.post.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Postingan tidak ditemukan',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final post = controller.post.value!;
        final String type = post['post_type'] ?? 'Donasi';

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📸 Image Layout
                    if (post['images'] != null &&
                        post['images'].toString().isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          post['images'].toString(),
                          height: 260,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 260,
                              color: Colors.grey[100],
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                                size: 48,
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // 🏷️ Badge & Price Dinamis
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: type == 'Dijual'
                                ? const Color(0xFFFFF3CD)
                                : type == 'Barter'
                                ? const Color(0xFFCCE5FF)
                                : const Color(0xFFD4EDDA),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: type == 'Dijual'
                                  ? const Color(0xFF856404)
                                  : type == 'Barter'
                                  ? const Color(0xFF004085)
                                  : const Color(0xFF155724),
                            ),
                          ),
                        ),
                        if (type == 'Dijual') ...[
                          Text(
                            post['price'] != null
                                ? 'Rp ${post['price']}'
                                : 'Rp 0',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D6A4F),
                            ),
                          ),
                        ] else if (type == 'Barter') ...[
                          Expanded(
                            child: Text(
                              'Cari: ${post['barter_wishlist'] ?? "Bebas"}',
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Gratis / Donasi 🎁',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D6A4F),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Title & Description
                    Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post['description'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.grey[800],
                      ),
                    ),

                    const Divider(height: 40),

                    // Author Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: const Color(0xFFD4EDDA),
                            child: Text(
                              (post['author']?['name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF155724),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post['author']?['name'] ??
                                      'Kontributor RuangSisa',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Dibuat pada: ${post['created_at']?.substring(0, 10) ?? ''}',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 💬 1. BAGIAN TITEL KOMENTAR (DIKEMBALIKAN UTAL)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Komentar (${controller.comments.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF111827),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            size: 20,
                            color: Colors.grey,
                          ),
                          onPressed: controller.fetchComments,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // 💬 2. LIST BUILDER KOMENTAR (DIKEMBALIKAN UTAL)
                    if (controller.isLoadingComments.value)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF2D6A4F),
                          ),
                        ),
                      )
                    else if (controller.comments.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'Belum ada komentar. Yuk mulai diskusi!',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.comments.length,
                        itemBuilder: (context, index) {
                          final comment = controller.comments[index];
                          final bool isOwnComment =
                              comment['user_id'] == controller.currentUserId;

                          return Card(
                            elevation: 0,
                            color: Colors.grey[50],
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey[100]!),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFD4EDDA),
                                radius: 16,
                                child: Text(
                                  (comment['user']?['name'] ?? 'U')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF155724),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                comment['user']?['name'] ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  comment['content'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              trailing: isOwnComment
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.redAccent,
                                        size: 18,
                                      ),
                                      onPressed: () => _showDeleteConfirmation(
                                        context,
                                        comment['id'],
                                        controller,
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // 💬 3. PANEL BOTTOM BAR INPUT KOMENTAR (DIKEMBALIKAN UTAL)
            Container(
              padding: EdgeInsets.only(
                left: 12,
                right: 12,
                top: 10,
                bottom: MediaQuery.of(context).padding.bottom + 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.commentController,
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar diskusi...',
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => controller.sendComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    if (controller.isSendingComment.value) {
                      return const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(0xFF2D6A4F),
                          strokeWidth: 2,
                        ),
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF2D6A4F)),
                      onPressed: controller.sendComment,
                    );
                  }),
                ],
              ),
            ),
          ],
        );
      }),

      // 🟢 ACTION BUTTON CHAT PENJUAL (TETAP AMAN)
      bottomNavigationBar: Obx(() {
        if (controller.post.value == null) return const SizedBox.shrink();
        final post = controller.post.value!;

        if (post['user_id'] != controller.currentUserId) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: ElevatedButton.icon(
              onPressed: controller.goToChat,
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                post['type'] == 'Dijual'
                    ? 'Beli Material Sekarang'
                    : post['type'] == 'Barter'
                    ? 'Ajukan Penawaran Barter'
                    : 'Ambil Donasi Material',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D6A4F),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    int commentId,
    PostDetailController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Komentar'),
        content: const Text('Yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteComment(commentId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
