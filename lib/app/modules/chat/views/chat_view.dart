import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  // 🟢 PENARIK DATA ROOM CHAT
  Future<List<dynamic>> _fetchMyActiveRooms(ChatController controller) async {
    try {
      final String? token = controller.getToken();

      final response = await http.get(
        Uri.parse("${controller.baseUrl}/api/chats/rooms"),
        headers: {
          "Authorization": "Bearer ${token ?? ''}",
          "Content-Type": "application/json",
        },
      );

      print("📡 [DEBUG VIEW] Ambil daftar room status: ${response.statusCode}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("[-] Gagal load active rooms di View: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final ChatController controller = Get.put(ChatController());

    return Obx(() {
      // =======================================================================
      // 🟢 KONDISI A: TAMPILAN DAFTAR CHAT LIST (Kotak Masuk Utama)
      // =======================================================================
      if (controller.partnerId.value == 0) {
        return Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            title: const Text(
              'Kotak Masuk',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0.5,
          ),
          // 🔄 RefreshIndicator tetep dipertahankan buat opsional manual user
          body: RefreshIndicator(
            color: const Color(0xFF2D6A4F),
            backgroundColor: Colors.white,
            onRefresh: () async {
              await controller.refreshActiveRooms();
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: FutureBuilder<List<dynamic>>(
              // 🔥 TRIK SAKTI 1: Ikat langsung ke refreshTrigger.value & controller.messages.length
              // Biar setiap ada pesan masuk/keluar di background, Kotak Masuk OTOMATIS meletup ke-refresh sendiri!
              future:
                  (controller.refreshTrigger.value >= 0 ||
                      controller.messages.length >= 0)
                  ? _fetchMyActiveRooms(controller)
                  : _fetchMyActiveRooms(controller),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !controller.isSending.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
                  );
                }
                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(height: Get.height * 0.25),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.forum_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum Ada Chat Hack Aktif',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Yuk, hubungi kontributor lewat menu\n"Ambil" atau "Barter" di Beranda, Beh!',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                final rooms = snapshot.data!;
                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    final receiver = room['receiver'] ?? {};
                    final String partnerName =
                        receiver['name'] ?? 'Kontributor RuangSisa';
                    final String partnerImage = receiver['avatar'] ?? '';
                    final int partnerId = receiver['id'] ?? 0;
                    final int roomId = room['id'] ?? 0;
                    final String lastMsg =
                        room['last_message'] ?? 'Memulai obrolan...';

                    final int unreadCount = room['unread_count'] ?? 0;
                    final bool hasUnread = unreadCount > 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      elevation: hasUnread ? 0.8 : 0,
                      color: hasUnread ? const Color(0xFFE8F5E9) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: hasUnread
                            ? const BorderSide(
                                color: Color(0xFF2D6A4F),
                                width: 1.2,
                              )
                            : BorderSide.none,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: hasUnread
                              ? const Color(0xFF1B4332)
                              : const Color(0xFF2D6A4F),
                          // 🟢 TINGGAL PANGGIL VARIABELNYA DI SINI, JIHAD!
                          // Cek apakah ada link gambar/avatar dari backend
                          backgroundImage: partnerImage.isNotEmpty
                              ? NetworkImage(
                                  partnerImage.startsWith('http')
                                      ? partnerImage
                                      : 'http://10.20.166.45:8000$partnerImage', // Auto-suntik IP lokal laptop
                                )
                              : null,
                          // Kalau string gambarnya kosong, baru tampilin Icon default orang (Icons.person)
                          child: partnerImage.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        title: Text(
                          partnerName,
                          style: TextStyle(
                            fontWeight: hasUnread
                                ? FontWeight.bold
                                : FontWeight.w600,
                            fontSize: 15,
                            color: hasUnread
                                ? const Color(0xFF1B4332)
                                : Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          lastMsg,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.normal,
                            color: hasUnread
                                ? Colors.black87
                                : Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        trailing: SizedBox(
                          width: 60,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                room['updated_at'] != null
                                    ? room['updated_at'].toString().substring(
                                        11,
                                        16,
                                      )
                                    : "12:30",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: hasUnread
                                      ? const Color(0xFF2D6A4F)
                                      : Colors.grey,
                                  fontWeight: hasUnread
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 5),
                              if (hasUnread)
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF2D6A4F),
                                    shape: BoxShape.circle,
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 22,
                                    minHeight: 22,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "$unreadCount",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        onTap: () {
                          controller.chatRoomId.value = roomId;
                          controller.setChatPartner(partnerId, partnerName);
                          controller.fetchChatHistory();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF2D6A4F),
            child: const Icon(Icons.chat_rounded, color: Colors.white),
            onPressed: () {
              controller.setChatPartner(2, 'Siti Taylor Tegal');
              controller.chatRoomId.value = 0;
              controller.initiateChatRoom();
            },
          ),
        );
      }

      // =======================================================================
      // ✉️ KONDISI B: DETAIL ISI CHAT PERORANGAN (BUBBLE CHAT)
      // =======================================================================
      return WillPopScope(
        // 🟢 CEGAH TOMBOL BACK FISIK HP KELUAR DARI APLIKASI
        onWillPop: () async {
          controller.partnerId.value = 0;
          controller.chatRoomId.value = 0;
          controller.refreshActiveRooms();
          return false; // Membatalkan aksi pop bawaan OS, dialihkan ke perubahan state internal
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF3F4F6),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                controller.partnerId.value = 0;
                controller.chatRoomId.value = 0;
                controller.refreshActiveRooms();
              },
            ),
            title: Obx(() {
              // 🟢 AMBIL DATA AVATAR SECARA REAKTIF DARI CONTROLLER
              final String partnerAvatar = controller.partnerAvatar.value;

              return Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFF2D6A4F),
                    radius: 18,
                    // 📸 JALUR STABIL: Deteksi link Google Auth atau File Lokal Backend
                    backgroundImage: partnerAvatar.isNotEmpty
                        ? NetworkImage(
                            partnerAvatar.startsWith('http')
                                ? partnerAvatar
                                : 'http://10.20.166.45:8000$partnerAvatar',
                          )
                        : null,
                    child: partnerAvatar.isEmpty
                        ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      controller.partnerName.value,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              );
            }),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(16),
                  reverse: true,
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    final bool isMe = msg['isMe'] ?? false;
                    return _buildChatBubble(
                      content: msg['content'] ?? '',
                      time: msg['time'] ?? '',
                      isMe: isMe,
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                color: Colors.white,
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.messageController,
                          maxLines: null,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => controller.sendMessage(),
                          decoration: InputDecoration(
                            hintText: "Ketik pesan nego material...",
                            hintStyle: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F6),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Obx(
                        () => CircleAvatar(
                          backgroundColor: const Color(0xFF2D6A4F),
                          radius: 22,
                          child: controller.isSending.value
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : IconButton(
                                  icon: const Icon(
                                    Icons.send_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  onPressed: () => controller.sendMessage(),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChatBubble({
    required String content,
    required String time,
    required bool isMe,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2D6A4F) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              content,
              style: TextStyle(
                color: isMe ? Colors.white : const Color(0xFF1F2937),
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
