import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ruang_sisa/app_config.dart';

class ChatController extends GetxController {
  // 🟢 IP Backend disamakan dengan log terminal FastAPI asli
  final String baseUrl = AppConfig.baseUrl;

  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;

  var chatRoomId = 0.obs;
  var partnerId = 0.obs;
  var partnerName = ''.obs;
  var partnerImage = ''.obs;
  var partnerAvatar = ''.obs;

  // RxInt untuk mentrigger update UI secara reaktif di View saat pull-to-refresh
  var refreshTrigger = 0.obs;

  final messageController = TextEditingController();
  var currentUserId = 0;

  Timer? _pollingTimer;
  final scrollController = ScrollController();

  // 🟢 AMBIL TOKEN SECARA VALID & BERSIH
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

    // 🟢 SUNTIKAN PENGAMAN MUTLAK DAN KEBAL CRASH NULL OPERATOR
    if (Get.arguments != null && Get.arguments is Map) {
      print("📦 Arguments received: ${Get.arguments}");
      final Map<String, dynamic> args = Map<String, dynamic>.from(
        Get.arguments,
      );

      // 🎯 1. JALUR LIST CHAT UTAMA YANG MEMBAWA 'chat_id' ATAU 'chat_room_id'
      if (args.containsKey('chat_id') || args.containsKey('chat_room_id')) {
        final String rawChatId = (args['chat_id'] ?? args['chat_room_id'])
            .toString();
        chatRoomId.value = int.tryParse(rawChatId) ?? 0;

        print("🔔 [JALUR ROOM INDEKS] Masuk Room ID: ${chatRoomId.value}");

        // Ambil fallback data nama aman dari payload list chat jika ada
        final String notifPartnerName =
            args['name']?.toString() ?? "Kontributor RuangSisa";
        final int targetUserId =
            int.tryParse(args['user_id']?.toString() ?? "0") ?? 999;

        // Set state awal agar UI aman dari jebakan null check di View
        partnerId.value = targetUserId;
        partnerName.value = notifPartnerName;
        partnerAvatar.value = args['avatar']?.toString() ?? "";
        partnerImage.value = args['avatar']?.toString() ?? "";

        // Kosongkan pesan lama dulu biar layout gak kaget saat render awal
        messages.clear();

        if (chatRoomId.value > 0) {
          fetchChatHistory();
          // 🔥 PIL PILIHAN: Sinkronkan nama asli dari list room server
          _fetchAndSetPartnerProfileFromRoom();
        }
      }
      // 🎯 2. JALUR BARU PENGUNJUNG LAPAK ATAU JALUR NOTIFIKASI TERBARU (Membawa user_id / reference_id)
      else if (args.containsKey('user_id') ||
          args.containsKey('reference_id')) {
        // 🟢 FIX SAKTI: Ambil ID penjual secara aman dari 'user_id' atau 'reference_id' pembawa payload FCM
        final String rawUserId =
            (args['user_id'] ?? args['reference_id'] ?? "0").toString();
        final int targetUserId = int.tryParse(rawUserId) ?? 0;

        final String targetName =
            args['name']?.toString() ?? 'Kontributor RuangSisa';

        setChatPartner(targetUserId, targetName);
        partnerAvatar.value = args['avatar']?.toString() ?? "";
        partnerImage.value = args['avatar']?.toString() ?? "";
        messages.clear();

        // Cari atau buat room otomatis ke backend jika target ID-nya valid
        if (targetUserId > 0) {
          initiateChatRoom();
        }
      }
    } else {
      print("⚠️ Get.arguments murni null atau bukan berupa Map!");
    }

    // Polling aktif tiap 2 detik demi stabilitas sinkronisasi pesan
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (chatRoomId.value != 0 && !isLoading.value) {
        _silentFetchMessages();
      }
    });
  }

  void _loadCurrentUser() {
    final box = GetStorage();
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

  Future<void> refreshActiveRooms() async {
    refreshTrigger.value++;
    _loadCurrentUser();
  }

  Future<void> initiateChatRoom() async {
    try {
      isLoading.value = true;
      _loadCurrentUser();

      String? cleanToken = getToken();
      if (cleanToken == null) {
        Get.snackbar('Error', 'Silakan login terlebih dahulu');
        isLoading.value = false;
        return;
      }

      final response = await http.post(
        Uri.parse("$baseUrl/api/chats/room"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $cleanToken",
        },
        body: jsonEncode({"receiver_id": partnerId.value}),
      );

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
          'Perhatian!',
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

      // 🟢 KUNCI FIX: Memastikan alamat endpoint berbunyi /api/chats/rooms/...
      final String fullUrl =
          "$baseUrl/api/chats/rooms/${chatRoomId.value}/messages";
      print("📡 FE menembak history chat ke: $fullUrl");

      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {"Authorization": "Bearer $cleanToken"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawList = jsonDecode(response.body);
        _parseAndSetMessages(rawList);
        _scrollToBottom();
        refreshActiveRooms();
      } else {
        print(
          "⚠️ [GET CHAT] Server merespon status: ${response.statusCode} | Body: ${response.body}",
        );
      }
      isLoading.value = false;
    } catch (e) {
      print('❌ Error Fetch History: $e');
      isLoading.value = false;
    }
  }

  // 🟢 POLLING SILENT: Update list pesan tanpa memicu loading screen (SUDAH DI-REPAIR)
  Future<void> _silentFetchMessages() async {
    try {
      String? cleanToken = getToken();
      if (cleanToken == null) return;

      final String fullUrl =
          "$baseUrl/api/chats/rooms/${chatRoomId.value}/messages";

      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {"Authorization": "Bearer $cleanToken"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawList = jsonDecode(response.body);

        // Hanya update & scroll kalau jumlah pesan di DB terbukti berubah!
        if (rawList.length != messages.length) {
          _parseAndSetMessages(rawList);
          _scrollToBottom();
        }
      }
    } catch (e) {
      print('[-] Polling error: $e');
    }
  }

  // 🔥 FUNGSI AUTOMATION: Mengambil data nama & avatar partner asli dari daftar room backend jika masuk via notif
  Future<void> _fetchAndSetPartnerProfileFromRoom() async {
    try {
      String? cleanToken = getToken();
      if (cleanToken == null) return;

      final response = await http.get(
        Uri.parse("$baseUrl/api/chats/rooms"),
        headers: {"Authorization": "Bearer $cleanToken"},
      );

      if (response.statusCode == 200) {
        final List<dynamic> rooms = jsonDecode(response.body);

        // Cari room yang ID-nya cocok dengan chatRoomId kita sekarang
        final activeRoom = rooms.firstWhere(
          (r) => (r['id'] ?? 0) == chatRoomId.value,
          orElse: () => null,
        );

        if (activeRoom != null && activeRoom['receiver'] != null) {
          final receiver = activeRoom['receiver'];
          partnerId.value = receiver['id'] ?? partnerId.value;
          partnerName.value = receiver['name']?.toString() ?? partnerName.value;

          // 🟢 FIX MUTLAK: Antisipasi kalau backend mengirimkan key 'avatar' atau 'avatar_url'
          String rawAvatar =
              receiver['avatar']?.toString() ??
              receiver['avatar_url']?.toString() ??
              "";

          partnerAvatar.value = rawAvatar;
          partnerImage.value = rawAvatar;

          print(
            "🎯 [PROFILE SYNC SUCCESS] Avatar terupdate: ${partnerAvatar.value}",
          );
        }
      }
    } catch (e) {
      print("[-] Gagal auto-sync profil partner dari list room: $e");
    }
  }

  // 🟢 PENGONDISIAN DATA REAKTIF
  void _parseAndSetMessages(List<dynamic> rawList) {
    List<Map<String, dynamic>> parsed = rawList.map((msg) {
      bool isMe = msg['sender_id'] == currentUserId;
      String contentText = msg['message_text'] ?? '';

      // 🟢 PARSING TIMESTAMP ASLI DARI BACKEND
      DateTime parsedDate;
      if (msg['created_at'] != null) {
        try {
          parsedDate = DateTime.parse(msg['created_at'].toString()).toLocal();
        } catch (_) {
          parsedDate = DateTime.now();
        }
      } else {
        parsedDate = DateTime.now();
      }

      return {
        'id': msg['id'],
        'content': contentText,
        'isMe': isMe,
        'sender_id': msg['sender_id'],
        'time':
            '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}',
        'timestamp':
            parsedDate, // 🌟 Suntik objek DateTime murni buat filter hari di UI
        'is_read': msg['is_read'] ?? false,
      };
    }).toList();

    // Pastikan sinkron dengan properti reverse: true di ListView UI lu
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
        // 🔥 SOLUSI SAKTI: Beri jeda mikro 50ms agar keyboard OS selesai merender layout,
        // Baru setelah itu data inputan dipastikan terhapus bersih secara steril!
        Future.delayed(const Duration(milliseconds: 50), () {
          messageController.clear();
        });

        // Tetap jalankan penarikan history secara asinkron
        fetchChatHistory();
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    _pollingTimer?.cancel(); // Wajib dimatikan demi keawetan baterai HP
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
