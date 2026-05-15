part of 'wallpaper_cubit.dart';

class WallpaperState {
  const WallpaperState({this.settings = WallpaperSettings.defaultSettings});

  final WallpaperSettings settings;

  WallpaperState copyWith({WallpaperSettings? settings}) {
    return WallpaperState(settings: settings ?? this.settings);
  }
}
