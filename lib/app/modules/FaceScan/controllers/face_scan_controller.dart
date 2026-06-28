import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class FaceScanController extends GetxController {
  CameraController? cameraController;
  var isCameraInitialized = false.obs;
  var isLoading = false.obs;
  final box = GetStorage();

  String mode = 'login';
  String emailForLogin = '';

  // 🍏 STATE FACE ID APPLE STYLE: Menyimpan langkah scan multi-angle
  var currentStep = 1.obs; // Step 1: Depan, Step 2: Kiri, Step 3: Kanan
  var stepInstruction = "Posisikan Wajah Menghadap DEPAN".obs;
  List<XFile> capturedFiles = []; // Menampung hasil jepretan 3 sudut foto

  // 📡 IP SAKRAL BACKEND DETIK INI (Satukan di satu tempat agar mudah diubah)
  final String ipBackend = "10.20.166.45:8000";

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
      // Mengambil daftar kamera langsung dari sistem biometrik perangkat
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
      isLoading.value = true;
      final XFile imageFile = await cameraController!.takePicture();

      // JIKA MODE REGISTRASI: Jalankan Alur 3 Langkah ala Apple Face ID
      if (mode == 'register') {
        capturedFiles.add(imageFile);

        if (currentStep.value == 1) {
          currentStep.value = 2;
          stepInstruction.value = "Sekarang Menoleh Sedikit ke KIRI, Beh!";
          isLoading.value = false;
          Get.snackbar(
            "Langkah 1 Berhasil 👍",
            "Sekarang miringkan muka lu ke kiri.",
          );
          return;
        } else if (currentStep.value == 2) {
          currentStep.value = 3;
          stepInstruction.value = "Terakhir, Menoleh Sedikit ke KANAN, Beh!";
          isLoading.value = false;
          Get.snackbar(
            "Langkah 2 Berhasil 👍",
            "Terakhir, miringkan muka lu ke kanan.",
          );
          return;
        } else {
          // Jika sudah terkumpul 3 foto (Step 3 Selesai), kirim paket ke FastAPI!
          stepInstruction.value =
              "Sedang mengunci karakteristik wajah seluruh muka lu...";
          await _sendPremiumFaceIdRegister();
        }
      }
      // JIKA MODE LOGIN: Alur jepretan tunggal biasa instan
      else {
        await _executeFaceIdLogin(imageFile);
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Eror", "Gagal menangkap gambar: $e");
    }
  }

  // 🔥 ACTION 1: KIRIM MULTIPLE FILE SEKALIGUS KE API REGISTER PREMIUM
  Future<void> _sendPremiumFaceIdRegister() async {
    try {
      String url =
          "http://$ipBackend/auth/register-face-premium?email=$emailForLogin";
      var request = http.MultipartRequest('POST', Uri.parse(url));

      for (var file in capturedFiles) {
        request.files.add(
          await http.MultipartFile.fromPath('files', file.path),
        );
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      isLoading.value = false;

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
      isLoading.value = false;
      _resetRegisterFlow();
      Get.snackbar("Eror Koneksi", "Gagal menghubungi server: $e");
    }
  }

  // 🔑 ACTION 2: JALUR LOGIN INSTAN BIOMETRIK NYOCOKIN MULTI-ANGLE DATA DI DB
  Future<void> _executeFaceIdLogin(XFile imageFile) async {
    try {
      // 🟢 FIX: Sekarang kepala IP-nya otomatis ikut sinkron ke 10.20.166.45 murni!
      String url = "http://$ipBackend/auth/login-face?email=$emailForLogin";
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      isLoading.value = false;

      if (response.statusCode == 200) {
        // 🟢 PERBAIKAN: Paksa tipe data body menjadi Map murni
        // 🟢 SOLUSI BERSIH: Langsung decode karena Dart sudah tahu ini String JSON mentah
        final dynamic decoded = jsonDecode(response.body);
        final Map<String, dynamic> data = Map<String, dynamic>.from(decoded);

        String internalToken = data['access_token'] ?? data['token'] ?? '';
        var userData = data['user'] ?? data;

        // 🟢 KUNCI DI SINI JUGA, BEH! BIAR PROFIL GAK AMNESIA
        final box = GetStorage();
        await box.write('access_token', internalToken.toString());
        await box.write('token', internalToken.toString());
        await box.write('user_data', userData);
        await box.write('user', userData);

        print("📸 [FACE ID SUCCESS] Sesi berhasil dikunci murni!");

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
      isLoading.value = false;
      Get.snackbar("Eror Jaringan", "Gagal validasi ke server backend: $e");
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
