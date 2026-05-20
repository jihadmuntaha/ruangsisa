import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(
    GetMaterialApp(
      title: "RuangSisa",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: AppTheme.themeData,
      debugShowCheckedModeBanner: false,
    ),
  );
}
