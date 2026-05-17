import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/services/photo_permission_helper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/core/wallpaper/wallpaper_settings.dart';

Future<void> showWallpaperPickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: BlocBuilder<WallpaperCubit, WallpaperState>(
          builder: (context, state) {
            final settings = state.settings;

            return Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    AppTexts.wallpaper,
                    style: AppTextStyle.style16W500.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ListTile(
                    leading: const Icon(
                      Icons.photo_library_outlined,
                      color: AppColors.primaryColor,
                    ),
                    title: Text(
                      AppTexts.chooseFromGallery,
                      style: AppTextStyle.style12W300,
                    ),
                    onTap: () async {
                      final cubit = context.read<WallpaperCubit>();
                      final blocked = await cubit.pickImageFromGallery();
                      if (!sheetContext.mounted) return;
                      if (blocked != null) {
                        await PhotoPermissionHelper.showPermissionDialog(
                          sheetContext,
                          blocked,
                        );
                        return;
                      }
                      if (cubit.state.settings.type == WallpaperType.image) {
                        Navigator.pop(sheetContext);
                      }
                    },
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AppTexts.solidColors,
                    style: AppTextStyle.style12W300.copyWith(
                      color: AppColors.secondaryColor.withAlpha(160),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 10.h,
                      crossAxisSpacing: 10.w,
                    ),
                    itemCount: wallpaperPresetColors.length,
                    itemBuilder: (context, index) {
                      final color = wallpaperPresetColors[index];
                      final isSelected =
                          settings.type == WallpaperType.color &&
                          settings.color?.toARGB32() == color.toARGB32();

                      return InkWell(
                        onTap: () async {
                          await context.read<WallpaperCubit>().setColor(color);
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        borderRadius: BorderRadius.circular(12.r),
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryColor
                                  : Colors.black12,
                              width: isSelected ? 3 : 1,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  color: _checkIconColor(color),
                                  size: 22.r,
                                )
                              : null,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  if (settings.hasWallpaper)
                    TextButton.icon(
                      onPressed: () async {
                        await context.read<WallpaperCubit>().reset();
                        if (sheetContext.mounted) {
                          Navigator.pop(sheetContext);
                        }
                      },
                      icon: const Icon(Icons.restore, color: Colors.red),
                      label: Text(
                        AppTexts.resetWallpaper,
                        style: AppTextStyle.style12W300.copyWith(
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}

Color _checkIconColor(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.5 ? AppColors.primaryColor : Colors.white;
}
