import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ContributorProfileController extends GetxController {
  final String baseUrl = "http://10.20.166.45:8000";

  var isLoading = false.obs;
  var contributorName = ''.obs;
  var contributorEmail = ''.obs;
  var contributorAvatar = ''.obs;
  var contributorBio = ''.obs;
  var contributorLocation = ''.obs;

  // Penampung barang-barang khusus yang diposting oleh kontributor ini saja
  var contributorPosts = <Map<String, dynamic>>[].obs;

  late int userId;

  @override
  void onInit() {
    super.onInit();
    // 🟢 Tangkap kiriman ID dari arguments Get.toNamed
    userId = Get.arguments['user_id'] ?? 0;
    fetchContributorDetails();
  }

  Future<void> fetchContributorDetails() async {
    if (userId == 0) return;
    try {
      isLoading.value = true;

      // 🛰️ 1. Ambil data profil kontributor (Bisa lewat endpoint /user atau /posts filter user)
      // Kita manfaatkan endpoint GET /posts yang sudah kita modifikasi dengan filter query param nanti
      String postUrl = "$baseUrl/api/posts"; // Sesuai endpoint bento grid lu

      final response = await http.get(Uri.parse(postUrl));

      if (response.statusCode == 200) {
        final List<dynamic> allPosts = jsonDecode(response.body);

        // Saring postingan yang user_id nya sesuai dengan kontributor ini
        var filteredPosts = allPosts
            .where((post) => post['user_id'] == userId)
            .toList();
        contributorPosts.assignAll(
          filteredPosts.map((item) => Map<String, dynamic>.from(item)).toList(),
        );

        // Ambil info author dari postingan pertamanya jika ada
        if (filteredPosts.isNotEmpty) {
          var authorData = filteredPosts.first['author'];
          contributorName.value = authorData['name'] ?? 'Kontributor RuangSisa';
          contributorAvatar.value = authorData['avatar'] ?? '';
        } else {
          contributorName.value = "Kontributor #$userId";
        }
      }
    } catch (e) {
      print("❌ [CONTRIBUTOR PROFILE ERROR]: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
