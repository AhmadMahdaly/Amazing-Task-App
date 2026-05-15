import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:s/core/services/photo_permission_helper.dart';
import 'package:s/core/wallpaper/wallpaper_repository.dart';
import 'package:s/core/wallpaper/wallpaper_settings.dart';

part 'wallpaper_state.dart';

class WallpaperCubit extends Cubit<WallpaperState> {
  WallpaperCubit(this._repository) : super(const WallpaperState());

  final WallpaperRepository _repository;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> load() async {
    final settings = await _repository.load();
    emit(state.copyWith(settings: settings));
  }

  Future<void> setColor(Color color) async {
    await _repository.saveColor(color);
    emit(
      state.copyWith(
        settings: WallpaperSettings(
          type: WallpaperType.color,
          color: color,
        ),
      ),
    );
  }

  Future<PhotoPermissionResult?> pickImageFromGallery() async {
    final blocked = await PhotoPermissionHelper.ensureGalleryAccessIfNeeded();
    if (blocked != null) {
      return blocked;
    }

    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (picked == null) return null;

    final path = await _repository.saveImageFromPath(picked.path);
    emit(
      state.copyWith(
        settings: WallpaperSettings(
          type: WallpaperType.image,
          imagePath: path,
        ),
      ),
    );
    return null;
  }

  Future<void> reset() async {
    await _repository.clear();
    emit(state.copyWith(settings: WallpaperSettings.defaultSettings));
  }
}
