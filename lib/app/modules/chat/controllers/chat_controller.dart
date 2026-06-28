import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  final String baseUrl = "http://10.20.166.45:8000";

  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;

  var chatRoomId = 0.obs;
  var partnerId = 0.obs;
  var partnerName = ''.obs;

  final messageController = TextEditingController();
  var currentUserId = 0;

  Timer? _pollingTimer;
  final scrollController = ScrollController();

  // 🟢 AMBIL TOKEN SECARA VALIDE & BERSIH
  String? getToken() {
    final box = GetStorage();
    String? token = box.read('access_token') ?? box.read('token');

    if (token != null && token.isNotEmpty) {
      if (token.startsWith("Bearer ")) {
        token = token.replaceFirst("Bearer ", "");
      }
      return token;
    }
    print("❌ Token tidak ditemukan di GetStorage!");
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();

    print("📱 CHAT CONTROLLER INIT");
    print("Current User ID: $currentUserId");

    if (Get.arguments != null) {
      print("📦 Arguments received: ${Get.arguments}");

      final int targetUserId = Get.arguments['user_id'] ?? 0;
      final String targetName = Get.arguments['name'] ?? 'Kontributor';
      final int? existingRoomId = Get.arguments['chat_room_id'];

      setChatPartner(targetUserId, targetName);

      if (existingRoomId != null && existingRoomId > 0) {
        chatRoomId.value = existingRoomId;
        print("✅ Menggunakan Room ID lama: $existingRoomId");
        fetchChatHistory();
      }
    }

    // Polling background pencari pesan baru setiap 3 detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (chatRoomId.value != 0 && !isLoading.value) {
        _silentFetchMessages();
      }
    });
  }

  void _loadCurrentUser() {
    final box = GetStorage();
    // Tarik ulang setiap kali controller dimuat agar sinkron pas ganti akun
    var user = box.read('user') ?? box.read('user_data');

    if (user != null) {
      currentUserId = user['id'] ?? 0;
      print("👤 Akun Aktif Saat Ini ID: $currentUserId");
    } else {
      print("⚠️ Data user kosong di storage!");
    }
  }

  void setChatPartner(int userId, String name) {
    partnerId.value = userId;
    partnerName.value = name;
    print("🤝 Menyetel Target Chat: ID=$userId, Nama=$name");
  }

  Future<void> initiateChatRoom() async {
    try {
      isLoading.value = true;
      _loadCurrentUser(); // Paksa reload user ID biar gak pakai cache akun lama

      String? cleanToken = getToken();
      if (cleanToken == null) {
        Get.snackbar('Error', 'Silakan login terlebih dahulu');
        isLoading.value = false;
        return;
      }

      print(
        "📡 Menembak /room. Partner: ${partnerId.value}, Me: $currentUserId",
      );

      final response = await http.post(
        Uri.parse("$baseUrl/api/chats/room"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $cleanToken",
        },
        body: jsonEncode({"receiver_id": partnerId.value}),
      );

      print("📡 Status Buat Room: ${response.statusCode}");
      print("📄 Respon Buat Room: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        chatRoomId.value = data['id'] ?? 0;

        if (chatRoomId.value > 0) {
          await fetchChatHistory();
        }
      } else {
        final errorData = jsonDecode(response.body);
        String errorMsg = errorData['detail'] ?? 'Gagal membuka kamar chat';
        Get.snackbar(
          'Perhatian, Beh!',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      isLoading.value = false;
    } catch (e) {
      print('❌ Error Initiate Room: $e');
      isLoading.value = false;
    }
  }

  Future<void> fetchChatHistory() async {
    if (chatRoomId.value == 0) return;

    try {
      isLoading.value = true;
      String? cleanToken = getToken();
      if (cleanToken == null) return;

      print("📥 Mengambil riwayat pesan Room ID: ${chatRoomId.value}");

      final response = await http.get(
        Uri.parse("$baseUrl/api/chats/rooms/${chatRoomId.value}/messages"),
        headers: {"Authorization": "Bearer $cleanToken"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawList = jsonDecode(response.body);
        _parseAndSetMessages(rawList);
        _scrollToBottom();
      }
      isLoading.value = false;
    } catch (e) {
      print('❌ Error Fetch History: $e');
      isLoading.value = false;
    }
  }

  Future<void> _silentFetchMessages() async {
    try {
      String? cleanToken = getToken();
      if (cleanToken == null) return;

      final response = await http.get(
        Uri.parse("$baseUrl/api/chats/rooms/${chatRoomId.value}/messages"),
        headers: {"Authorization": "Bearer $cleanToken"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawList = jsonDecode(response.body);
        if (rawList.length != messages.length) {
          _parseAndSetMessages(rawList);
          _scrollToBottom();
        }
      }
    } catch (e) {
      print('[-] Polling error: $e');
    }
  }

  // 🟢 PEMBERSIHAN TOTAL: Bebas dari jeratan eror .min() jahanam
  void _parseAndSetMessages(List<dynamic> rawList) {
    List<Map<String, dynamic>> parsed = rawList.map((msg) {
      bool isMe = msg['sender_id'] == currentUserId;
      String contentText = msg['message_text'] ?? '';

      return {
        'id': msg['id'],
        'content': contentText,
        'isMe': isMe,
        'sender_id': msg['sender_id'],
        'time': _formatIsoTime(msg['created_at']),
      };
    }).toList();

    messages.assignAll(parsed.reversed.toList());
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    if (chatRoomId.value == 0) {
      await initiateChatRoom();
      if (chatRoomId.value == 0) return;
    }

    try {
      isSending.value = true;
      String? cleanToken = getToken();
      if (cleanToken == null) return;

      final response = await http.post(
        Uri.parse("$baseUrl/api/chats/messages"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $cleanToken",
        },
        body: jsonEncode({
          "chat_id": chatRoomId.value,
          "message_text": content,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        messageController.clear();
        await fetchChatHistory();
      }
      isSending.value = false;
    } catch (e) {
      print('❌ Error Send Message: $e');
      isSending.value = false;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatIsoTime(String? isoString) {
    if (isoString == null) return _getCurrentTime();
    try {
      DateTime dt = DateTime.parse(isoString).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return _getCurrentTime();
    }
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
