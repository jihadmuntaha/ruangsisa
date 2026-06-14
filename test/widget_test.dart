import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// 🛠️ PERBAIKAN: Jalur import diselaraskan langsung ke folder app/ tanpa embel-embel '../lib/'
import '../lib/app/modules/main_wrapper/views/main_wrapper_view.dart';
import '../lib/app/modules/main_wrapper/controllers/main_wrapper_controller.dart';

void main() {
  // Helper fungsi untuk ngebangun shell GetX di dalam testing environment
  Widget createHomeScreen() => GetMaterialApp(
    initialRoute: '/main-wrapper',
    getPages: [
      GetPage(
        name: '/main-wrapper',
        page: () => const MainWrapperView(),
        binding: BindingsBuilder(() {
          // Inisialisasi controller utama navigasi navbar
          Get.lazyPut<MainWrapperController>(() => MainWrapperController());

          // 🛠️ PERBAIKAN: Daftarkan mock/lazyPut controller anak di sini jika view anak kamu
          // (Home, Message, dll) membutuhkan controller-nya masing-masing agar tidak crash saat di-pump.
          // Contoh:
          // Get.lazyPut<HomeController>(() => HomeController());
          // Get.lazyPut<MessageController>(() => MessageController());
        }),
      ),
    ],
  );

  // Ritual membersihkan dependency GetX setiap kali satu skenario test selesai
  tearDown(() {
    Get.reset();
  });

  testWidgets('RuangSisa Navigation Bar Layout Test', (
    WidgetTester tester,
  ) async {
    // 1. Build aplikasi RuangSisa dan trigger frame pertama
    await tester.pumpWidget(createHomeScreen());
    await tester.pump(); // Trigger inisialisasi awal controller

    // 2. Memastikan komponen identitas brand RuangSisa muncul di Beranda pertama kali
    expect(find.text('RuangSisa'), findsOneWidget);
    expect(find.byIcon(Icons.eco), findsOneWidget);

    // 3. Memastikan ke-5 menu navigasi bawah (Bottom Nav Bar) merender teks yang benar
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Eksplor'), findsOneWidget);
    expect(find.text('Post Baru'), findsOneWidget);
    expect(find.text('Pesan'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // 4. Simulasi interaksi tap: Coba klik menu 'Pesan' di navbar bawah
    // Menggunakan find.text kadang bisa rancu jika teks 'Pesan' ada di navbar dan di judul halaman.
    // Kita targetkan secara spesifik ke widget teksnya.
    await tester.tap(find.text('Pesan').last);

    // Tunggu animasi transisi atau pembaruan state reaktif GetX selesai sepenuhnya
    await tester.pumpAndSettle();

    // 5. Memastikan halaman Inbox Pesan berhasil dirender setelah di-tap
    expect(find.text('Andi Pratama'), findsOneWidget);
    expect(find.text('Siti Aminah'), findsOneWidget);
  });
}
