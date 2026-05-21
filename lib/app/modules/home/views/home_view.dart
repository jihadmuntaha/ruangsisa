import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // List kategori dummy sehari-hari sesuai desain Stitch
    final List<Map<String, dynamic>> categories = [
      {'name': 'Semua', 'icon': Icons.grid_view},
      {'name': 'Elektronik', 'icon': Icons.devices},
      {'name': 'Furnitur', 'icon': Icons.chair},
      {'name': 'Fashion', 'icon': Icons.checkroom},
      {'name': 'Buku & Hobi', 'icon': Icons.menu_book},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
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
            onPressed: () {
              // Aksi menuju halaman notifikasi global
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // --- CATEGORY FILTERS (Horizontal Scroll) ---
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
                    onPressed: () {},
                  ),
                );
              },
            ),
          ),

          // --- TIMELINE FEED LIST ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              children: const [
                FeedCard(
                  name: 'Aris Setiawan',
                  time: '2 jam yang lalu',
                  type: 'Donasi',
                  title: 'Set Piring Keramik Vintage',
                  desc:
                      'Masih sangat bagus, hanya ada sedikit goresan halus. Ingin memberikan kepada yang membutuhkan untuk mengurangi limbah rumah tangga.',
                  btnLabel: 'Ambil',
                ),
                FeedCard(
                  name: 'Lestari Putri',
                  time: '5 jam yang lalu',
                  type: 'Barter',
                  title: 'E-Reader Kindle 10th Gen',
                  desc:
                      'Ingin tukar dengan tanaman hias atau peralatan berkebun. Kondisi 90% mulus, baterai masih sangat awet.',
                  btnLabel: 'Tawarkan',
                ),
                FeedCard(
                  name: 'Budi Santoso',
                  time: '1 hari yang lalu',
                  type: 'Dijual',
                  title: 'Kursi Kantor Ergonomis',
                  desc:
                      'Baru dipakai 6 bulan, dijual karena mau pindah rumah. Masih sangat kokoh dan nyaman untuk kerja WFH.',
                  price: 'Rp 450.000',
                  btnLabel: 'Beli',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- KOMPONEN KARTU FEED (POST CARD) ---
class FeedCard extends StatelessWidget {
  final String name;
  final String time;
  final String type;
  final String title;
  final String desc;
  final String btnLabel;
  final String? price;

  const FeedCard({
    Key? key,
    required this.name,
    required this.time,
    required this.type,
    required this.title,
    required this.desc,
    required this.btnLabel,
    this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menyesuaikan warna badge label transaksi
    Color badgeColor = const Color(0xFFC1ECD4);
    if (type == 'Barter') badgeColor = const Color(0xFFA1F4C8);
    if (type == 'Donasi') badgeColor = const Color(0xFFE8FFF0);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info Header
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF2D6A4F),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            subtitle: Text(
              time,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type,
                style: const TextStyle(
                  color: Color(0xFF0F5238),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // Image Box Placeholder
          Container(
            height: 220,
            width: double.infinity,
            color: Colors.grey[100],
            child: const Center(
              child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
            ),
          ),

          // Content Detail
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Jika bertipe Dijual, tampilkan harga di atas judul
                if (price != null) ...[
                  Text(
                    price!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F5238),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF002114),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    color: Color(0xFF404943),
                    height: 1.4,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Divider(height: 28, thickness: 0.5),

                // Action Buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 22,
                        color: Color(0xFF404943),
                      ),
                      onPressed: () {},
                    ),
                    const Text(
                      '12',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.send_outlined,
                        size: 22,
                        color: Color(0xFF404943),
                      ),
                      onPressed: () {},
                    ),
                    const Spacer(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2D6A4F),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onPressed: () {
                        // Menghubungi pemilik barang (Direct Message)
                      },
                      child: Text(
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
