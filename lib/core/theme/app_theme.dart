import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF2D6A4F);
  static const secondaryColor = Color(0xFF0F5238);
  static const backgroundColor = Color(0xFFF8F9FA);

  static final themeData = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(),
  );
}