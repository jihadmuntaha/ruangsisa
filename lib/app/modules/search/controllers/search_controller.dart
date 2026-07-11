import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ruang_sisa/app_config.dart';

class SearchController extends GetxController {
  final String baseUrl = AppConfig.baseUrl;

  var searchResults = <Map<String, dynamic>>[].obs; // Penampung postingan
  var userResults = <Map<String, dynamic>>[].obs; // 🟢 Penampung user baru
  var isLoading = false.obs;

  final searchController = TextEditingController();
  var currentSearchQuery = ''.obs;
  var selectedCategoryId = 0.obs;
  var selectedPostType = 'Semua'.obs;
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();

  // 🟢 STATE SWITCH TAB UTAMA
  var activeTab = 'Material'.obs; // Pilihan: 'Material' atau 'Kontributor'

  final List<Map<String, dynamic>> categoriesList = [
    {"id": 0, "name": "Semua", "icon": Icons.grid_view_rounded},
    {"id": 1, "name": "Fashion", "icon": Icons.checkroom_rounded},
    {"id": 2, "name": "Elektronik", "icon": Icons.phone_android_rounded},
    {"id": 3, "name": "Furnitur", "icon": Icons.chair_rounded},
    {"id": 4, "name": "Buku", "icon": Icons.menu_book_rounded},
    {"id": 5, "name": "Lainnya", "icon": Icons.more_horiz_rounded},
  ];

  @override
  void onInit() {
    super.onInit();
    triggerSearch(); // Load data pertama kali
  }

  // 🟢 LOGIKA SELEKTOR PENCARIAN BERDASARKAN TAB YANG AKTIF
  void triggerSearch({String query = ""}) {
    currentSearchQuery.value = query;
    if (activeTab.value == 'Material') {
      fetchExplorPosts(query: query);
    } else {
      fetchExplorUsers(query: query);
    }
  }

  // Tarik Data Postingan (Tetap bawa filter lengkap)
  Future<void> fetchExplorPosts({String query = "", int? categoryId}) async {
    try {
      isLoading.value = true;
      if (categoryId != null) selectedCategoryId.value = categoryId;

      final box = GetStorage();
      String? token = box.read('access_token') ?? box.read('token');

      List<String> queryParams = [];
      if (currentSearchQuery.value.isNotEmpty) {
        queryParams.add(
          "search=${Uri.encodeComponent(currentSearchQuery.value)}",
        );
      }
      if (selectedCategoryId.value > 0) {
        queryParams.add("category_id=${selectedCategoryId.value}");
      }
      if (selectedPostType.value != 'Semua') {
        queryParams.add("post_type=${selectedPostType.value}");
      }
      if (minPriceController.text.isNotEmpty) {
        queryParams.add("min_price=${minPriceController.text}");
      }
      if (maxPriceController.text.isNotEmpty) {
        queryParams.add("max_price=${maxPriceController.text}");
      }

      String url = "$baseUrl/api/posts";
      if (queryParams.isNotEmpty) url += "?${queryParams.join("&")}";

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${token ?? ''}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        searchResults.assignAll(
          data.map((item) => Map<String, dynamic>.from(item)).toList(),
        );
      }
    } catch (e) {
      print("❌ [POST EXPLOR ERROR]: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // 🟢 TARIK DATA USER / KONTRIBUTOR DARI ENDPOINT BARU
  Future<void> fetchExplorUsers({String query = ""}) async {
    try {
      isLoading.value = true;
      final box = GetStorage();
      String? token = box.read('access_token') ?? box.read('token');

      // 🛰️ DISESUAIKAN MURNI TANPA /api KARENA ROUTER LU INDEPENDEN
      String url = "$baseUrl/user";
      if (query.isNotEmpty) {
        url += "?search=${Uri.encodeComponent(query)}";
      }

      print("📡 [FLUTTER SEARCH USER] Nembak URL: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer ${token ?? ''}",
          "Content-Type": "application/json",
        },
      );

      print("📡 [FLUTTER RESPONSE] Status Code: ${response.statusCode}");
      print("📡 [FLUTTER RESPONSE] Body: ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        userResults.assignAll(
          data.map((item) => Map<String, dynamic>.from(item)).toList(),
        );
        print(
          "✅ Berhasil memuat ${userResults.length} kontributor ke UI Flutter.",
        );
      } else {
        print("⚠️ Gagal load users: STATUS ${response.statusCode}");
      }
    } catch (e) {
      print("❌ [USER EXPLOR ERROR]: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Ganti Tab Utama Eksplor
  void switchTab(String tabName) {
    if (activeTab.value == tabName) return;
    activeTab.value = tabName;
    triggerSearch(query: searchController.text.trim());
  }

  void resetAdvancedFilters() {
    selectedPostType.value = 'Semua';
    minPriceController.clear();
    maxPriceController.clear();
    triggerSearch(query: searchController.text.trim());
  }

  void toggleCategory(int categoryId) {
    if (selectedCategoryId.value == categoryId) return;
    selectedCategoryId.value = categoryId;
    triggerSearch(query: searchController.text.trim());
  }

  void searchByHashtag(String hashtag) {
    searchController.text = hashtag;
    triggerSearch(query: hashtag);
  }

  void clearSearch() {
    searchController.clear();
    triggerSearch(query: "");
  }
}
