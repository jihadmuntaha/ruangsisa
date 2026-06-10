import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  final box = GetStorage();

  var name = ''.obs;
  var bio = ''.obs;
  var location = ''.obs;
  var userContributions = <Map<String, String>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  // 🚨 MANANTRA PENYELAMAT SINKRONISASI JIHAD:
  // onReady akan otomatis memanggil ulang data segar dari GetStorage
  // begitu user masuk dari halaman login ke halaman dashboard utama!
  @override
  void onReady() {
    super.onReady();
    loadUserData();
  }

  void loadUserData() {
    // Ambil data yang barusan ditulis oleh LoginController
    name.value = box.read('name') ?? 'Kontributor RuangSisa';
    bio.value =
        box.read('bio') ?? 'Pecinta gerakan sirkulasi ekonomi textile waste ♻️';
    location.value = box.read('location') ?? 'Kabupaten Tegal, Central Java';

    userContributions.clear();
  }

  void logoutAction() async {
    await box.erase(); // Bersihkan sasis memori total pas logout
    Get.offAllNamed('/login');
  }
}
