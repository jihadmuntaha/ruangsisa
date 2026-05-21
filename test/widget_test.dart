import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import '../lib/app/modules/main_wrapper/views/main_wrapper_view.dart';
import '../lib/app/modules/main_wrapper/controllers/main_wrapper_controller.dart';
import '../lib/app/modules/home/views/home_view.dart';
import '../lib/app/modules/search/views/search_view.dart';
import '../lib/app/modules/add_post/views/add_post_view.dart';
import '../lib/app/modules/message/views/message_view.dart';
import '../lib/app/modules/profile/views/profile_view.dart';

void main() {
  // Helper fungsi untuk ngebangun shell GetX di dalam testing environment
  Widget createHomeScreen() => GetMaterialApp(
    initialRoute: '/main-wrapper',
    getPages: [
      GetPage(
        name: '/main-wrapper',
        page: () => const MainWrapperView(),
        binding: BindingsBuilder(() {
          Get.lazyPut<MainWrapperController>(() => MainWrapperController());
        }),
      ),
    ],
  );

  testWidgets('RuangSisa Navigation Bar Layout Test', (
    WidgetTester tester,
  ) async {
    // 1. Build aplikasi RuangSisa dan trigger frame pertama
    await tester.pumpWidget(createHomeScreen());

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
    await tester.tap(find.text('Pesan'));
    await tester
        .pumpAndSettle(); // Tunggu animasi transisi IndexedStack selesai

    // 5. Memastikan halaman Inbox Pesan berhasil dirender setelah di-tap
    expect(find.text('Andi Pratama'), findsOneWidget);
    expect(find.text('Siti Aminah'), findsOneWidget);
  });
}
