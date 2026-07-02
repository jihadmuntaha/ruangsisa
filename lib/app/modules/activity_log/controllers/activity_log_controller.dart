import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
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

      // 1. Ambil token segar dari GetStorage yang didapat pas proses Login sukses
      String? token = box.read('token') ?? box.read('access_token');
      print("🔑 [LOG AUTH CHECK] Mengirim token ke backend: $token");

      String url = "http://10.20.166.45:8000/user/logs";

      var response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          // 🔐 PASPOR UTAMA: Kirim token via header Authorization Bearer
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        logList.assignAll(
          data.map((x) => ActivityLogModel.fromJson(x)).toList(),
        );
      } else {
        print(
          "🚨 [LOG FLUTTER ERROR]: Status Code ${response.statusCode} - ${response.body}",
        );
      }
    } catch (e) {
      print("🚨 [LOG EXCEPTION]: $e");
    } finally {
      isLoading(false);
    }
  }
}
