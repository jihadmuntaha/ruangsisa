import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailView extends StatelessWidget {
  const PostDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PostDetailController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Postingan'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.post.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.post.value == null) {
          return const Center(child: Text('Postingan tidak ditemukan'));
        }

        final post = controller.post.value!;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 📸 Image
                    if (post['images'] != null && post['images'].isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          post['images'].startsWith('http')
                              ? post['images']
                              : 'http://172.24.243.45:8000${post['images']}',
                          height: 300,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 300,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.image_not_supported,
                                size: 50,
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // 🏷️ Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: post['post_type'] == 'Dijual'
                            ? Colors.orange[100]
                            : post['post_type'] == 'Barter'
                            ? Colors.blue[100]
                            : Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        post['post_type'] ?? 'Donasi',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: post['post_type'] == 'Dijual'
                              ? Colors.orange[800]
                              : post['post_type'] == 'Barter'
                              ? Colors.blue[800]
                              : Colors.green[800],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 👤 Author
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Text(
                            (post['author']?['name'] ?? 'U')[0],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['author']?['name'] ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${post['created_at']?.substring(0, 10) ?? ''}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: controller.goToChat,
                          icon: const Icon(Icons.chat, size: 16),
                          label: const Text('Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D6A4F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 💰 Price
                    if (post['price'] != null)
                      Text(
                        'Rp ${post['price']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D6A4F),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // 📝 Title
                    Text(
                      post['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 📄 Description
                    Text(
                      post['description'] ?? '',
                      style: const TextStyle(fontSize: 16, height: 1.6),
                    ),
                    // Di bagian bawah description
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(
                          '/chat',
                          arguments: {
                            'user_id': post['user_id'],
                            'name': post['author']?['name'] ?? 'User',
                          },
                        );
                      },
                      icon: const Icon(Icons.chat, color: Colors.white),
                      label: const Text('Chat Penjual'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 💬 Comments Section
                    const Divider(),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Komentar (${controller.comments.length})',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: controller.fetchComments,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Comments List
                    if (controller.isLoadingComments.value)
                      const Center(child: CircularProgressIndicator())
                    else if (controller.comments.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Belum ada komentar. Yuk mulai diskusi!'),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.comments.length,
                        itemBuilder: (context, index) {
                          final comment = controller.comments[index];
                          final isOwnComment =
                              comment['user_id'] == controller.currentUserId;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green[100],
                                radius: 18,
                                child: Text(
                                  (comment['user']?['name'] ?? 'U')[0],
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              title: Text(
                                comment['user']?['name'] ?? 'User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(comment['content'] ?? ''),
                              trailing: isOwnComment
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _showDeleteConfirmation(
                                          context,
                                          comment['id'],
                                          controller,
                                        );
                                      },
                                    )
                                  : null,
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),

            // 📝 Comment Input
            // Comment Input - pastikan pakai Form
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.commentController,
                      decoration: InputDecoration(
                        hintText: 'Tulis komentar...',
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
                      return const CircularProgressIndicator(
                        color: Color(0xFF2D6A4F),
                        strokeWidth: 2,
                      );
                    }
                    return IconButton(
                      icon: const Icon(Icons.send, color: Color(0xFF2D6A4F)),
                      onPressed: controller.sendComment,
                      splashRadius: 20,
                    );
                  }),
                ],
              ),
            ),
          ],
        );
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
