import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ruang_sisa/app/data/providers/post_provider.dart';
import 'package:ruang_sisa/app_config.dart';

class ProfileController extends GetxController {
  final box = GetStorage();
  final PostProvider _postProvider = Get.find<PostProvider>();
  final ImagePicker _picker = ImagePicker();

  // 📡 IP SAKRAL BACKEND (Gunakan basis HTTP Connect GetX bawaan proyek lu)
  final String baseUrl = AppConfig.baseUrl;

  // 👤 State Informasi Akun
  var name = "".obs;
  var email = "".obs;
  var bio = "".obs;
  var location = "".obs;
  var avatarUrl = "".obs; // Untuk nampung foto kustom / Google Avatar
  var ecoPoints = 0.obs;

  var isLoading = false.obs;
  var isActionLoading =
      false.obs; // Loading khusus pas submit upload / ganti password

  // 📦 List Kontribusi Postingan Aktif Si User
  var userContributions = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserProfileFromDatabase();
  }

  // ===================================================================
  // 🔄 PEMICU REFRESH INDICATOR (DITARIK KE BAWAH)
  // ===================================================================
  Future<void> refreshProfileData() async {
    // Memanggil fungsi load data yang sudah ada secara asynchronous
    fetchUserProfileFromDatabase();
    // Beri delay tipis agar animasi RefreshIndicator di UI terasa mulus
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // ===================================================================
  // 1. MEMUAT PROFIL & FILTER POSTINGAN (Logika Asli Lu yang Sudah Diperkuat)
  // ===================================================================
  void fetchUserProfileFromDatabase() async {
    try {
      isLoading(true);

      // Baca data user session lokal
      var userData = box.read('user') ?? box.read('user_data');

      if (userData == null) {
        print("🚨 [PROFILE] Gagal total! data user beneran kosong di storage.");
        return;
      }

      // Setel nilai reaktif utama
      var userId = userData['id'];
      name.value = userData['name'] ?? "Jihad Muntaha A";
      email.value = userData['email'] ?? "";
      bio.value = userData['bio'] ?? "Kontributor Aktif RuangSisa";
      location.value = userData['location'] ?? "Kabupaten Tegal";
      ecoPoints.value = userData['eco_points'] ?? 0;

      // 🍏 SINKRONISASI FOTO: Custom Avatar FastAPI, Google Avatar, atau Kosong
      if (userData['avatar'] != null &&
          userData['avatar'].toString().isNotEmpty) {
        avatarUrl.value = userData['avatar'].toString().startsWith('http')
            ? userData['avatar']
            : "$baseUrl/static/avatars/${userData['avatar']}";
      } else if (userData['google_avatar'] != null) {
        avatarUrl.value = userData['google_avatar'];
      } else {
        avatarUrl.value = "";
      }

      print(
        "👤 [PROFILE] Sukses memuat profil lokal! ID: $userId | Nama: ${name.value}",
      );

      // Ambil list kontribusi postingan milik user dari DB laptop
      final response = await _postProvider.getPosts();
      if (response.statusCode == 200 && response.body != null) {
        List<dynamic> allPosts = response.body;
        var myPosts = allPosts
            .where((post) => post['user_id'].toString() == userId.toString())
            .toList();
        userContributions.assignAll(myPosts);
      }
    } catch (e) {
      print("🚨 [PROFILE] Terjadi error: $e");
    } finally {
      isLoading(false);
    }
  }

  // ===================================================================
  // 📸 2. AMBIL FOTO VIA KAMERA REALME / GALERI & MULTIPART UPLOAD
  // ===================================================================
  Future<void> pickAndUploadAvatar(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );
      if (pickedFile == null) return;

      isActionLoading(true);
      String? token = box.read('token');

      // Siapkan form multipart data biner gambar
      final form = FormData({
        'file': MultipartFile(
          File(pickedFile.path),
          filename: 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      // Menggunakan GetConnect bawaan untuk upload ke FastAPI
      final GetConnect client = GetConnect();
      final response = await client.post(
        '$baseUrl/user/upload-avatar',
        form,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Sukses 🎉",
          "Foto profil kontributor berhasil diperbarui!",
          backgroundColor: const Color(0xFF2D6A4F),
          colorText: Colors.white,
        );

        // Update database cache lokal GetStorage lu
        var userData = box.read('user') ?? box.read('user_data') ?? {};
        userData['avatar'] = response.body['avatar'];
        box.write('user', userData);

        fetchUserProfileFromDatabase(); // Refresh data layar
      } else {
        Get.snackbar("Gagal ❌", "Server backend menolak unggahan foto.");
      }
    } catch (e) {
      Get.snackbar("Eror", "Gagal mengolah file gambar: $e");
    } finally {
      isActionLoading(false);
    }
  }

  // ===================================================================
  // 📝 3. UPDATE BIODATA (NAMA, BIO, LOKASI REGIONAL)
  // ===================================================================
  Future<void> updateProfileData(
    String newName,
    String newBio,
    String newLocation,
  ) async {
    if (newName.isEmpty) return;
    try {
      isActionLoading(true);
      String? token = box.read('token');

      final GetConnect client = GetConnect();
      final response = await client.put(
        '$baseUrl/user/profile', // 🟢 SINKRON: Sesuai endpoint @router.put("/profile")
        {"name": newName, "bio": newBio, "location": newLocation},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Sukses 🟢",
          "Biodata profil berhasil disinkronkan!",
          backgroundColor: const Color(0xFF2D6A4F),
          colorText: Colors.white,
        );

        // Timpa cache session lokal lu
        var userData = box.read('user') ?? box.read('user_data') ?? {};
        userData['name'] = newName;
        userData['bio'] = newBio;
        userData['location'] = newLocation;
        box.write('user', userData);

        fetchUserProfileFromDatabase();
      }
    } catch (e) {
      print("🚨 Eror update profil: $e");
    } finally {
      isActionLoading(false);
    }
  }

  // ===================================================================
  // 🔒 4. PRIVASI ACCOUN: UBAH PASSWORD LAPIS KEDUA (OTP OPSI B)
  // ===================================================================
  // 🔒 4. PRIVASI ACCOUN: UBAH PASSWORD AKSES LOKAL (ANTI 401 UNAUTHORIZED)
  Future<void> changeAccountPassword(
    String oldPassword,
    String newPassword,
  ) async {
    if (oldPassword.isEmpty || newPassword.isEmpty) {
      Get.snackbar("Peringatan ⚠️", "Kolom password tidak boleh kosong!");
      return;
    }
    try {
      isActionLoading(true);
      print("📦 [DEBUG GETSTORAGE] Semua Keys yang ada: ${box.getKeys()}");
      var dataUserLokal = box.read('user') ?? box.read('user_data');
      print(
        "👤 [DEBUG GETSTORAGE] Isi data user lokal saat ini: $dataUserLokal",
      );
      // 🕵️‍♂️ STRATEGI PELACAKAN TOKEN SECARA BERLAPIS (MENGANTISIPASI SEGALA NAMA KEY STORAGE)
      String? token = box.read('token') ?? box.read('access_token');

      // Jika masih null, coba bedah isi objek 'user' atau 'user_data' lu, siapa tahu tokennya nyelip di dalem
      if (token == null) {
        var userData = box.read('user') ?? box.read('user_data');
        if (userData != null) {
          token =
              userData['token'] ??
              userData['access_token'] ??
              userData['accessToken'];
        }
      }

      print("🔑 [DEBUG OTP] Hasil pelacakan Token murni: Bearer $token");

      if (token == null || token.isEmpty) {
        Get.snackbar(
          "Akses Ditolak ❌",
          "Token otentikasi tidak ditemukan di HP lu. Silakan logout lalu login ulang!",
          backgroundColor: Colors.red[800],
          colorText: Colors.white,
        );
        return;
      }

      final GetConnect client = GetConnect();

      // --- TAHAP 1: KIRIM REQUEST VALIDASI & PEMBUATAN OTP ---
      final requestResponse = await client.post(
        '$baseUrl/user/change-password/request',
        {"old_password": oldPassword, "new_password": newPassword},
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print(
        "📡 [DEBUG OTP FASE 1] Status Respons: ${requestResponse.statusCode}",
      );
      print("📦 [DEBUG OTP FASE 1] Body Respons: ${requestResponse.body}");

      if (requestResponse.statusCode == 200) {
        Get.back(); // Tutup dialog form password lama/baru biar rapi

        // --- TAHAP 2: SEPAK POP-UP INTERAKTIF INPUT OTP ---
        final TextEditingController otpInputCtrl = TextEditingController();

        Get.defaultDialog(
          title: "Konfirmasi Keamanan 🔒",
          titleStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D6A4F),
          ),
          backgroundColor: Colors.white,
          barrierDismissible: false,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          content: Column(
            children: [
              const Text(
                "Sebelum password diganti, masukkan 4 digit kode OTP yang tercetak di terminal uvicorn laptop lu!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: otpInputCtrl,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "0000",
                  hintStyle: TextStyle(color: Colors.grey[300]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          textConfirm: "Verifikasi Final",
          confirmTextColor: Colors.white,
          buttonColor: const Color(0xFF2D6A4F),
          textCancel: "Batal",
          cancelTextColor: Colors.grey,
          onConfirm: () async {
            String codeOtp = otpInputCtrl.text.trim();
            if (codeOtp.length < 4) {
              Get.snackbar("Eror ❌", "Kode OTP harus berukuran 4 digit penuh!");
              return;
            }

            // --- TAHAP 3: TEMBAK VERIFIKASI OTP FINAL ---
            final verifyResponse = await client.post(
              '$baseUrl/user/change-password/verify',
              {"otp": codeOtp},
              headers: {
                'Authorization':
                    'Bearer $token', // Menggunakan token pelacakan yang sama
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            );

            if (verifyResponse.statusCode == 200) {
              Get.back(); // Tutup dialog pop-up OTP
              Get.snackbar(
                "Sukses Total! 🎉",
                "Kata sandi akun RuangSisa lu resmi diubah dengan pengamanan OTP!",
                backgroundColor: const Color(0xFF2D6A4F),
                colorText: Colors.white,
              );
            } else {
              String msg =
                  verifyResponse.body != null &&
                      verifyResponse.body['detail'] != null
                  ? verifyResponse.body['detail']
                  : "Kode OTP salah atau kedaluwarsa.";
              Get.snackbar(
                "Gagal ❌",
                msg,
                backgroundColor: Colors.red[800],
                colorText: Colors.white,
              );
            }
          },
        );
      } else if (requestResponse.statusCode == 401) {
        Get.snackbar(
          "Sesi Tidak Sah 🔐",
          "Backend menolak token lu. Coba lakukan logout murni lalu login kembali agar session ter-refresh!",
          backgroundColor: Colors.red[800],
          colorText: Colors.white,
        );
      } else {
        String msg =
            requestResponse.body != null &&
                requestResponse.body['detail'] != null
            ? requestResponse.body['detail']
            : "Gagal memproses pengubahan sandi.";
        Get.snackbar(
          "Gagal ❌",
          msg,
          backgroundColor: Colors.red[800],
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("🚨 Eror kompilasi OTP: $e");
    } finally {
      isActionLoading(false);
    }
  }

  // ===================================================================
  // 5. DAFTAR / LOGIN INSTAN BIOMETRIK WAJAH (FACE ID)

  // ===================================================================
  // 🚪 Aksi Keluar Akun (Clear Session)
  // ===================================================================
  void logoutAction() async {
    await box.erase();
    Get.snackbar(
      "Logout Berhasil",
      "Sesi aman ditutup, sampai jumpa kembali!",
      backgroundColor: const Color(0xFF2D6A4F),
      colorText: const Color.fromARGB(255, 237, 246, 239),
    );
    Get.offAllNamed('/login');
  }
}
