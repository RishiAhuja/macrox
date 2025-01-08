import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AppTheme {
  static InputDecorationTheme inputDecorationTheme(bool isDark) {
    return InputDecorationTheme(
      alignLabelWithHint: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      focusColor: AppColors.primaryLight,
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(color: AppColors.primaryLight, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        borderSide: BorderSide(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1.0,
        ),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
      hintStyle: GoogleFonts.robotoMono(),
      floatingLabelStyle: GoogleFonts.robotoMono(color: AppColors.primaryLight),
      labelStyle: GoogleFonts.robotoMono(),
      filled: false,
      fillColor: Colors.transparent,
    );
  }

  static final lightTheme = ThemeData(
      inputDecorationTheme: inputDecorationTheme(false),
      colorScheme: const ColorScheme.light(
          primary: AppColors.primaryLight,
          secondary: AppColors.primaryDark,
          onPrimary: Colors.black,
          onSecondary: Colors.white),
      brightness: Brightness.light,
      primaryColor: AppColors.primaryLight,
      scaffoldBackgroundColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.robotoMono(
                color: Colors.black,
                fontSize: 20.sp,
              ))));

  static final darkTheme = ThemeData(
      inputDecorationTheme: inputDecorationTheme(true),
      primaryColor: AppColors.primaryDark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      brightness: Brightness.dark,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.robotoMono(
                color: Colors.white,
                fontSize: 20.sp,
              ))));
}
