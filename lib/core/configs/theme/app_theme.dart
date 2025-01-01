import 'package:blog/core/configs/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AppTheme {
  static final lightTheme = ThemeData(
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
