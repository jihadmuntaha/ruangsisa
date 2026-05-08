import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RuangSisa', style: TextStyle(color: Color(0xFF2D6A4F), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildUserInfo(),
          const SizedBox(height: 24),
          _buildStatSection(),
          const SizedBox(height: 24),
          _buildMenuSection(),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        const CircleAvatar(
          radius: 48,
          backgroundImage: NetworkImage("https://placehold.co/96x96"),
        ),
        const SizedBox(height: 12),
        const Text('Jihad', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F5238))),
        const Text('+62 812-3456-7890', style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Barang Saya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _statCard("12", "Aktif", const Color(0xFF0F5238))),
            const SizedBox(width: 12),
            Expanded(child: _statCard("45", "Terjual", const Color(0xFF0F5238))),
            const SizedBox(width: 12),
            Expanded(child: _statCard("08", "Didonasikan", const Color(0xFF7D562D))),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: const [BoxShadow(color: Color(0x0C2D6A4F), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        children: [
          _menuTile(Icons.location_on_outlined, "Alamat Saya", () => Get.toNamed('/address')),
          _menuTile(Icons.settings_outlined, "Pengaturan Akun", () => Get.toNamed('/account-setting')),
          _menuTile(Icons.help_outline, "Tentang", () => Get.toNamed('/about')),
        ],
      ),
    );
  }

  Widget _menuTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2D6A4F)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: const Color(0x33FFDAD6), borderRadius: BorderRadius.circular(16)),
      child: TextButton(
        onPressed: () => Get.offAllNamed('/register'),
        child: const Text('Keluar Akun', style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.bold)),
      ),
    );
  }
}