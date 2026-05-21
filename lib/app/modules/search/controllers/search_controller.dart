import 'package:get/get.dart';

class SearchController extends GetxController {
  // Tempat logic pencarian barang atau filtering hashtag
  final searchQuery = ''.obs;

  void searchBarang(String query) {
    searchQuery.value = query;
  }
}
