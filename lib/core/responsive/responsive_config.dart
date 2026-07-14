import 'package:flutter/material.dart';

///=> Design screen size:
final Size deviceSize = Size(
  SizeConfig.isTablet ? 1668 : 402,
  SizeConfig.isTablet ? 2388 : 874,
);
// const Size deviceSize = Size(390, 844);

enum DeviceType { phone, tablet, desktop }

abstract class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late DeviceType deviceType;
  static T responsiveValue<T>({required T phone, required T tablet}) {
    return isTablet ? tablet : phone;
  }

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    if (screenWidth >= 1100) {
      deviceType = DeviceType.desktop;
    } else if (screenWidth >= 600) {
      deviceType = DeviceType.tablet;
    } else {
      deviceType = DeviceType.phone;
    }
  }

  static bool get isDesktop => deviceType == DeviceType.desktop;
  static bool get isTablet => deviceType == DeviceType.tablet;
  static bool get isPhone => deviceType == DeviceType.phone;

  /// عرض العناصر
  static double w(double value) {
    if (isDesktop) return value; // ثابت
    return screenWidth * (value / deviceSize.width);
  }

  /// ارتفاع العناصر
  static double h(double value) {
    if (isDesktop) return value;
    return screenHeight * (value / deviceSize.height);
  }

  /// الخط
  static double sp(double size) {
    if (isDesktop) return size; // ثابت
    return size * (screenWidth / deviceSize.width);
  }

  /// نصف القطر
  static double r(double radius) {
    return isDesktop ? radius : w(radius);
  }
}

extension ResponsiveSized on num {
  double get w => SizeConfig.w(toDouble());
  double get h => SizeConfig.h(toDouble());
  double get sp => SizeConfig.sp(toDouble());
  double get r => SizeConfig.r(toDouble());

  SizedBox get verticalSpace => SizedBox(height: h);
  SizedBox get horizontalSpace => SizedBox(width: w);
}

/// --->
/// 100.w
/// 50.h
/// 16.sp
/// verticalSpace و horizontalSpace
