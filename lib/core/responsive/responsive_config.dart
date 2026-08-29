// ignore_for_file: unused_field

import 'package:flutter/material.dart';

enum DeviceType {
  phone,
  tablet,
  desktop,
}

/// Design reference sizes
const Size phoneDesignSize = Size(402, 874);
const Size tabletDesignSize = Size(1668, 2388);

abstract class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double _safeBlockHorizontal;
  static late double _safeBlockVertical;
  static late DeviceType deviceType;
  static bool get isPhone => deviceType == DeviceType.phone;
  static bool get isTablet => deviceType == DeviceType.tablet;
  static bool get isDesktop => deviceType == DeviceType.desktop;

  static T responsiveValue<T>({required T phone, T? tablet, T? desktop}) {
    switch (deviceType) {
      case DeviceType.phone:
        return phone;

      case DeviceType.tablet:
        return tablet ?? desktop ?? phone;

      case DeviceType.desktop:
        return desktop ?? tablet ?? phone;
    }
  }

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    deviceType = _getDeviceType(screenWidth);

    final horizontalPadding =
        _mediaQueryData.padding.left + _mediaQueryData.padding.right;

    final verticalPadding =
        _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    _safeBlockHorizontal = screenWidth - horizontalPadding;
    _safeBlockVertical = screenHeight - verticalPadding;
  }

  static DeviceType _getDeviceType(double width) {
    if (width < 600) {
      return DeviceType.phone;
    }

    if (width < 999) {
      return DeviceType.tablet;
    }

    return DeviceType.desktop;
  }

  static double getWidth(double width) {
    switch (deviceType) {
      case DeviceType.phone:
        return screenWidth * (width / phoneDesignSize.width);

      case DeviceType.tablet:
        return screenWidth * (width / tabletDesignSize.width);

      case DeviceType.desktop:
        return _desktopWidth(width);
    }
  }

  static double getHeight(double height) {
    switch (deviceType) {
      case DeviceType.phone:
        return screenHeight * (height / phoneDesignSize.height);

      case DeviceType.tablet:
        return screenHeight * (height / tabletDesignSize.height);

      case DeviceType.desktop:
        return _desktopHeight(height);
    }
  }

  static double _desktopWidth(double width) {
    final scale = screenWidth / 1440;

    return (width * scale).clamp(
      width * 0.85,
      width * 1.35,
    );
  }

  static double _desktopHeight(double height) {
    final scale = screenHeight / 900;

    return (height * scale).clamp(
      height * 0.85,
      height * 1.35,
    );
  }

  static double getFontSize(double size) {
    switch (deviceType) {
      case DeviceType.phone:
        final scale = _safeBlockHorizontal / 100;

        return (size * scale).clamp(
          size * 0.85,
          size * 1.15,
        );

      case DeviceType.tablet:
        final scale = _safeBlockHorizontal / 100;

        return (size * 1.3 * scale).clamp(
          size * 1.1,
          size * 1.5,
        );

      case DeviceType.desktop:
        final scale = screenWidth / 1440;

        return (size * scale).clamp(
          size * 0.9,
          size * 1.25,
        );
    }
  }

  static double getRadius(double radius) {
    switch (deviceType) {
      case DeviceType.phone:
      case DeviceType.tablet:
        return getWidth(radius);

      case DeviceType.desktop:
        final scale = screenWidth / 1440;

        return (radius * scale).clamp(
          radius * 0.9,
          radius * 1.25,
        );
    }
  }
}

extension ResponsiveSized on num {
  double get w => SizeConfig.getWidth(toDouble());
  double get h => SizeConfig.getHeight(toDouble());
  double get r => SizeConfig.getRadius(toDouble());
  double get sp => SizeConfig.getFontSize(toDouble());
  SizedBox get verticalSpace => SizedBox(height: h);
  SizedBox get horizontalSpace => SizedBox(width: w);
}

/// =>
/// 100.w
/// 50.h
/// 16.sp
/// hSpace و wSpace
