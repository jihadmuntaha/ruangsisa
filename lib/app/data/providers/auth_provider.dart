import 'package:get/get.dart';

class AuthProvider extends GetConnect {
  // ⚠️ ATUR BASE URL SESUAI EMULATOR / HP KAMU
  // Gunakan 'http://10.0.2.2:8000/auth' jika pakai Emulator Android bawaan
  // Gunakan IP Laptop kamu (misal: 'http://192.168.1.X:8000/auth') jika pakai HP Fisik
  final String baseUrlAuth = "http://192.168.1.5:8000/auth";

  // Fungsi menembak endpoint Register
  Future<Response> registerUser(Map<String, dynamic> data) {
    return post('$baseUrlAuth/register', data);
  }

  // Fungsi menembak endpoint Login
  Future<Response> loginUser(Map<String, dynamic> data) {
    return post('$baseUrlAuth/login', data);
  }

  // Fungsi untuk google id token ke fastapi (opsional, bisa diimplementasikan nanti jika backend sudah siap)
  Future<Response> loginWithGoogleProvider(Map<String, dynamic> data) async {
    final response = await post('$baseUrlAuth/google', data);
    print("STATUS: ${response.statusCode}");
    print("BODY: ${response.body}");
    return response;
  }
}
