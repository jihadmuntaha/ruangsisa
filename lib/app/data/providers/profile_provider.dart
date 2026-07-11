import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ruang_sisa/app_config.dart';

class ProfileProvider extends GetConnect {
  final box = GetStorage();
  final String baseUrl = AppConfig.baseUrl;

  // Header sakral dengan Bearer Token
  Map<String, String> _getHeaders() {
    String? token = box.read('token');
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  Future<Response> getProfile() async {
    return await get('$baseUrl/users/me', headers: _getHeaders());
  }

  // 1. Update nama, bio, dan lokasi murni
  Future<Response> updateProfile(Map<String, dynamic> data) async {
    return await put('$baseUrl/users/update', data, headers: _getHeaders());
  }

  // 2. Upload foto profil menggunakan Multipart FormData
  Future<Response> uploadAvatar(File imageFile) async {
    final form = FormData({
      'file': MultipartFile(
        imageFile,
        filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    });
    return await post(
      '$baseUrl/users/upload-avatar',
      form,
      headers: _getHeaders(),
    );
  }

  // 3. Ganti password akun lokal
  Future<Response> changePassword(Map<String, String> data) async {
    return await post(
      '$baseUrl/users/change-password',
      data,
      headers: _getHeaders(),
    );
  }
}
