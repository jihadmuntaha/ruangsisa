import 'package:flutter/material.dart';

class MessageView extends StatelessWidget {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.eco, color: Color(0xFF2D6A4F)),
            SizedBox(width: 8),
            Text(
              'Pesan',
              style: TextStyle(
                color: Color(0xFF2D6A4F),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: Color(0xFF2D6A4F)),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          // Filter Pesan Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterChip('Semua', isActive: true),
                const SizedBox(width: 8),
                _buildFilterChip('Belum Dibaca'),
                const SizedBox(width: 8),
                _buildFilterChip('Arsip'),
              ],
            ),
          ),
          // Chat List
          Expanded(
            child: ListView(
              children: const [
                ChatTile(
                  name: 'Andi Pratama',
                  msg: 'Halo, apakah barang ini masih tersedia?',
                  time: '14:20',
                  unread: 2,
                ),
                ChatTile(
                  name: 'Siti Aminah',
                  msg: 'Terima kasih banyak ya! Sudah saya terima.',
                  time: '10:45',
                  unread: 0,
                ),
                ChatTile(
                  name: 'Budi Santoso',
                  msg: 'Mengirim foto produk',
                  time: 'Kemarin',
                  unread: 0,
                  isPhoto: true,
                ),
                ChatTile(
                  name: 'RuangSisa Eco-Team',
                  msg: 'Selamat! Kamu baru saja menyelamatkan 5kg sampah...',
                  time: 'Senin',
                  unread: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF2D6A4F).withOpacity(0.1)
            : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF2D6A4F) : Colors.transparent,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? const Color(0xFF2D6A4F) : Colors.grey[700],
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name, msg, time;
  final int unread;
  final bool isPhoto;

  const ChatTile({
    super.key,
    required this.name,
    required this.msg,
    required this.time,
    required this.unread,
    this.isPhoto = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        backgroundColor: Color(0xFF2D6A4F),
        radius: 24,
        child: Icon(Icons.person, color: Colors.white),
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Row(
        children: [
          if (isPhoto) ...[
            const Icon(Icons.photo_outlined, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              msg,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal,
                color: unread > 0 ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          if (unread > 0) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF2D6A4F),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      onTap: () {},
    );
  }
}
