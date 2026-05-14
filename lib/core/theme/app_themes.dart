import 'package:flutter/material.dart';

import '../constants.dart';
import '../responsive/responsive_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

class Appthemes {
  static ThemeData lightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
      useMaterial3: true,
      primaryColor: AppColors.primaryColor,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLightColor,
      fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,

      textTheme: TextTheme(
        titleLarge: AppTextStyle.style18W800,
        titleMedium: AppTextStyle.style16W500,
      ),
      appBarTheme: AppBarTheme(
        iconTheme: const IconThemeData(
          color: AppColors.scaffoldBackgroundLightColor,
        ),
        toolbarHeight: 100.h,
        titleTextStyle: AppTextStyle.style18Bold.copyWith(
          color: AppColors.scaffoldBackgroundLightColor,
          fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
        ),
        backgroundColor: AppColors.primaryColor,
        surfaceTintColor: AppColors.scaffoldBackgroundLightColor,
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
        backgroundColor: AppColors.scaffoldBackgroundLightColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        elevation: 5,
        titleTextStyle: AppTextStyle.style20Bold.copyWith(
          fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
        ),
      ),

      /// ستايل الزر الرئيسي (ElevatedButton)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor:
              AppColors.scaffoldBackgroundLightColor, // لون النص والأيقونة
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          textStyle: AppTextStyle.style12W500.copyWith(
            fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
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
            fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
          ),
        ),
      ),
    );
  }
}
