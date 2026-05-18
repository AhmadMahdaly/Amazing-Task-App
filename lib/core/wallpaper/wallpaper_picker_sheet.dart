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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    24.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: Icon(Icons.close, size: 18.r),
                        ),

                        Text(
                          AppTexts.wallpaper,
                          style: AppTextStyle.style16Bold.copyWith(),
                          textAlign: TextAlign.center,
                        ),
                        40.horizontalSpace,
                      ],
                    ),

                    20.verticalSpace,

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

                    20.verticalSpace,

                    Text(
                      AppTexts.wallpaperImages,
                      style: AppTextStyle.style12W600.copyWith(
                        color: AppColors.secondaryColor.withAlpha(160),
                      ),
                    ),

                    12.verticalSpace,

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: wallpaperPresetImages.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: .65,
                      ),
                      itemBuilder: (context, index) {
                        final image = wallpaperPresetImages[index];

                        final isSelected =
                            settings.type == WallpaperType.image &&
                            settings.imagePath == image;

                        return InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () async {
                            await context.read<WallpaperCubit>().setAssetImage(
                              image,
                            );

                            if (sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primaryColor
                                    : Colors.black12,
                                width: isSelected ? 3 : 1,
                              ),
                            ),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    14.r,
                                  ),
                                  child: Image.asset(
                                    image,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                ),

                                if (isSelected)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: EdgeInsets.all(4.r),
                                      decoration: const BoxDecoration(
                                        color: AppColors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check,
                                        size: 18.r,
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: 20.h),

                    Text(
                      AppTexts.solidColors,
                      style: AppTextStyle.style12W300.copyWith(
                        color: AppColors.secondaryColor.withAlpha(160),
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    12.verticalSpace,

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
                            await context.read<WallpaperCubit>().setColor(
                              color,
                            );

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

                    20.verticalSpace,

                    if (settings.hasWallpaper)
                      TextButton.icon(
                        onPressed: () async {
                          await context.read<WallpaperCubit>().reset();

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        },
                        icon: const Icon(
                          Icons.restore,
                          color: Colors.red,
                        ),
                        label: Text(
                          AppTexts.resetWallpaper,
                          style: AppTextStyle.style12W300.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
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
