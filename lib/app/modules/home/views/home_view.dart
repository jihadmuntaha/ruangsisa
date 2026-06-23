import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    // 🟢 SINKRON: Base URL murni mengarah ke IP laptop aktif lu saat ini
    final String baseUrl = "http://172.24.243.45:8000";

    final List<Map<String, dynamic>> categories = [
      {'id': null, 'name': 'Semua', 'icon': Icons.grid_view},
      {'id': 1, 'name': 'Pakaian', 'icon': Icons.checkroom},
      {'id': 2, 'name': 'Elektronik', 'icon': Icons.devices_other},
      {'id': 3, 'name': 'Furnitur', 'icon': Icons.chair},
      {'id': 4, 'name': 'Buku & Hobi', 'icon': Icons.menu_book},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.eco, color: Color(0xFF2D6A4F), size: 28),
            SizedBox(width: 8),
            Text(
              'RuangSisa',
              style: TextStyle(
                color: Color(0xFF2D6A4F),
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Obx(
            () => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded, size: 26),
                  onPressed: () {},
                ),
                if (controller.unreadCount.value > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${controller.unreadCount.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category Filters
          Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final isSelected =
                    controller.selectedCategoryId.value ==
                    categories[index]['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(
                      categories[index]['icon'],
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF404943),
                    ),
                    label: Text(categories[index]['name']),
                    backgroundColor: isSelected
                        ? const Color(0xFF2D6A4F)
                        : const Color(0xFFC1ECD4).withOpacity(0.4),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF404943),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                    onPressed: () {
                      controller.selectedCategoryId.value =
                          categories[index]['id'];
                      controller.fetchTimelinePosts(
                        categoryId: categories[index]['id'],
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Timeline Feed
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.postsList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
                );
              }

              if (controller.postsList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada barang sisa yang diposting',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => Get.toNamed('/add-post'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D6A4F),
                        ),
                        child: const Text('Posting Sekarang'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: const Color(0xFF2D6A4F),
                onRefresh: () => controller.fetchTimelinePosts(),
                child: ListView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: controller.postsList.length,
                  itemBuilder: (context, index) {
                    final post = controller.postsList[index];

                    String ownerName = "User RuangSisa";
                    if (post['author'] != null) {
                      if (post['author']['name'] != null) {
                        ownerName = post['author']['name'];
                      }
                    } else if (post['user'] != null &&
                        post['user']['name'] != null) {
                      ownerName = post['user']['name'];
                    }

                    String labelTombol = 'Ambil';
                    if (post['post_type'] == 'Barter') labelTombol = 'Tawarkan';
                    if (post['post_type'] == 'Dijual') labelTombol = 'Beli';

                    String? formatPrice;
                    if (post['post_type'] == 'Dijual' &&
                        post['price'] != null) {
                      formatPrice = 'Rp ${post['price']}';
                    }

                    // 🟢 PERBAIKAN: Rakit URL Gambar secara presisi & anti-double-slash
                    String? finalImageUrl;
                    if (post['images'] != null &&
                        post['images'].toString().isNotEmpty) {
                      String imagePath = post['images'].toString();
                      // Ambil murni nama filenya saja, cegah penumpukan kata '/uploads/'
                      String cleanFileName = imagePath.split('/').last;
                      finalImageUrl = "$baseUrl/uploads/$cleanFileName";
                    }

                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(
                          '/post-detail',
                          arguments: {'post_id': post['id']},
                        );
                      },
                      child: FeedSosmedCard(
                        postId: post['id'],
                        name: ownerName,
                        type: post['post_type'] ?? 'Donasi',
                        title: post['title'] ?? 'Tanpa Judul',
                        desc: post['description'] ?? '',
                        price: formatPrice,
                        btnLabel: labelTombol,
                        imageUrl: finalImageUrl,
                        onChatPressed: () {
                          Get.toNamed(
                            '/chat',
                            arguments: {
                              'user_id': post['user_id'],
                              'name': ownerName,
                              'post_id': post['id'],
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class FeedSosmedCard extends StatelessWidget {
  final String name;
  final String type;
  final String title;
  final String desc;
  final String btnLabel;
  final String? price;
  final String? imageUrl;
  final VoidCallback onChatPressed;
  final int postId;

  const FeedSosmedCard({
    Key? key,
    required this.name,
    required this.type,
    required this.title,
    required this.desc,
    required this.btnLabel,
    required this.onChatPressed,
    this.price,
    this.imageUrl,
    required this.postId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color badgeColor = const Color(0xFFE8FFF0);
    Color textColor = const Color(0xFF0F5238);
    if (type == 'Barter') {
      badgeColor = const Color(0xFFE0F2FE);
      textColor = const Color(0xFF0369A1);
    } else if (type == 'Dijual') {
      badgeColor = const Color(0xFFFEF3C7);
      textColor = const Color(0xFFB45309);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF2D6A4F),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: const Text(
              'Baru saja',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                type,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          if (imageUrl != null)
            Image.network(
              imageUrl!,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 260,
                  color: Colors.grey[100],
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported_outlined,
                          size: 40,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Gambar tidak tersedia',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          else
            Container(
              height: 120,
              width: double.infinity,
              color: const Color(0xFFF9FAFB),
              child: const Center(
                child: Icon(
                  Icons.insert_photo_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (price != null) ...[
                  Text(
                    price!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D6A4F),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.4,
                    fontSize: 13,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border_rounded,
                            color: Color(0xFF4B5563),
                            size: 24,
                          ),
                          onPressed: () {
                            Get.snackbar("Like", "Postingan berhasil disukai!");
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Color(0xFF4B5563),
                            size: 23,
                          ),
                          onPressed: () {
                            Get.toNamed(
                              '/post-detail',
                              arguments: {'post_id': postId},
                            );
                          },
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onPressed: onChatPressed,
                      icon: const Icon(
                        Icons.send_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: Text(
                        btnLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
