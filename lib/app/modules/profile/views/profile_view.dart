import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
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
                // 📸 1. FOTO PROFIL INTERAKTIF (Bisa diklik buat ganti foto pake kamera Realme)
                GestureDetector(
                  onTap: () => _showAvatarPickerSheet(context, controller),
                  child: Stack(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF2D6A4F),
                          backgroundImage: controller.avatarUrl.value.isNotEmpty
                              ? NetworkImage(controller.avatarUrl.value)
                              : null,
                          child: controller.avatarUrl.value.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF52B788),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
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

  // 🟢 INTERAKTIF: Modal pilih sumber foto profil
  void _showAvatarPickerSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2D6A4F)),
              title: const Text('Ambil via Kamera HP Realme, Beh!'),
              onTap: () {
                Get.back();
                controller.pickAndUploadAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: Color(0xFF2D6A4F),
              ),
              title: const Text('Pilih dari Galeri Foto'),
              onTap: () {
                Get.back();
                controller.pickAndUploadAvatar(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🟢 FIX IP SAKRAL: Diselaraskan biar gambar postingan gak 404
  Widget _buildMiniGrid(String title, String status, String? imageName) {
    const String ipLaptop = "10.20.166.45";
    String? finalImageUrl;

    if (imageName != null &&
        imageName.isNotEmpty &&
        imageName != 'foto_barang_default.png') {
      String cleanFileName = imageName.split('/').last;
      finalImageUrl = "http://$ipLaptop:8000/uploads/$cleanFileName";
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

// --- SUB-VIEW TAMBAHAN: EDIT PROFIL (FIXED & FULLY INTERACTIVE) ---
class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller Text Lokal untuk menampung ketikan baru si user
    final nameCtrl = TextEditingController(text: controller.name.value);
    final bioCtrl = TextEditingController(text: controller.bio.value);
    final locationCtrl = TextEditingController(text: controller.location.value);

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
              child: Icon(
                Icons.mode_edit_outline_outlined,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildField('Nama Lengkap', nameCtrl),
          _buildField('Bio', bioCtrl),
          _buildField('Lokasi', locationCtrl),
          const SizedBox(height: 24),

          // Tombol eksekusi simpan ke FastAPI database laptop lu, Beh!
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D6A4F),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              Get.back(); // Kembali ke layar profil utama
              await controller.updateProfileData(
                nameCtrl.text,
                bioCtrl.text,
                locationCtrl.text,
              );
            },
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

  Widget _buildField(String label, TextEditingController txtController) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: txtController,
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
                arguments: {
                  'mode': 'register',
                  'email': controller.email.value,
                },
              );
            },
          ),
          const Divider(height: 1),

          // 🟢 INTERAKTIF: Ditautkan ke modal popup ubah password murni
          ListTile(
            leading: const Icon(
              Icons.lock_outline_rounded,
              color: Colors.blueGrey,
            ),
            title: const Text('Ubah Kata Sandi Akun'),
            subtitle: const Text(
              'Perbarui kredensial password login lokal berkala',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showChangePasswordPopUp(),
          ),
          const Divider(height: 1),

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

  // 🟢 INTERAKTIF: Dialog popup ganti password bawaan GetX
  void _showChangePasswordPopUp() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();

    Get.defaultDialog(
      title: "Ubah Kata Sandi",
      buttonColor: const Color(0xFF2D6A4F),
      confirmTextColor: Colors.white,
      textConfirm: "Update",
      textCancel: "Batal",
      cancelTextColor: Colors.grey,
      content: Column(
        children: [
          TextField(
            controller: oldPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Kata Sandi Lama"),
          ),
          TextField(
            controller: newPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Kata Sandi Baru"),
          ),
        ],
      ),
      onConfirm: () =>
          controller.changeAccountPassword(oldPassCtrl.text, newPassCtrl.text),
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
