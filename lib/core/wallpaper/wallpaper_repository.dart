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
      final path = CacheHelper.getData(WallpaperCacheKeys.imagePath) as String?;
      if (path == null || path.isEmpty) {
        return WallpaperSettings.defaultSettings;
      }

      if (path.startsWith('assets/')) {
        return WallpaperSettings(
          type: WallpaperType.image,
          imagePath: path,
        );
      }

      final fileName = path.split('/').last;
      final dir = await getApplicationDocumentsDirectory();
      final actualPath = '${dir.path}/$fileName';

      if (!File(actualPath).existsSync()) {
        return WallpaperSettings.defaultSettings;
      }

      return WallpaperSettings(
        type: WallpaperType.image,
        imagePath: actualPath,
      );
    }

    return WallpaperSettings.defaultSettings;
  }

  Future<void> _deleteStoredImageIfAny() async {
    final path =
        CacheHelper.getData(
              WallpaperCacheKeys.imagePath,
            )
            as String?;

    if (path == null || path.isEmpty) return;
    if (path.startsWith('assets/')) return;

    try {
      final fileName = path.split('/').last;
      final dir = await getApplicationDocumentsDirectory();
      final actualPath = '${dir.path}/$fileName';

      final file = File(actualPath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> save(WallpaperSettings settings) async {
    await CacheHelper.saveData(
      key: WallpaperCacheKeys.type,
      value: settings.type.name,
    );

    if (settings.type == WallpaperType.color && settings.color != null) {
      await _deleteStoredImageIfAny();

      await CacheHelper.saveData(
        key: WallpaperCacheKeys.color,
        value: settings.color!.toARGB32(),
      );

      await CacheHelper.removeData(
        WallpaperCacheKeys.imagePath,
      );

      return;
    }

    if (settings.type == WallpaperType.image && settings.imagePath != null) {
      await CacheHelper.saveData(
        key: WallpaperCacheKeys.imagePath,
        value: settings.imagePath,
      );

      await CacheHelper.removeData(
        WallpaperCacheKeys.color,
      );

      return;
    }
  }

  Future<String> saveImageFromPath(
    String sourcePath,
  ) async {
    await _deleteStoredImageIfAny();

    final dir = await getApplicationDocumentsDirectory();

    final fileName = 'wallpaper_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final destPath = '${dir.path}/$fileName';

    await File(sourcePath).copy(destPath);

    return destPath;
  }

  Future<void> clear() async {
    await _deleteStoredImageIfAny();

    await CacheHelper.saveData(
      key: WallpaperCacheKeys.type,
      value: 'none',
    );

    await CacheHelper.removeData(
      WallpaperCacheKeys.color,
    );

    await CacheHelper.removeData(
      WallpaperCacheKeys.imagePath,
    );
  }
}
