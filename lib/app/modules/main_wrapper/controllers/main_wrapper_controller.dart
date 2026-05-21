import 'package:get/get.dart';

class MainWrapperController extends GetxController {
  // Variabel untuk menyimpan index halaman yang aktif (reaktif .obs)
  final currentIndex = 0.obs;

  // Fungsi pemindah halaman utama
  void changePage(int index) {
    currentIndex.value = index;
  }

  // Fungsi alias agar tidak error jika di View tertulis changeTabIndex
  void changeTabIndex(int index) {
    currentIndex.value = index;
  }
}
