import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/services/notification_service.dart';

class LoginController extends GetxController {
  final AuthProvider _authProvider = Get.put(AuthProvider());

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var rememberMe = false.obs;
  var isLoading = false.obs;
  var _isProcessing = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        "704950152906-bc94j0fasn2os09af328s6f26ahr44qi.apps.googleusercontent.com",
    scopes: ['email', 'profile'],
  );

  @override
  void onInit() {
    super.onInit();
    _loadRememberMe();
  }

  void _loadRememberMe() {
    try {
      final box = GetStorage();
      final savedEmail = box.read('saved_email');
      if (savedEmail != null && savedEmail.isNotEmpty) {
        emailController.text = savedEmail;
        rememberMe.value = true;
      }
    } catch (e) {
      print("🚨 Error loading remember me: $e");
    }
  }

  void _saveRememberMe(String email) {
    try {
      final box = GetStorage();
      if (rememberMe.value) {
        box.write('saved_email', email);
      } else {
        box.remove('saved_email');
      }
    } catch (e) {
      print("🚨 Error saving remember me: $e");
    }
  }

  // 🚀 FUNGSI LOGIN EMAIL & PASSWORD MURNI
  void login() async {
    if (_isProcessing || isLoading.value) return;
    if (!Get.isRegistered<LoginController>()) return;

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          "Error",
          "Email dan Password wajib diisi!",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      _isProcessing = true;
      isLoading.value = true;

      Map<String, dynamic> payload = {"email": email, "password": password};
      Response response = await _authProvider.loginUser(payload);

      if (!Get.isRegistered<LoginController>()) return;

      isLoading.value = false;
      _isProcessing = false;

      if (response.statusCode == 200 && response.body is Map) {
        String internalToken =
            response.body['access_token'] ??
            response.body['token']; // Backup key
        var userData = response.body['user'];

        // 🟢 FIX MUTLAK SORE INI: Inisialisasi murni tanpa instance terputus
        final box = GetStorage();

        // Bersihkan sisa dump cache lama biar gak tabrakan
        await box.remove('token');
        await box.remove('access_token');
        await box.remove('user');
        await box.remove('user_data');

        // Tulis ulang secara paksa, pastikan nilainya string beneran murni
        await box.write('access_token', internalToken.toString());
        await box.write('token', internalToken.toString());
        await box.write('user_data', userData);
        await box.write('user', userData);

        // Pli tambah debug print lokal biar kelihatan di log HP Realme lu pas klik login
        print(
          "📁 [DEBUG LOGIN MANUAL] Berhasil mengunci token: ${box.read('token')}",
        );

        _saveRememberMe(email);
        FocusManager.instance.primaryFocus?.unfocus();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.currentRoute != '/main-wrapper') {
            Get.offAllNamed('/main-wrapper');
          }
        });
      } else {
        Get.snackbar(
          "Login Gagal",
          response.body?['detail'] ?? "Server merespon ${response.statusCode}",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isRegistered<LoginController>()) {
        isLoading.value = false;
        _isProcessing = false;
      }
      Get.snackbar(
        "Error",
        "Tidak dapat terhubung ke server backend!",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🌐 FUNGSI LOGIN VIA GOOGLE SAKTI
  void loginWithGoogle() async {
    if (_isProcessing || isLoading.value) return;
    if (!Get.isRegistered<LoginController>()) return;

    try {
      _isProcessing = true;
      isLoading.value = true;

      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (!Get.isRegistered<LoginController>()) return;

      if (googleUser == null) {
        isLoading.value = false;
        _isProcessing = false;
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (!Get.isRegistered<LoginController>()) return;

      if (idToken == null) {
        isLoading.value = false;
        _isProcessing = false;
        Get.snackbar("Auth Gagal", "Gagal mendapatkan ID Token dari Google.");
        return;
      }

      Map<String, dynamic> payload = {"id_token": idToken};
      Response response = await _authProvider.loginWithGoogleProvider(payload);

      if (!Get.isRegistered<LoginController>()) return;

      isLoading.value = false;
      _isProcessing = false;

      if (response.statusCode == 200 && response.body is Map) {
        String internalToken =
            response.body['access_token'] ?? response.body['token'];
        var userData = response.body['user'];
        String userName = userData['name'] ?? 'User';

        final box = GetStorage();

        // Bersihkan dump cache sisa login lama
        await box.remove('token');
        await box.remove('access_token');
        await box.remove('user');
        await box.remove('user_data');

        // Tulis ulang secara seragam dan paksa murni
        await box.write('access_token', internalToken.toString());
        await box.write('token', internalToken.toString());
        await box.write('user_data', userData);
        await box.write('user', userData);

        print(
          "📁 [DEBUG LOGIN GOOGLE] Berhasil mengunci token: ${box.read('token')}",
        );
        Get.find<NotificationService>().getDeviceToken();

        FocusManager.instance.primaryFocus?.unfocus();
        Get.snackbar(
          "Sukses via Google",
          "Selamat datang, $userName!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (Get.currentRoute != '/main-wrapper') {
            Get.offAllNamed('/main-wrapper');
          }
        });
      } else {
        String errorMsg =
            response.body != null && response.body['detail'] != null
            ? response.body['detail']
            : "Verifikasi gagal";
        Get.snackbar(
          "Login Gagal",
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (error) {
      if (Get.isRegistered<LoginController>()) {
        isLoading.value = false;
        _isProcessing = false;
      }
      Get.snackbar("Error Exception", error.toString());
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    _isProcessing = false;
    super.onClose();
  }
}
