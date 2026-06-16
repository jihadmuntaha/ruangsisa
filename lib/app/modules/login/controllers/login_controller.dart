import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/providers/auth_provider.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var rememberMe = false.obs;
  var isLoading = false.obs;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "704950152906-bc94j0fasn2os09af328s6f26ahr44qi.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  @override
  void onInit() {
    super.onInit();
  }

  // --- Fungsi Login Lokal ---
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

      print("📡 Response Status: ${response.statusCode}");

      if (response.statusCode == 200 && response.body is Map) {
        String internalToken = response.body['access_token'];
        var userData = response.body['user'];

        // ✅ AMANKAN DATA KE STORAGE DENGAN AWAIT
        final box = GetStorage();

        // Tunggu setiap operasi write selesai
        await box.write('access_token', internalToken);
        await box.write('user_data', userData);
        await box.write('user', userData);

        // Beri jeda kecil agar semua write selesai sempurna
        await Future.delayed(const Duration(milliseconds: 100));

        print("🔑 SESSION USER BERHASIL DI-LOCK: ${userData['name']}");

        Get.offAllNamed('/main-wrapper');
      } else {
        Get.snackbar(
          "Login Gagal",
          "Server merespon ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      print("❌ Error login: $e");
      Get.snackbar(
        "Error",
        "Tidak dapat terhubung ke server backend!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // --- Fungsi Login Google (SESUAIKAN) ---
  void loginWithGoogle() async {
    try {
      isLoading.value = true;
      print("🔍 [STEP 1] Tombol Google Sign-In diketuk...");

      // Clear session lama
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        isLoading.value = false;
        print("🚨 [STEP 2] User membatalkan pilihan akun.");
        return;
      }

      print("🟢 [STEP 3] Akun dipilih: ${googleUser.email}");

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        isLoading.value = false;
        print("🚨 [STEP 4] idToken NULL! Masalah SHA-1 mismatch.");
        Get.snackbar("Auth Gagal", "Gagal mendapatkan ID Token dari Google.");
        return;
      }

      print("🔑 [STEP 5] ID Token: ${idToken.substring(0, 10)}...");

      Map<String, dynamic> payload = {"id_token": idToken};
      Response response = await _authProvider.loginWithGoogleProvider(payload);
      isLoading.value = false;

      print("📡 [STEP 6] Response Status: ${response.statusCode}");
      print("📡 [STEP 7] Response Body: ${response.body}");

      if (response.statusCode == 200 && response.body is Map) {
        String internalToken = response.body['access_token'];
        var userData = response.body['user'];
        String userName = userData['name'] ?? 'User';

        print("🔑 TOKEN: $internalToken");

        // ✅ PERBAIKAN UTAMA: Simpan dengan await dan jeda
        final box = GetStorage();

        // Operasi 1: Simpan token
        await box.write('access_token', internalToken);

        // Operasi 2: Simpan data user (jika perlu jeda)
        await Future.delayed(const Duration(milliseconds: 50));
        await box.write('user_data', userData);

        // Operasi 3: Simpan user
        await Future.delayed(const Duration(milliseconds: 50));
        await box.write('user', userData);

        // Operasi 4: Verifikasi data tersimpan
        await Future.delayed(const Duration(milliseconds: 100));
        final savedUser = await box.read('user');

        if (savedUser != null) {
          print("✅ [VERIFIKASI] User berhasil disimpan: ${savedUser['name']}");
          print("💾 [SESSION SAVED] Session Akun Google ($userName) Sukses!");
        } else {
          print("❌ [VERIFIKASI] Gagal menyimpan user!");
        }

        FocusManager.instance.primaryFocus?.unfocus();

        Get.snackbar(
          "Sukses via Google",
          "Selamat datang, $userName!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        Get.offAllNamed('/main-wrapper');
      } else {
        Get.snackbar(
          "Login Gagal",
          response.body?['detail'] ?? "Verifikasi gagal",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      isLoading.value = false;
      print("🚨 [ERROR] Exception: $error");
      Get.snackbar("Error Exception", error.toString());
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
