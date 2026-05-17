// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/wallpaper/wallpaper_settings.dart';

class WallpaperCacheKeys {
  static const type = 'wallpaper_type';
  static const color = 'wallpaper_color';
  static const imagePath = 'wallpaper_image_path';
}

class WallpaperRepository {
  Future<WallpaperSettings> load() async {
    final typeRaw = CacheHelper.getData(WallpaperCacheKeys.type) as String?;
    if (typeRaw == null || typeRaw == 'none') {
      return WallpaperSettings.defaultSettings;
    }

    if (typeRaw == 'color') {
      final colorValue = CacheHelper.getData(WallpaperCacheKeys.color) as int?;
      if (colorValue == null) return WallpaperSettings.defaultSettings;
      return WallpaperSettings(
        type: WallpaperType.color,
        color: Color(colorValue),
      );
    }

    if (typeRaw == 'image') {
      final path =
          CacheHelper.getData(WallpaperCacheKeys.imagePath) as String?;
      if (path == null || path.isEmpty || !File(path).existsSync()) {
        return WallpaperSettings.defaultSettings;
      }
      return WallpaperSettings(
        type: WallpaperType.image,
        imagePath: path,
      );
    }

    return WallpaperSettings.defaultSettings;
  }

  Future<void> saveColor(Color color) async {
    await _deleteStoredImageIfAny();
    await CacheHelper.saveData(key: WallpaperCacheKeys.type, value: 'color');
    await CacheHelper.saveData(
      key: WallpaperCacheKeys.color,
      value: color.toARGB32(),
    );
    await CacheHelper.removeData(WallpaperCacheKeys.imagePath);
  }

  Future<String> saveImageFromPath(String sourcePath) async {
    await _deleteStoredImageIfAny();

    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final destPath = '${dir.path}/$fileName';
    await File(sourcePath).copy(destPath);

    await CacheHelper.saveData(key: WallpaperCacheKeys.type, value: 'image');
    await CacheHelper.saveData(
      key: WallpaperCacheKeys.imagePath,
      value: destPath,
    );
    await CacheHelper.removeData(WallpaperCacheKeys.color);

    return destPath;
  }

  Future<void> clear() async {
    await _deleteStoredImageIfAny();
    await CacheHelper.saveData(key: WallpaperCacheKeys.type, value: 'none');
    await CacheHelper.removeData(WallpaperCacheKeys.color);
    await CacheHelper.removeData(WallpaperCacheKeys.imagePath);
  }

  Future<void> _deleteStoredImageIfAny() async {
    final path =
        CacheHelper.getData(WallpaperCacheKeys.imagePath) as String?;
    if (path == null || path.isEmpty) return;
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }
}
