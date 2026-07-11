import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ruang_sisa/app_config.dart';

class AuthProvider extends GetConnect {
  final String baseUrlAuth = AppConfig.baseUrl;

  @override
  void onInit() {
    super.onInit();
    baseUrl =
        null; // Biarkan null agar tidak merusak rute bawaan Google Login lu

    httpClient.timeout = const Duration(seconds: 10);

    httpClient.addRequestModifier<dynamic>((request) async {
      final String fullUrl = request.url.toString();

      if (fullUrl.contains('auth/google') ||
          fullUrl.contains('auth/login') ||
          fullUrl.contains('auth/register')) {
        print("🔓 [INTERCEPTOR] Rute Publik Lolos Tanpa Token: $fullUrl");
        return request;
      }

      final box = GetStorage();
      final token = box.read('access_token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });
  }

  // 📡 =============== ENDPOINT ROUTER MANDIRI & SAH ===============
  // Disesuaikan murni tanpa /api sesuai bukti nyata log Vercel lu!

  Future<Response> registerUser(Map<String, dynamic> data) {
    print("📡 [REGISTER] Menembak ke jalur sah: $baseUrlAuth/auth/register");
    return post('$baseUrlAuth/auth/register', data); // 🟢 Hapus /api, Beh!
  }

  Future<Response> loginUser(Map<String, dynamic> data) {
    print("📡 [LOGIN] Menembak ke jalur sah: $baseUrlAuth/auth/login");
    return post('$baseUrlAuth/auth/login', data); // 🟢 Hapus /api, Beh!
  }

  Future<Response> loginWithGoogleProvider(Map<String, dynamic> data) async {
    print("📡 [PROVIDER GOOGLE] Menembak ke Google...");
    return await post(
      '$baseUrlAuth/auth/google',
      data,
    ); // 🟢 Tetap utuh bawaan lu
  }

  Future<Response> verifyOtpProvider(Map<String, dynamic> payload) async {
    print(
      "📡 [OTP VERIFY] Menembak murni ke rute sah: $baseUrlAuth/auth/verify-otp",
    );
    // 🟢 SINKRON MURNI: Mengarah langsung ke @router.post("/verify-otp") Python lu
    return await post('$baseUrlAuth/auth/verify-otp', payload);
  }

  Future<Response> resendOtpProvider(Map<String, dynamic> payload) async {
    print(
      "📡 [OTP RESEND] Menembak murni ke rute sah: $baseUrlAuth/auth/resend-otp",
    );
    // 🟢 SINKRON MURNI: Mengarah langsung ke @router.post("/resend-otp") Python lu
    return await post('$baseUrlAuth/auth/resend-otp', payload);
  }
}
