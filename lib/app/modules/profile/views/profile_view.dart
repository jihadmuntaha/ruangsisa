import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart'; // Sesuaikan jalur import controller kalian

// 1. DIUBAH: Menggunakan StatelessWidget agar mandiri & anti-crash dari Bottom Nav
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // 🚨 MANANTRA PENYELAMAT: Memaksa GetX mendaftarkan ProfileController ke memori saat tab diklik
    final ProfileController controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () => Get.to(() => const SettingsView()),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu Identitas Akun
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF2D6A4F),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 12),

                // 🚨 Menggunakan Obx agar Nama User dinamis pasca-login
                Obx(
                  () => Text(
                    controller.name.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                // 🚨 Menggunakan Obx agar Bio User dinamis dari database
                Obx(
                  () => Text(
                    controller.bio.value,
                    style: const TextStyle(
                      color: Color(0xFF404943),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2D6A4F)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Get.to(() => const EditProfileView()),
                    child: const Text(
                      'Edit Profil',
                      style: TextStyle(
                        color: Color(0xFF2D6A4F),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const Divider(height: 32),

                // 🚨 Bagian Stat Counter dipantau Obx secara reaktif mengikuti jumlah upload
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Obx(
                      () => _StatItem(
                        num: '${controller.userContributions.length}',
                        label: 'Postingan',
                      ),
                    ),
                    const _StatItem(num: '0', label: 'Pengikut'),
                    const _StatItem(num: '0', label: 'Mengikuti'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Grid Konten Saya
          const Text(
            'Kontribusi Aktif',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 🚨 REACTIVE GRID: Kosong di awal, otomatis memuntahkan data saat terisi kelak
          Obx(() {
            if (controller.userContributions.isEmpty) {
              return Container(
                height: 150,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                      size: 36,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Belum ada kontribusi waste material.\nYuk mulai upload sisa tekstilmu!',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.userContributions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                final item = controller.userContributions[index];

                // Kirim data judul, tipe/status, dan nama file gambarnya, Beh!
                return _buildMiniGrid(
                  item['title'] ?? '',
                  item['post_type'] ?? 'Donasi',
                  item['images'], // ◄ AMBIL FIELD GAMBAR DARI DATABASE LU
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniGrid(String title, String status, String? imageName) {
    // Alamat IP Laptop lu buat jalur bypass gambar static FastAPI
    const String ipLaptop =
        "192.168.1.5"; // ◄ SAMAKAN DENGAN IP LAPTOP LU YANG AKTIF!

    // Bangun URL gambar penuh
    String? finalImageUrl;
    if (imageName != null &&
        imageName.isNotEmpty &&
        imageName != 'foto_barang_default.png') {
      finalImageUrl = "http://$ipLaptop:8000/static/uploads/$imageName";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 AREA FOTO POSTINGAN SAYA
            Expanded(
              child: finalImageUrl != null
                  ? Image.network(
                      finalImageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[100],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[100],
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
                    ),
            ),

            // 📝 KETERANGAN TEKS (JUDUL & BADGE STATUS)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: const TextStyle(
                      color: Color(0xFF2D6A4F),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String num, label;
  const _StatItem({required this.num, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          num,
          style: const TextStyle(
            color: Color(0xFF2D6A4F),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

// --- SUB-VIEW TAMBAHAN: EDIT PROFIL ---
class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF2D6A4F),
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          _buildField('Nama Lengkap', controller.name.value),
          _buildField('Bio', controller.bio.value),
          _buildField('Lokasi', controller.location.value),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6A4F),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Get.back(),
            child: const Text(
              'Simpan Perubahan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// --- SUB-VIEW TAMBAHAN: PENGATURAN ---
class SettingsView extends GetView<ProfileController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: Icon(Icons.lock_outline),
            title: Text('Privasi Akun'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifikasi'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Bantuan'),
            trailing: Icon(Icons.chevron_right),
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Keluar Akun',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () => controller.logoutAction(),
          ),
        ],
      ),
    );
  }
}
