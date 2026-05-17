import 'package:flutter/material.dart';

import '../constants.dart';
import '../responsive/responsive_config.dart';
import 'app_colors.dart';
import 'app_text_style.dart';

class Appthemes {
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
      useMaterial3: true,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.white,
      fontFamily: kPrimaryEnFont,

      textTheme: TextTheme(
        titleLarge: AppTextStyle.style18W800,
        titleMedium: AppTextStyle.style16W500,
      ),
      appBarTheme: AppBarTheme(
        iconTheme: const IconThemeData(
          color: AppColors.white,
        ),
        toolbarHeight: 100.h,
        titleTextStyle: AppTextStyle.style18Bold.copyWith(
          color: AppColors.white,
          fontFamily: kPrimaryEnFont,
        ),
        backgroundColor: AppColors.primaryColor,
        surfaceTintColor: AppColors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.r)),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,

      /// Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 5,
        titleTextStyle: AppTextStyle.style20Bold.copyWith(
          fontFamily: kPrimaryEnFont,
        ),
      ),

      /// ستايل الزر الرئيسي (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white, // لون النص والأيقونة
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          textStyle: AppTextStyle.style12W500.copyWith(
            fontFamily: kPrimaryEnFont,
          ),
        ),
      ),

      /// ستايل الزر الثانوي (TextButton)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          textStyle: AppTextStyle.style14W500.copyWith(
            fontFamily: kPrimaryEnFont,
          ),
        ),
      ),
    );
  }
}
