import 'package:flutter/material.dart';

enum WallpaperType { none, color, image }

class WallpaperSettings {
  const WallpaperSettings({
    this.type = WallpaperType.none,
    this.color,
    this.imagePath,
  });

  final WallpaperType type;
  final Color? color;
  final String? imagePath;

  static const WallpaperSettings defaultSettings = WallpaperSettings();

  bool get hasWallpaper => type != WallpaperType.none;

  WallpaperSettings copyWith({
    WallpaperType? type,
    Color? color,
    String? imagePath,
    bool clearColor = false,
    bool clearImagePath = false,
  }) {
    return WallpaperSettings(
      type: type ?? this.type,
      color: clearColor ? null : (color ?? this.color),
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
    );
  }
}

const List<Color> wallpaperPresetColors = [
  Color(0xFFECE5DD),
  Color(0xFFD0E9F5),
  Color(0xFFE8F5E9),
  Color(0xFFFFF9C4),
  Color(0xFFF3E5F5),
  Color(0xFFFFE0B2),
  Color(0xFFE1BEE7),
  Color(0xFFB2DFDB),
  Color(0xFFFFCDD2),
  Color(0xFFC5CAE9),
  Color(0xFFDCEDC8),
  Color(0xFF263238),
  Color(0xFF37474F),
  Color(0xFF1B5E20),
];
