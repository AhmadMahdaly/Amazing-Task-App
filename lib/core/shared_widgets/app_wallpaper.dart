import 'dart:io';

import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/wallpaper/wallpaper_settings.dart';

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
        return ColoredBox(color: settings.color ?? AppColors.primaryColor);
      case WallpaperType.image:
        final path = settings.imagePath;
        if (path == null || path.isEmpty) {
          return const ColoredBox(
            color: AppColors.primaryColor,
          );
        }
        return Image.file(
          File(path),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const ColoredBox(
            color: AppColors.primaryColor,
          ),
        );
      case WallpaperType.none:
        return const ColoredBox(
          color: AppColors.primaryColor,
        );
    }
  }
}
