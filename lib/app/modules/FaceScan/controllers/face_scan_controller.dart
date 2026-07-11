import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ruang_sisa/app_config.dart'; // 🟢 Kunci utama impor alamat sakral

class FaceScanController extends GetxController {
  CameraController? cameraController;
  var isCameraInitialized = false.obs;
  var isLoading = false.obs;
  final box = GetStorage();

  String mode = 'login';
  String emailForLogin = '';

  // 🍏 STATE FACE ID APPLE STYLE: Langkah scan multi-angle
  var currentStep = 1.obs; // Step 1: Depan, Step 2: Kiri, Step 3: Kanan
  var stepInstruction = "Posisikan Wajah Menghadap DEPAN".obs;
  List<XFile> capturedFiles = []; // Menampung hasil jepretan 3 sudut foto

  // 📡 JALUR CLOUD MURNI VERCEL:
  // Menggunakan baseUrl murni secara utuh (contoh: https://ruangsisa-backend-livid.vercel.app)
  // Tanpa rekayasa port lokal (:8000) biar langsung tembus serverless cloud!
  String get serverUrl {
    // Pastikan tidak ada trailing slash (tanda /) di paling ujung
    if (AppConfig.baseUrl.endsWith('/')) {
      return AppConfig.baseUrl.substring(0, AppConfig.baseUrl.length - 1);
    }
    return AppConfig.baseUrl;
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      mode = Get.arguments['mode'] ?? 'login';
      emailForLogin = Get.arguments['email'] ?? '';
    }
    _initCamera();
  }

  void _initCamera() async {
    try {
      final List<CameraDescription> availableDevCameras =
          await availableCameras();

      if (availableDevCameras.isEmpty) {
        Get.snackbar("Eror", "Kamera perangkat tidak terdeteksi, Beh!");
        return;
      }

      CameraDescription? frontCamera;
      for (var camera in availableDevCameras) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      frontCamera ??= availableDevCameras.first;

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      Get.snackbar("Eror Kamera", "Gagal membuka kamera: $e");
    }
  }

  // 🟢 FUNGSI JEP RET INTERAKTIF MULTI-STEPS
  void captureAndSendFace() async {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;
    if (isLoading.value) return;

    try {
      isLoading.value = true; // Nyalakan loading spinner UI
      final XFile imageFile = await cameraController!.takePicture();

      // 🍏 JIKA MODE REGISTRASI PREMIUM (3 LANGKAH)
      if (mode == 'register') {
        capturedFiles.add(imageFile);

        if (currentStep.value == 1) {
          currentStep.value = 2;
          stepInstruction.value = "Sekarang Menoleh Sedikit ke KIRI, Beh!";
          isLoading.value =
              false; // Matikan loading sementara untuk step berikutnya
          Get.snackbar(
            "Langkah 1 Berhasil 👍",
            "Sekarang miringkan muka lu ke kiri.",
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
          return;
        } else if (currentStep.value == 2) {
          currentStep.value = 3;
          stepInstruction.value = "Terakhir, Menoleh Sedikit ke KANAN, Beh!";
          isLoading.value =
              false; // Matikan loading sementara untuk step terakhir
          Get.snackbar(
            "Langkah 2 Berhasil 👍",
            "Terakhir, miringkan muka lu ke kanan.",
            backgroundColor: Colors.blue,
            colorText: Colors.white,
          );
          return;
        } else {
          // Jika sudah terkumpul 3 foto, kunci instruksi dan kirim massal ke FastAPI
          stepInstruction.value =
              "Sedang mengunci karakteristik wajah seluruh muka lu...";
          await _sendPremiumFaceIdRegister();
        }
      }
      // 🔑 JIKA MODE LOGIN BIOMETRIK (1 LANGKAH)
      else {
        await _executeFaceIdLogin(imageFile);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        "Eror",
        "Gagal menangkap gambar: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // 🔥 ACTION 1: KIRIM 3 FILE SEKALIGUS KE API REGISTER PREMIUM FASTAPI CLOUD
  Future<void> _sendPremiumFaceIdRegister() async {
    try {
      // 🟢 SINKRON MURNI HTTPS VERCEL CLOUD
      String url = "$serverUrl/auth/register-face-premium?email=$emailForLogin";
      print(
        "📡 [MULTIPART POST] Menembak 3 Angulasi Muka ke Cloud Vercel: $url",
      );

      var request = http.MultipartRequest('POST', Uri.parse(url));

      for (var file in capturedFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path),
        );
      }

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 25),
      );
      var response = await http.Response.fromStream(streamedResponse);

      print(
        "📡 [MULTIPART REGISTER RESPONS] Status Cloud: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "Premium Face ID Aktif 🍏🎉",
          "Sistem biometrik se-muka lu sukses dikunci!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        capturedFiles.clear();
        Get.offAllNamed('/login');
      } else {
        _resetRegisterFlow();
        Get.snackbar(
          "Gagal ❌",
          "OpenCV gagal membaca pola wajah lu. Ulangi dari posisi depan, Beh!",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      _resetRegisterFlow();
      print("❌ [FACE REGIS ERROR] Kendala Cloud: $e");
      Get.snackbar(
        "Eror Jaringan",
        "Gagal menghubungi server Vercel Cloud lu: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false; // 🟢 KUNCI MATI
    }
  }

  // 🔑 ACTION 2: JALUR LOGIN INSTAN BIOMETRIK NYOCOKIN WAJAH
  Future<void> _executeFaceIdLogin(XFile imageFile) async {
    try {
      // 🟢 SINKRON MURNI HTTPS VERCEL CLOUD
      String url = "$serverUrl/auth/login-face?email=$emailForLogin";
      print(
        "📡 [MULTIPART POST] Verifikasi Wajah Single-Angle ke Cloud Vercel: $url",
      );

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      var response = await http.Response.fromStream(streamedResponse);

      print(
        "📡 [MULTIPART LOGIN RESPONS] Status Cloud: ${response.statusCode}",
      );

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

        String internalToken = data['access_token'] ?? data['token'] ?? '';
        var userData = data['user'] ?? data;

        // Kunci session ke lokal GetStorage
        await box.write('access_token', internalToken.toString());
        await box.write('token', internalToken.toString());
        await box.write('user_data', userData);
        await box.write('user', userData);

        print("📸 [FACE ID SUCCESS] Sesi berhasil dikunci murni via Cloud!");
        FocusManager.instance.primaryFocus?.unfocus();

        Get.offAllNamed('/main-wrapper');
      } else {
        Get.snackbar(
          "Akses Ditolak ❌",
          "Wajah atau data email anda tidak sinkron! Cari tempat terang.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("❌ [FACE LOGIN ERROR] Kendala Cloud: $e");
      Get.snackbar(
        "Eror Jaringan",
        "Gagal validasi ke server Vercel Cloud: $e",
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading.value = false; // 🟢 KUNCI MATI
    }
  }

  void _resetRegisterFlow() {
    capturedFiles.clear();
    currentStep.value = 1;
    stepInstruction.value = "Posisikan Wajah Menghadap DEPAN";
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
