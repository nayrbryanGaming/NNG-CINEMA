import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movies_app/core/resources/app_colors.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    // Main Colors
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.primaryBackground,
    canvasColor: AppColors.secondaryBackground, // For dropdowns, etc.

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: _getTextStyle(fontSize: 18, color: AppColors.primaryText),
      iconTheme: const IconThemeData(color: AppColors.primaryText),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.secondaryBackground,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.tertiaryText,
      type: BottomNavigationBarType.fixed,
    ),

    // Text Theme
    textTheme: TextTheme(
      headlineSmall: _getTextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryText),
      titleLarge: _getTextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.primaryText),
      titleMedium: _getTextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.secondaryText),
      titleSmall: _getTextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.secondaryText),
      bodyLarge: _getTextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.primaryText),
      bodyMedium: _getTextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.tertiaryText),
      bodySmall: _getTextStyle(fontSize: 10, fontWeight: FontWeight.w400, color: AppColors.tertiaryText),
    ),

    // Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.primaryText,
        textStyle: _getTextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.secondaryBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Input Decoration Theme (for TextFormFields)
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: AppColors.tertiaryText),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.tertiaryText),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

TextStyle _getTextStyle({
  required double fontSize,
  FontWeight fontWeight = FontWeight.normal,
  required Color color,
}) {
  return GoogleFonts.poppins(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}
