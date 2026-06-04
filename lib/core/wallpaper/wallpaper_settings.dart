import 'package:flutter/material.dart';

enum WallpaperType { none, color, image }

class WallpaperSettings {
  const WallpaperSettings({
    this.type = WallpaperType.image,
    this.color,
    this.imagePath = defaultWallpaper,
  });

  final WallpaperType type;
  final Color? color;
  final String? imagePath;

  static const String defaultWallpaper =
      'assets/images/wallpapers/wellpaper1.jpeg';

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
  Color(0xFFE1BEE7),
  Color(0xFFB2DFDB),
  Color(0xFFFFCDD2),
  Color(0xFFC5CAE9),
  Color(0xFF263238),
  Color(0xFF37474F),
  Color(0xFF1B5E20),
];

const List<String> wallpaperPresetImages = [
  'assets/images/wallpapers/wellpaper1.jpeg',
  'assets/images/wallpapers/wellpaper3.jpeg',
  'assets/images/wallpapers/wellpaper4.jpeg',
  'assets/images/wallpapers/wellpaper2.jpeg',
  'assets/images/wallpapers/wellpaper5.jpeg',
  'assets/images/wallpapers/wellpaper6.jpeg',
];
