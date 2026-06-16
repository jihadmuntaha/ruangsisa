import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart'; // ✅ TAMBAHKAN INI
import 'app/routes/app_pages.dart';

void main() async {
  // ✅ TAMBAHKAN 'async'
  WidgetsFlutterBinding.ensureInitialized(); // ✅ TAMBAHKAN INI
  await GetStorage.init(); // ✅ TAMBAHKAN INI - WAJIB!

  runApp(
    GetMaterialApp(
      title: "RuangSisa",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2D6A4F),
        scaffoldBackgroundColor: Colors.white,
      ),
    ),
  );
}
