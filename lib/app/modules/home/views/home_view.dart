import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    // Alamat IP Backend laptop lu untuk jalur rendering gambar statis
    const String ipLaptop =
        "192.168.1.5"; // ◄ SESUAIKAN DENGAN IP LAPTOP LU, BEH!

    final List<Map<String, dynamic>> categories = [
      {'id': null, 'name': 'Semua', 'icon': Icons.grid_view},
      {'id': 1, 'name': 'Pakaian', 'icon': Icons.checkroom},
      {'id': 2, 'name': 'Elektronik', 'icon': Icons.devices_other},
      {'id': 3, 'name': 'Furnitur', 'icon': Icons.chair},
      {'id': 4, 'name': 'Buku & Hobi', 'icon': Icons.menu_book},
    ];

    return Scaffold(
      backgroundColor: const Color(
        0xFFF3F4F6,
      ), // Background abu-abu soft khas sosmed
      // --- TOP APP BAR ---
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
          IconButton(
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black,
              size: 26,
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // --- CATEGORY FILTERS ---
          Container(
            height: 60,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                bool isAll = index == 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(
                      categories[index]['icon'],
                      size: 16,
                      color: isAll ? Colors.white : const Color(0xFF404943),
                    ),
                    label: Text(categories[index]['name']),
                    backgroundColor: isAll
                        ? const Color(0xFF2D6A4F)
                        : const Color(0xFFC1ECD4).withOpacity(0.4),
                    labelStyle: TextStyle(
                      color: isAll ? Colors.white : const Color(0xFF404943),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                    onPressed: () {
                      controller.fetchTimelinePosts(
                        categoryId: categories[index]['id'],
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // --- TIMELINE FEED LIST (MODEL MEDIA SOSIAL MODERN) ---
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.postsList.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
                );
              }

              if (controller.postsList.isEmpty) {
                return const Center(
                  child: Text('Belum ada barang sisa yang diposting, Beh!'),
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

                    // 1. Ambil Nama User Dinamis dari Relasi Backend Lu, Beh!
                    String ownerName = "User RuangSisa";

                    // 📡 RADAR PELACAK: Cetak isi JSON postingan ke Debug Console VS Code lu
                    print("DEBUG JSON POSTINGAN KE-$index: ${post.toString()}");

                    if (post['user'] != null) {
                      if (post['user']['name'] != null) {
                        ownerName = post['user']['name'];
                      } else if (post['user']['username'] != null) {
                        ownerName =
                            post['user']['username']; // ◄ Cadangan 1: Kalau backend pake username
                      }
                    } else if (post['username'] != null) {
                      ownerName =
                          post['username']; // ◄ Cadangan 2: Kalau backend narik data langsung tanpa nested object
                    } else if (post['user_name'] != null) {
                      ownerName =
                          post['user_name']; // ◄ Cadangan 3: Kalau di JSON namanya user_name
                    }

                    // Setup Label Aksi Utama C2C
                    String labelTombol = 'Ambil';
                    if (post['post_type'] == 'Barter') labelTombol = 'Tawarkan';
                    if (post['post_type'] == 'Dijual') labelTombol = 'Beli';

                    String? formatPrice;
                    if (post['post_type'] == 'Dijual' &&
                        post['price'] != null) {
                      formatPrice = 'Rp ${post['price']}';
                    }

                    // 2. BANGUN URL GAMBAR DINAMIS DARI SERVER LAPTOP
                    String? finalImageUrl;
                    if (post['images'] != null &&
                        post['images'].isNotEmpty &&
                        post['images'] != 'foto_barang_default.png') {
                      // Mengarah ke folder static uploads FastAPI lu via Wi-Fi
                      finalImageUrl =
                          "http://$ipLaptop:8000/static/uploads/${post['images']}";
                    }

                    return FeedSosmedCard(
                      name: ownerName,
                      type: post['post_type'] ?? 'Donasi',
                      title: post['title'] ?? 'Tanpa Judul',
                      desc: post['description'] ?? '',
                      price: formatPrice,
                      btnLabel: labelTombol,
                      imageUrl: finalImageUrl,
                      onChatPressed: () {
                        // 3. TERUSKAN KE CHAT PEMILIK BARANG
                        print("Hubungi pemilik barang bernama: $ownerName");
                        // Nanti kalau modul message lu udah aktif tinggal lempar route:
                        // Get.toNamed('/message', arguments: {'user_id': post['user_id'], 'name': ownerName});
                      },
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

// --- 🛠️ UPGRADE TOTAL: KOMPONEN KARTU SOSIAL MEDIA PREMIUM ---
class FeedSosmedCard extends StatelessWidget {
  final String name;
  final String type;
  final String title;
  final String desc;
  final String btnLabel;
  final String? price;
  final String? imageUrl;
  final VoidCallback onChatPressed;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Styling Badge kontribusi biar eye-catching
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
          // 👤 Header User Sosmed
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

          // 📸 2. POSTINGAN FOTO DINAMIS DARI DATABASE BACKEND
          if (imageUrl != null)
            Image.network(
              imageUrl!,
              height: 260,
              width: double.infinity,
              fit: BoxFit.cover,
              // Loading Handle saat narik data gambar dari laptop
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
              // Error Handle kalau gambar gak ketemu di folder static laptop
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
                          'Gambar belum di-sync ke folder static laptop',
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              },
            )
          else
            // Placeholder minimalis jika user posting tanpa melampirkan foto
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

          // ✍️ Detail Konten (Judul, Harga, Deskripsi)
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
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, thickness: 0.5),
                const SizedBox(height: 4),

                // 📊 3. TOMBOL SOSMED INTERAKTIF (LIKE, KOMEN, CHAT INTERAKSI)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // A. Tombol Like Sosmed
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border_rounded,
                            color: Color(0xFF4B5563),
                            size: 24,
                          ),
                          onPressed: () {
                            Get.snackbar(
                              "Like",
                              "Postingan berhasil disukai, Beh!",
                            );
                          },
                        ),
                        // B. Tombol Komen Nego Terbuka
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: Color(0xFF4B5563),
                            size: 23,
                          ),
                          onPressed: () {
                            Get.snackbar(
                              "Komentar",
                              "Membuka lembar diskusi nego barang...",
                            );
                          },
                        ),
                      ],
                    ),

                    // C. Tombol Hubungi Pemilik (Diteruskan Langsung ke Chat)
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
                      onPressed:
                          onChatPressed, // ◄ Pemicu aksi kirim pesan privat
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
