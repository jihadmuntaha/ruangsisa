import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final box = GetStorage();
  final _connect = GetConnect(
    timeout: const Duration(
      seconds: 20,
    ), // Memberi kompensasi cold-start Vercel
    allowAutoSignedCert: true,
  );

  // URL Backend RuangSisa Vercel
  final String baseUrl = "https://ruangsisa-backend.vercel.app";

  // State untuk text field inputan
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // State loading reactive
  var isLoading = false.obs;

  // State remember me reactive
  var rememberMe = false.obs;

  // 🚨 1. TAMBAHAN TAKTIS: Membaca cache Remember Me saat halaman pertama kali dibuka
  @override
  void onInit() {
    super.onInit();
    if (box.read('remember_me') == true) {
      rememberMe.value = true;
      emailController.text = box.read('saved_email') ?? '';
      passwordController.text = box.read('saved_password') ?? '';
    }
  }

  void loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Email/Username dan password wajib diisi!",
        backgroundColor: Colors.white.withOpacity(0.9),
      );
      return;
    }

    try {
      isLoading(true);

      // Menembak endpoint login FastAPI sesuai sasis Swagger UI
      final response = await _connect.post(
        '$baseUrl/api/auth/login',
        {"email": email, "password": password},
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // 1. Ambil token JWT hasil generate backend FastAPI
        String token = response.body['access_token'];
        await box.write('token', token);

        // 🚨 TAKTIK JALUR PINTAS JIHAD (ANTI RUN-ULANG BACKEND):
        // Kita ambil data dari key 'name' sesuai field di model UserModel SQLAlchemy lu.
        // Kalau di JSON root-nya kosong, baru kita fallback ke textfield inputan loginnya.
        String userLogin =
            response.body['name'] ??
            (response.body['user'] != null
                ? response.body['user']['name']
                : null) ??
            email;

        // Tetap simpan pakai key 'username' biar ProfileController kalian gak usah dirombak lagi
        await box.write('name', userLogin);

        // 🚨 Ambil juga data bio dan location dari backend jika ada biar halaman profile gak dummy statis
        if (response.body['bio'] != null)
          await box.write('bio', response.body['bio']);
        if (response.body['location'] != null)
          await box.write('location', response.body['location']);

        // 2. Eksekusi simpan/hapus kredensial berdasarkan status checkbox Remember Me
        if (rememberMe.value) {
          await box.write('remember_me', true);
          await box.write('saved_email', email);
          await box.write('saved_password', password);
        } else {
          await box.remove('remember_me');
          await box.remove('saved_email');
          await box.remove('saved_password');
        }

        Get.snackbar(
          "Berhasil",
          "Selamat datang kembali di RuangSisa!",
          backgroundColor: Colors.white.withOpacity(0.9),
        );

        // Navigasi Sasis: Tendang langsung masuk ke Main Wrapper menu utama
        Get.offAllNamed('/main-wrapper');
      } else {
        print("Response error: ${response.statusCode} - ${response.body}");
        String errMsg = "Gagal melakukan login";
        if (response.body != null && response.body['detail'] != null) {
          final detail = response.body['detail'];
          if (detail is String) {
            errMsg = detail;
          } else if (detail is List && detail.isNotEmpty) {
            errMsg = detail[0]['msg'] ?? "Format data tidak valid";
          }
        }

        Get.snackbar(
          "Gagal Login",
          errMsg,
          backgroundColor: Colors.white.withOpacity(0.9),
        );
      }
    } catch (e, stacktrace) {
      print("🚨 EROR JARINGAN LOGIN: $e");
      print("📌 STACKTRACE LOGIN: $stacktrace");
      Get.snackbar(
        "Error",
        "Gagal terhubung ke server: $e",
        backgroundColor: Colors.white.withOpacity(0.9),
      );
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
