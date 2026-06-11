import 'package:get/get.dart';

class AuthProvider extends GetConnect {
  // Ganti pakai URL Vercel produksi lu yang baru
  final String baseUrlProduction =
      "https://ruangsisa-backend.vercel.app/api/auth";

  // 🎯 1. Fungsi untuk Request OTP
  Future<Response> requestOtp(String email) async {
    final body = {"email": email};
    return await post('$baseUrlProduction/forgot-password', body);
  }

  // 🎯 2. Fungsi untuk Eksekusi Reset Password
  Future<Response> resetPassword(
    String email,
    String otpCode,
    String newPassword,
  ) async {
    final body = {
      "email": email,
      "otp_code": otpCode,
      "new_password": newPassword,
    };
    return await post('$baseUrlProduction/reset-password', body);
  }
}
