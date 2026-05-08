import 'package:get/get.dart';

class NavigationController extends GetxController {
  // .obs supaya UI (Obx) bisa mendeteksi perubahan secara real-time
  var currentIndex = 0.obs;

  // Fungsi untuk ganti halaman (dipanggil saat navbar diklik)
  void changePage(int index) {
    currentIndex.value = index;
  }
}