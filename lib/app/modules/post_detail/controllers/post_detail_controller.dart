import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/post_provider.dart';
import '../../home/controllers/home_controller.dart';

class PostDetailController extends GetxController {
  final PostProvider _postProvider = Get.put(PostProvider());

  // Post data
  var post = Rxn<Map<String, dynamic>>();
  var isLoading = false.obs;
  var postId = 0.obs;

  // Comments
  var comments = <Map<String, dynamic>>[].obs;
  var isLoadingComments = false.obs;

  // Comment form
  final commentController = TextEditingController();
  var isSendingComment = false.obs;

  // Current user
  var currentUserId = 0;

  @override
  void onInit() {
    super.onInit();
    // Ambil postId dari arguments
    if (Get.arguments != null && Get.arguments['post_id'] != null) {
      postId.value = Get.arguments['post_id'];
      loadCurrentUser();
      fetchPostDetail();
      fetchComments();
    } else {
      Get.back();
      Get.snackbar("Error", "ID Postingan tidak ditemukan");
    }
  }

  void loadCurrentUser() {
    final box = GetStorage();
    final user = box.read('user');
    if (user != null) {
      currentUserId = user['id'] ?? 0;
    }
  }

  Future<void> fetchPostDetail() async {
    try {
      isLoading.value = true;
      final homeController = Get.find<HomeController>();
      final existingPost = homeController.postsList.firstWhereOrNull(
        (p) => p['id'] == postId.value,
      );

      if (existingPost != null) {
        post.value = existingPost;
        print("✅ Post loaded from home list");
      } else {
        // TODO: Panggil API get post by id
        // final response = await _postProvider.getPostById(postId.value);
        // if (response.statusCode == 200) {
        //   post.value = response.body;
        // }
      }
    } catch (e) {
      print("❌ Error fetch post: $e");
      Get.snackbar("Error", "Gagal memuat detail postingan");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchComments() async {
    try {
      isLoadingComments.value = true;
      final response = await _postProvider.getComments(postId.value);

      print("💬 [FETCH COMMENTS] Status: ${response.statusCode}");
      print("💬 [FETCH COMMENTS] Body type: ${response.body.runtimeType}");

      if (response.statusCode == 200 && response.body != null) {
        // ✅ Handle response yang berupa List
        if (response.body is List) {
          final List<dynamic> data = response.body;
          comments.value = data
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          print("✅ Loaded ${comments.length} comments");
        } else if (response.body is Map && response.body['data'] is List) {
          final List<dynamic> data = response.body['data'];
          comments.value = data
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
          print("✅ Loaded ${comments.length} comments from data field");
        } else {
          print("⚠️ Unexpected response format: ${response.body.runtimeType}");
          comments.clear();
        }
      } else {
        print("⚠️ Failed to load comments: ${response.statusCode}");
        comments.clear();
      }
    } catch (e) {
      print("❌ Error fetch comments: $e");
      comments.clear();
    } finally {
      isLoadingComments.value = false;
    }
  }

  Future<void> sendComment() async {
    final content = commentController.text.trim();
    if (content.isEmpty) {
      Get.snackbar("Error", "Komentar tidak boleh kosong");
      return;
    }

    // ✅ Cek user ID
    if (currentUserId == 0) {
      Get.snackbar("Error", "User tidak terdeteksi, silakan login ulang");
      return;
    }

    try {
      isSendingComment.value = true;

      final data = {
        'post_id': postId.value,
        'user_id': currentUserId,
        'content': content,
      };

      print("📝 Sending comment: $data");

      final response = await _postProvider.sendComment(data);

      if (response.statusCode == 201 || response.statusCode == 200) {
        commentController.clear();
        Get.snackbar("Sukses", "Komentar berhasil dikirim");
        // Focus node unfocus
        FocusManager.instance.primaryFocus?.unfocus();
        await fetchComments();
      } else {
        String errorMsg = response.body?['detail'] ?? "Gagal mengirim komentar";
        print("❌ Send comment failed: $errorMsg");
        Get.snackbar("Gagal", errorMsg);
      }
    } catch (e) {
      print("❌ Error send comment: $e");
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    } finally {
      isSendingComment.value = false;
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      final response = await _postProvider.deleteComment(
        commentId,
        currentUserId,
      );

      if (response.statusCode == 200) {
        comments.removeWhere((c) => c['id'] == commentId);
        Get.snackbar("Sukses", "Komentar dihapus");
      } else {
        Get.snackbar("Gagal", "Gagal menghapus komentar");
      }
    } catch (e) {
      print("❌ Error delete comment: $e");
      Get.snackbar("Error", "Terjadi kesalahan: $e");
    }
  }

  void goToChat() {
    final ownerId = post.value?['user_id'];
    final ownerName = post.value?['author']?['name'] ?? "Penjual";

    Get.toNamed('/chat', arguments: {'user_id': ownerId, 'name': ownerName});
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }
}
