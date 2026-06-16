import 'dart:ui';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ruang_sisa/app/data/providers/post_provider.dart'; // ATAU AuthProvider lu, Beh

class ProfileController extends GetxController {
  final box = GetStorage();
  final PostProvider _postProvider =
      Get.find<PostProvider>(); // Menggunakan provider yang udah ada tokennya

  // 👤 State Kosong Sempurna (Menunggu ketukan data dari Database)
  var name = "".obs;
  var bio = "".obs;
  var location = "".obs;
  var isLoading = false.obs;

  // 📦 List Kontribusi Postingan Aktif Si User
  var userContributions = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfileFromDatabase();
  }

  void fetchUserProfileFromDatabase() async {
    try {
      isLoading(true);
      final box = GetStorage();

      // Baca data user yang barusan kita simpan di LoginController
      var userData = box.read('user') ?? box.read('user_data');

      if (userData == null) {
        print("🚨 [PROFILE] Gagal total! data user beneran kosong di storage.");
        return;
      }

      // Setel nilai reaktifnya agar langsung muncul di layar HP lu
      var userId = userData['id'];
      name.value = userData['name'] ?? "Jihad Muntaha A";
      bio.value = userData['bio'] ?? "Kontributor Aktif RuangSisa";
      location.value = userData['location'] ?? "Kabupaten Tegal";

      print(
        "👤 [PROFILE] Sukses memuat profil lokal! ID: $userId | Nama: ${name.value}",
      );

      // Ambil list kontribusi postingan milik user ini dari DB laptop
      final response = await _postProvider.getPosts();
      if (response.statusCode == 200 && response.body != null) {
        List<dynamic> allPosts = response.body;
        var myPosts = allPosts
            .where((post) => post['user_id'].toString() == userId.toString())
            .toList();
        userContributions.assignAll(myPosts);
      }
    } catch (e) {
      print("🚨 [PROFILE] Terjadi error: $e");
    } finally {
      isLoading(false);
    }
  }

  // 🚪 Aksi Keluar Akun (Clear Session)
  void logoutAction() async {
    await box.erase();
    Get.snackbar(
      "Logout Berhasil",
      "Sesi aman ditutup, sampai jumpa kembali, Beh!",
      backgroundColor: const Color(0xFF2D6A4F),
      colorText: Color.fromARGB(255, 237, 246, 239),
    );
    Get.offAllNamed('/login');
  }
}
