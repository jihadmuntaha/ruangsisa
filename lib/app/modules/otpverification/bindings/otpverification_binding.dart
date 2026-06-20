import 'package:get/get.dart';
// 🟢 FIXED: Jalur import diselaraskan dengan nama file controller asli lu yang pake underscore (_)
import '../controllers/otpverification_controller.dart';

class OtpverificationBinding extends Bindings {
  @override
  void dependencies() {
    // 🟢 FIXED: Memanggil class OtpVerificationController dengan huruf V besar sesuai isi file controllernya
    Get.lazyPut<OtpVerificationController>(() => OtpVerificationController());
    print(
      "📦 [BINDING] OtpVerificationController berhasil didaftarkan ke memori GetX!",
    );
  }
}
