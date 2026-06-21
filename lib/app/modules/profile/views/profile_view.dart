import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
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
            'Kontribusi Active',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

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
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final item = controller.userContributions[index];
                return _buildMiniGrid(
                  item['title'] ?? '',
                  item['post_type'] ?? 'Donasi',
                  item['images'],
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMiniGrid(String title, String status, String? imageName) {
    const String ipLaptop =
        "172.24.243.45"; // ◄ SINKRONKAN DENGAN IP LAPTOP LU SAAT INI
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
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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

// --- SUB-VIEW TAMBAHAN: PENGATURAN (SINKRONISASI LOG AKTIVITAS KAMDAT) ---
class SettingsView extends GetView<ProfileController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          _buildSectionTitle('Keamanan & Autentikasi'),

          ListTile(
            leading: const Icon(
              Icons.face_unlock_rounded,
              color: Color(0xFF2D6A4F),
            ),
            title: const Text(
              'Aktifkan Face ID Login',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Daftarkan wajah lu untuk login instan biometrik, Beh!',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Get.toNamed(
                '/face-scan',
                arguments: {'mode': 'register', 'email': ''},
              );
            },
          ),
          const Divider(height: 1),

          ListTile(
            leading: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.blueGrey,
            ),
            title: const Text('Privasi Akun'),
            subtitle: const Text(
              'Kelola visibilitas postingan tekstil & data pribadi',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),

          // 🛡️📝 MENU LOG AKTIVITAS (SUDAH DISINKRONKAN RUTENYA, BEH!)
          ListTile(
            leading: const Icon(
              Icons.history_toggle_off_rounded,
              color: Color(0xFF1B4332),
            ),
            title: const Text(
              'Log Aktivitas',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Audit trail: Riwayat login, perubahan data tekstil, & aksi lu, Beh!',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // 🟢 KUNCI SINKRON: Mengarah tepat ke rute page khusus yang kita bikin kemarin
              Get.toNamed('/activity-log');
            },
          ),

          const SizedBox(height: 16),
          _buildSectionTitle('Aplikasi & Notifikasi'),

          ListTile(
            leading: const Icon(
              Icons.notifications_outlined,
              color: Colors.orange,
            ),
            title: const Text('Notifikasi'),
            subtitle: const Text(
              'Atur pesan masuk, pengingat OTP, & info donasi',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline_rounded, color: Colors.blue),
            title: const Text('Bantuan & Hubungi Kami'),
            subtitle: const Text(
              'Pusat edukasi sirkular ekonomi & CS RuangSisa',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),

          const SizedBox(height: 32),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.red, width: 1),
              ),
              tileColor: Colors.red.withOpacity(0.05),
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Keluar Akun Kontributor',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () => controller.logoutAction(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2D6A4F),
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
