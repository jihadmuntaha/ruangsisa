import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ruang_sisa/app_config.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    final String baseUrl = AppConfig.baseUrl;

    final List<Map<String, dynamic>> categories = [
      {'id': null, 'name': 'Semua', 'icon': Icons.grid_view},
      {'id': 1, 'name': 'Fashion', 'icon': Icons.checkroom},
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
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_active_outlined,
                    color: Color(0xFF2D6A4F),
                  ),
                  onPressed: () {
                    print("🔔 [NAVIGASI] Tombol lonceng diklik!");
                    Get.toNamed('/notification');
                  },
                ),
                if (controller.unreadCount.value > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
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
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filters
          // 🟢 Pindahkan Obx dari luar ListView ke dalam itemBuilder
          Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                // 🟢 BUNGKUS OBX HANYA PADA WIDGET YANG NILAINYA BERUBAH SECARA REAKTIF
                return Obx(() {
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
                          ? const Color(0xFF2D6A4F) // Ijo tua pas aktif
                          : const Color(
                              0xFFC1ECD4,
                            ).withOpacity(0.4), // Ijo muda transparan
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
                });
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

                    // 1. Tentukan nama pemilik postingan
                    String ownerName = "User RuangSisa";
                    if (post['author'] != null) {
                      if (post['author']['name'] != null) {
                        ownerName = post['author']['name'];
                      }
                    } else if (post['user'] != null &&
                        post['user']['name'] != null) {
                      ownerName = post['user']['name'];
                    }

                    // 🟢 2. DETEKSI AMAN 3 STATUS (Gak bakal disatukan atau tertukar lagi!)
                    final String rawPrice = (post['price'] ?? '').toString();
                    final bool isBarterByWishlist =
                        post['barter_wishlist'] != null &&
                        post['barter_wishlist'].toString().trim().isNotEmpty;
                    final bool isBarterByPrice =
                        post['post_type'] == 'Dijual' &&
                        (rawPrice == '0' || rawPrice == 'Rp 0');

                    String tipeMurni = 'Donasi';
                    String labelTombol = 'Ambil';
                    String infoKontribusi = 'Gratis / Donasi';

                    // 🔵 SEKAT MUTLAK A: JALUR BARTER
                    if (isBarterByWishlist || isBarterByPrice) {
                      tipeMurni = 'Barter';
                      labelTombol =
                          'Tawarkan'; // Tombol disesuaikan murni ke Barter

                      String wishText =
                          (post['barter_wishlist'] != null &&
                              post['barter_wishlist'].toString().isNotEmpty)
                          ? post['barter_wishlist'].toString()
                          : 'Hubungi Pemilik';
                      infoKontribusi = 'Tukar: $wishText';
                    }
                    // 🟠 SEKAT MUTLAK B: JALUR DIJUAL MURNI
                    else if (post['post_type'] == 'Dijual') {
                      tipeMurni = 'Dijual';
                      labelTombol = 'Beli';
                      infoKontribusi = post['price'] != null
                          ? 'Rp ${post['price']}'
                          : 'Rp 0';
                    }
                    // 🟢 SEKAT MUTLAK C: JALUR DONASI MURNI
                    else {
                      tipeMurni = 'Donasi';
                      labelTombol = 'Ambil';
                      infoKontribusi = 'Gratis / Donasi';
                    }

                    // 🛠️ RAKIT URL GAMBAR POSTINGAN
                    String? finalImageUrl;
                    if (post['images'] != null &&
                        post['images'].toString().isNotEmpty) {
                      String imagePath = post['images'].toString();
                      if (imagePath.startsWith('http')) {
                        finalImageUrl = imagePath;
                      } else {
                        String cleanFileName = imagePath.split('/').last;
                        finalImageUrl =
                            "$baseUrl/static/uploads/$cleanFileName";
                      }
                    }

                    // 🛠️ RAKIT URL AVATAR PROFIL
                    String? finalAvatarUrl;
                    String? rawAvatar =
                        post['author']?['avatar'] ?? post['user']?['avatar'];
                    if (rawAvatar != null && rawAvatar.toString().isNotEmpty) {
                      if (rawAvatar.startsWith('http')) {
                        finalAvatarUrl = rawAvatar;
                      } else {
                        String cleanAvatarName = rawAvatar.split('/').last;
                        finalAvatarUrl =
                            "$baseUrl/static/uploads/$cleanAvatarName";
                      }
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
                        avatarUrl: finalAvatarUrl,
                        type: tipeMurni,
                        title: post['title'] ?? 'Tanpa Judul',
                        desc: post['description'] ?? '',
                        price: infoKontribusi,

                        // 🟢 1. FIX WARNING: Gunakan kembali variabel labelTombol bawaan lu biar ga mubazir
                        btnLabel: post['post_type'] == 'Dijual'
                            ? 'Beli Material Sekarang'
                            : post['post_type'] == 'Barter'
                            ? 'Ajukan Penawaran Barter'
                            : post['post_type'] == 'Donasi'
                            ? 'Ambil Donasi Material'
                            : labelTombol, // Menggunakan fallback ke labelTombol bawaan lu

                        imageUrl: finalImageUrl,
                        createdAt: post['created_at'] ?? '',

                        // 🟢 2. FIX EROR TYPE NULL: Jangan dioper 'null' mentah-mentah kalau parameternya mewajibkan VoidCallback.
                        // Kita ganti pakai fungsi kosong '() {}' jika itu postingan milik sendiri.
                        onChatPressed:
                            post['user_id'].toString() ==
                                controller.currentUserId.toString()
                            ? () {} // Fungsi kosong agar tombol tidak crash tapi fungsi chat mati
                            : () => controller.goToChatFromHome(post),
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
  final String? avatarUrl;
  final String? createdAt;
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
    this.avatarUrl,
    this.createdAt,
    required this.postId,
  }) : super(key: key);

  String formatTimeAgo(String? createdAtStr) {
    if (createdAtStr == null || createdAtStr.isEmpty) return 'Baru saja';
    try {
      DateTime postTime = DateTime.parse(createdAtStr).toLocal();
      DateTime now = DateTime.now();
      Duration difference = now.difference(postTime);

      if (difference.inSeconds < 60) {
        return 'Baru saja';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} menit yang lalu';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} jam yang lalu';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} hari yang lalu';
      } else {
        return '${postTime.day}/${postTime.month}/${postTime.year}';
      }
    } catch (e) {
      return 'Baru saja';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 PEMISAHAN WARNA BADGE KATEGORI SECARA TEGAS INDEPENDEN
    Color badgeColor = const Color(0xFFE8FFF0);
    Color textColor = const Color(0xFF0F5238);

    if (type == 'Barter') {
      badgeColor = const Color(0xFFE0F2FE); // Biru muda kalem mumpuni
      textColor = const Color(0xFF0369A1); // Biru pekat
    } else if (type == 'Dijual') {
      badgeColor = const Color(0xFFFEF3C7); // Kuning emas bawaan lu
      textColor = const Color(0xFFB45309); // Coklat jingga
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF2D6A4F),
              backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null || avatarUrl!.isEmpty
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              formatTimeAgo(createdAt),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                type, // 🟢 MENYESUAIKAN TYPE POST: Donasi / Dijual / Barter
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
                    price!, // 🟢 MENYESUAIKAN DATA BAWAHAN: nominal harga / wishlist / gratis
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: type == 'Barter'
                          ? const Color(0xFF0369A1)
                          : const Color(0xFF2D6A4F),
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
                        btnLabel, // 🟢 MENYESUAIKAN AKSI: Ambil / Beli / Tawarkan
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
