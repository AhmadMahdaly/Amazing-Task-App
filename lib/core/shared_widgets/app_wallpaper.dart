import 'dart:io';

import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/wallpaper/wallpaper_settings.dart';

/// Paints a WhatsApp-style chat background behind [child].
class AppWallpaper extends StatelessWidget {
  const AppWallpaper({
    required this.settings,
    required this.child,
    super.key,
  });

  final WallpaperSettings settings;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildBackground(),
        child,
      ],
    );
  }

  Widget _buildBackground() {
    switch (settings.type) {
      case WallpaperType.color:
        return ColoredBox(color: settings.color ?? Colors.white);
      case WallpaperType.image:
        final path = settings.imagePath;
        if (path == null || path.isEmpty) {
          return const ColoredBox(
            color: AppColors.scaffoldBackgroundLightColor,
          );
        }
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const ColoredBox(
            color: AppColors.scaffoldBackgroundLightColor,
          ),
        );
      case WallpaperType.none:
        return const ColoredBox(
          color: AppColors.scaffoldBackgroundLightColor,
        );
    }
  }
}
