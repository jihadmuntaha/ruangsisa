import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/providers/auth_provider.dart';

class LoginController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  // 🟢 1. Deklarasikan variabel menggunakan 'late' agar tidak langsung dibuat statis di awal
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  var rememberMe = false.obs;
  var isLoading = false.obs;

  // 🛠️ Inisialisasi GoogleSignIn instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "704950152906-bc94j0fasn2os09af328s6f26ahr44qi.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  // 🟢 2. Hidupkan controller teks BARU setiap kali halaman login ini dimuat oleh GetX
  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  // --- Fungsi Login Lokal Kemarin (Tetap Dipertahankan) ---
  void login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Email dan Password wajib diisi!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    try {
      isLoading.value = true;
      Map<String, dynamic> payload = {
        "email": emailController.text.trim(),
        "password": passwordController.text,
      };
      Response response = await _authProvider.loginUser(payload);
      isLoading.value = false;

      if (response.statusCode == 200) {
        String token = response.body['access_token'];
        String userName = response.body['user']['name'];
        print("🔑 JWT TOKEN RUANGSISA: $token");
        Get.snackbar(
          "Sukses",
          "Selamat datang kembali, $userName!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed('/main-wrapper');
      } else {
        String errorMsg = response.body?['detail'] ?? "Terjadi kesalahan";
        Get.snackbar(
          "Login Gagal",
          errorMsg,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Error",
        "Tidak dapat terhubung ke server backend!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🛠️ Fungsi Login Google
  void loginWithGoogle() async {
    try {
      isLoading.value = true;

      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        isLoading.value = false;
        Get.snackbar(
          "Google Auth Gagal",
          "Gagal mendapatkan ID Token dari Google.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      Map<String, dynamic> payload = {"id_token": idToken};
      Response response = await _authProvider.loginWithGoogleProvider(payload);
      isLoading.value = false;

      if (response.statusCode == 200) {
        String internalToken = response.body['access_token'];
        String userName = response.body['user']['name'];

        print("🔑 JWT GOOGLE TOKEN RUANGSISA: $internalToken");

        Get.snackbar(
          "Sukses via Google",
          "Selamat datang, $userName!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/main-wrapper');
      } else {
        String errorMsg =
            response.body?['detail'] ?? "Verifikasi backend gagal";
        Get.snackbar(
          "Google Login Gagal",
          errorMsg,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      isLoading.value = false;
      print("🚨 DETAIL ERROR GOOGLE SIGN IN: $error");
      Get.snackbar(
        "Error",
        "Gagal melakukan Google Sign In: $error",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🟢 3. Matikan secara aman pas halamannya ditutup/ditinggal permanen
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
