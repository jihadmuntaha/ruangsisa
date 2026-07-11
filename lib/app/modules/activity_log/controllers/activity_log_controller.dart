import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ruang_sisa/app_config.dart';
import '../../../data/models/activity_log_model.dart'; // ◄ Sudah pas mengarah ke folder baru, Beh!

class ActivityLogController extends GetxController {
  var isLoading = true.obs;
  var logList = <ActivityLogModel>[].obs;
  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    fetchLogs();
  }

  Future<void> fetchLogs() async {
    try {
      isLoading(true);
      print("🚀 [DEBUG FLUTTER] Fungsi fetchLogs() MULAI BERJALAN!");

      // Ambil token secara steril
      String? token = box.read('token') ?? box.read('access_token');
      print("🔑 [LOG AUTH CHECK] Mengirim token ke backend: $token");

      // 🟢 KEMBALIKAN KE URL ASLI TANPA /API (Sesuai hasil tes web lu)
      String url = "${AppConfig.baseUrl}/user/logs";
      print("🌐 [DEBUG FLUTTER] Mencoba nembak URL: $url");

      // 🟢 LONGGARKAN TIMEOUT JADI 20 DETIK:
      // Biar server Vercel + Supabase lu punya waktu buat bangun dari Cold Start!
      var response = await http
          .get(
            Uri.parse(url),
            headers: {
              "Content-Type": "application/json",
              "Authorization":
                  "Bearer $token", // ◄ Ini yang bakal ngilangin "Not authenticated"
            },
          )
          .timeout(const Duration(seconds: 20));

      print(
        "📡 [DEBUG FLUTTER] BERHASIL DAPAT RESPONS! Status Code: ${response.statusCode}",
      );
      print("📦 [DEBUG FLUTTER] Isi Body Mentah: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        // 1. Parsing semua data mentah dari backend ke model
        List<ActivityLogModel> parsedLogs = data
            .map((x) => ActivityLogModel.fromJson(x))
            .toList();

        // 2. Urutkan dari yang paling baru (ID terbesar ke terkecil)
        parsedLogs.sort((a, b) => b.id.compareTo(a.id));

        // 3. ✂️ KUNCI LIMITING: Ambil maksimal 15 log teratas saja
        List<ActivityLogModel> limitedLogs = parsedLogs.length > 15
            ? parsedLogs.sublist(0, 15)
            : parsedLogs;

        // 4. Masukkan data yang sudah dipotong ke list view utama
        logList.assignAll(limitedLogs);

        print(
          "✅ [DEBUG FLUTTER] Sukses membatasi data! Menampilkan ${logList.length} log terbaru.",
        );
      }
    } catch (e) {
      print("🚨 [LOG EXCEPTION CRASH]: Terjadi eror saat eksekusi: $e");
      Get.snackbar(
        "Server Berpikir",
        "Vercel sedang bersiap, coba ketuk ikon refresh di pojok kanan atas dalam 3 detik, Beh! 🔄",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Color(0xFF3A301C),
        colorText: Color.fromARGB(255, 255, 255, 255),
      );
    } finally {
      isLoading(false);
      print("🏁 [DEBUG FLUTTER] Fungsi fetchLogs() SELESAI EKSEKUSI.");
    }
  }
}
