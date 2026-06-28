import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceDetectorService {
  late FaceDetector _faceDetector;

  void initialize() {
    // Menggunakan opsi deteksi wajah performa tinggi
    final options = FaceDetectorOptions(
      performanceMode: FaceDetectorMode.accurate,
      enableLandmarks: true,
    );
    _faceDetector = FaceDetector(options: options);
  }

  // Fungsi mengubah stream camera frame menjadi format gambar yang dipahami ML Kit
  Future<List<Face>> detectFacesFromImage(
    CameraImage image,
    int sensorOrientation,
  ) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final InputImageMetadata metadata = InputImageMetadata(
      size: imageSize,
      rotation: _getRotation(sensorOrientation),
      format:
          InputImageFormat.nv21, // Umum digunakan di device Android (Realme)
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(bytes: bytes, metadata: metadata);
    return await _faceDetector.processImage(inputImage);
  }

  InputImageRotation _getRotation(int orientation) {
    switch (orientation) {
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  void dispose() {
    _faceDetector.close();
  }
}
