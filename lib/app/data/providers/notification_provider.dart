import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ruang_sisa/app_config.dart';

class NotificationProvider extends GetConnect {
  @override
  void onInit() {
    // 🟢 Hapus atau matikan konfigurasi baseUrl bawaan untuk menghindari duplikasi slash
    // httpClient.baseUrl = AppConfig.baseUrl;
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  Future<Response> getMyNotifications() async {
    try {
      final box = GetStorage();
      final tokenAuth = box.read('token');

      final Map<String, String> headers = {
        'Authorization': 'Bearer $tokenAuth',
        'Accept': 'application/json',
      };

      // 🟢 RAKIT URL SECARA MANUAL & STERIL DARI DOUBLE SLASH
      // Pastikan membersihkan karakter garing di akhir baseUrl jika ada
      String cleanBaseUrl = AppConfig.baseUrl.endsWith('/')
          ? AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1)
          : AppConfig.baseUrl;

      String fullUrl = "$cleanBaseUrl/api/notifications";

      print(
        "📡 FE sedang menarik riwayat notifikasi secara presisi dari: $fullUrl",
      );

      // 🟢 TEMBAK LANGSUNG MENGGUNAKAN FULL URL MURNI (Bypass Bug GetConnect)
      final response = await get(fullUrl, headers: headers);

      return response;
    } catch (e) {
      print("❌ Error di NotificationProvider: $e");
      return Response(
        statusCode: 500,
        statusText: "Koneksi Terputus: ${e.toString()}",
      );
    }
  }
}
