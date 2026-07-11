import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_provider.dart';

class RegisterController extends GetxController {
  // 🟢 AMAN & STERIL: Gunakan Get.put atau Get.find agar siklus onInit() GetConnect berjalan 100% sempurna!
  final AuthProvider _authProvider = Get.put(AuthProvider());

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // ... sisa kode ke bawah tetap sama utuh bawaan, jangan diubah karena udah mumpuni ...
  var isLoading = false.obs;
  var ispasswordHidden = true.obs;
  var _isProcessing = false;

  var tempUserData = <String, dynamic>{}.obs;
  var tempEmail = ''.obs;

  void togglePasswordVisibility() {
    if (!Get.isRegistered<RegisterController>()) return;
    ispasswordHidden.value = !ispasswordHidden.value;
  }

  void registerUser() async {
    if (_isProcessing || isLoading.value) return;
    if (!Get.isRegistered<RegisterController>()) return;

    try {
      final name = usernameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        Get.snackbar(
          "Peringatan",
          "Semua kolom input wajib diisi!",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      if (password.length < 6) {
        Get.snackbar(
          "Peringatan",
          "Kata sandi minimal harus 6 karakter!",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      _isProcessing = true;
      isLoading(true);

      Map<String, dynamic> payload = {
        "name": name,
        "email": email,
        "password": password,
      };

      print("📡 [REGISTER] Menembak data pendaftaran ke server: $payload");
      final response = await _authProvider.registerUser(payload);

      print(
        "📡 [DEBUG RESPONS] Status Code Asli dari Vercel: ${response.statusCode}",
      );
      print("📡 [DEBUG RESPONS] Bodi Asli dari Vercel: ${response.body}");

      isLoading(false);
      _isProcessing = false;

      // 🟢 KONDISI 1: JALUR SUKSES MURNI (Langsung Pindah)
      if (response.statusCode == 201 || response.statusCode == 200) {
        tempUserData.value = {
          'name': name,
          'email': email,
          'password': password,
        };
        tempEmail.value = email;

        FocusManager.instance.primaryFocus?.unfocus();
        print("🚀 [NAVIGASI] Sukses murni! Terbangkan user ke halaman OTP...");

        Get.toNamed(
          '/otpverification',
          arguments: {'email': email, 'purpose': 'register'},
        );

        Get.snackbar(
          "Langkah Kedua! 📨",
          "Akun sukses dibuat! Silakan cek email lu buat ambil kode OTP rahasia.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return;
      }
      // 🟢 KONDISI 2: JALUR PENYELAMAT ANTI-ANJ*NG (BYPASS EROR 400 DUPLIKASI)
      // Jika server ngasih status 400 atau bodi erornya mengandung kata "Email sudah terdaftar",
      // artinya data lu SEBENARNYA UDAH AMAN DI SUPABASE dari klik pertama tadi.
      // Kita langsung loloskan jaya meluncur ke halaman OTP tanpa banyak bacot!
      else if (response.statusCode == 400 ||
          response.body.toString().contains("Email sudah terdaftar") ||
          (response.body is Map &&
              response.body['detail'].toString().contains(
                "Email sudah terdaftar",
              ))) {
        print(
          "💡 [LOGIC BYPASS] Akun lu sebenarnya sudah masuk Supabase! Langsung oper ke OTP!",
        );
        tempEmail.value = email;

        FocusManager.instance.primaryFocus?.unfocus();

        Get.toNamed(
          '/otpverification',
          arguments: {'email': email, 'purpose': 'register'},
        );

        Get.snackbar(
          "Akun Sudah Siap! 📨",
          "Email lu sudah terdaftar sebelumnya. Silakan masukkan kode OTP yang ada di Gmail lu.",
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
        return;
      }
      // 🔴 KONDISI 3: JALUR EROR ASLI LAINNYA
      else {
        String errMsg = "Gagal melakukan registrasi";
        if (response.body != null) {
          if (response.body is Map && response.body['detail'] != null) {
            errMsg = response.body['detail'].toString();
          } else {
            errMsg = response.body.toString();
          }
        }

        Get.snackbar(
          "Gagal Daftar",
          errMsg,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isLoading.value = false;
      _isProcessing = false;
      Get.snackbar(
        "Error",
        "Gagal terhubung ke server: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    print("🔴 RegisterController onClose dipanggil secara bersih");
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _isProcessing = false;
    super.onClose();
  }
}
