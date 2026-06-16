import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var isSending = false.obs;

  var partnerId = 0.obs;
  var partnerName = ''.obs;

  final messageController = TextEditingController();

  var currentUserId = 0;

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    _loadMessages();
  }

  void _loadCurrentUser() {
    final box = GetStorage();
    final user = box.read('user');
    if (user != null) {
      currentUserId = user['id'] ?? 0;
    }
  }

  void setChatPartner(int userId, String name) {
    partnerId.value = userId;
    partnerName.value = name;
  }

  Future<void> _loadMessages() async {
    try {
      isLoading.value = true;

      // TODO: Nanti panggil API
      // final response = await _chatProvider.getMessages(partnerId.value);

      // Data dummy untuk testing
      await Future.delayed(const Duration(milliseconds: 500));
      messages.assignAll([
        {
          'content': 'Halo, barang ini masih tersedia?',
          'isMe': false,
          'time': '10:30',
        },
        {'content': 'Ya masih tersedia. Minat?', 'isMe': true, 'time': '10:32'},
        {'content': 'Harganya bisa nego gak?', 'isMe': false, 'time': '10:35'},
      ]);

      isLoading.value = false;
    } catch (e) {
      print('❌ Error: $e');
      isLoading.value = false;
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty) return;

    try {
      isSending.value = true;

      // TODO: Nanti panggil API
      // final response = await _chatProvider.sendMessage({
      //   'receiver_id': partnerId.value,
      //   'content': content,
      // });

      // Simulasi kirim
      await Future.delayed(const Duration(milliseconds: 300));

      // Tambah pesan
      messages.insert(0, {
        'content': content,
        'isMe': true,
        'time': _getCurrentTime(),
      });

      messageController.clear();

      // Simulasi balasan otomatis
      _simulateReply();

      isSending.value = false;
    } catch (e) {
      print('❌ Error: $e');
      isSending.value = false;
      Get.snackbar('Error', 'Gagal mengirim pesan');
    }
  }

  void _simulateReply() {
    Future.delayed(const Duration(seconds: 2), () {
      final replies = ['Baik', 'Boleh', 'Siap', 'Oke', 'Nego aja'];
      messages.insert(0, {
        'content': replies[DateTime.now().millisecond % replies.length],
        'isMe': false,
        'time': _getCurrentTime(),
      });
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}
