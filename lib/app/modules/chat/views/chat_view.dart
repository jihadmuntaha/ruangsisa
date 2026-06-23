import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/chat_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  // 🟢 SINKRON & BERSIH: Menarik daftar kamar chat aktif langsung menggunakan token publik controller
  Future<List<dynamic>> _fetchMyActiveRooms(ChatController controller) async {
    try {
      // Memanggil fungsi getToken() publik dari ChatController yang baru diperbarui
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
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFF2D6A4F),
                ),
                onPressed: () {
                  // Trigger refresh daftar list chat secara paksa
                  controller.partnerId.refresh();
                },
              ),
            ],
          ),
          body: FutureBuilder<List<dynamic>>(
            // Menggunakan fungsi penarik data room yang sudah disinkronkan tokennya
            future: _fetchMyActiveRooms(controller),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2D6A4F)),
                );
              }
              if (snapshot.hasError ||
                  snapshot.data == null ||
                  snapshot.data!.isEmpty) {
                return Center(
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
                        'Belum Ada Chat Aktif',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yuk, hubungi kontributor lewat menu\n"Ambil" atau "Barter" di Beranda, Beh!',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final rooms = snapshot.data!;
              return ListView.builder(
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final receiver = room['receiver'] ?? {};
                  final String partnerName =
                      receiver['name'] ?? 'Kontributor RuangSisa';
                  final int partnerId = receiver['id'] ?? 0;
                  final int roomId = room['id'] ?? 0;
                  final String lastMsg =
                      room['last_message'] ?? 'Memulai obrolan...';

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF2D6A4F),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        partnerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        lastMsg,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        // 🟢 KLIK DAFTAR LIST LANGSUNG MASUK KE DETAIL CHAT NYATA
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
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF2D6A4F),
            child: const Icon(Icons.chat_rounded, color: Colors.white),
            onPressed: () {
              // Jalur pintas simulasi demo: Hubungi akun ID 2 (Siti Taylor)
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
      return Scaffold(
        backgroundColor: const Color(0xFFF3F4F6),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Reset partnerId agar kembali ke tampilan Kotak Masuk List utama
              controller.partnerId.value = 0;
              controller.chatRoomId.value = 0;
            },
          ),
          title: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFF2D6A4F),
                radius: 18,
                child: Icon(Icons.person, color: Colors.white, size: 20),
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
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                    CircleAvatar(
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
                  ],
                ),
              ),
            ),
          ],
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
