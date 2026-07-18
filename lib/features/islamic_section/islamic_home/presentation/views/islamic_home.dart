import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/islamic_section/azkar/presentation/controllers/cubit/azkar_cubit.dart';

class IslamicHomeView extends StatelessWidget {
  const IslamicHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'فَقُلْ أَسْلَمْتُ وَجْهِيَ لِلَّهِ',
                style: AppTextStyle.style20W900.copyWith(
                  fontFamily: AppFonts.amiri,
                ),
              ),
              backgroundColor: AppColors.primaryColor,
              centerTitle: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: Platform.isWindows
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => context.pop(),
                    ),
            ),
            resizeToAvoidBottomInset: false,
            backgroundColor: wallpaperState.settings.hasWallpaper
                ? Colors.transparent
                : AppColors.primaryColor,

            body: AppWallpaper(
              settings: wallpaperState.settings,
              child: Builder(
                builder: (context) {
                  final items = [
                    _IslamicItem(
                      title: 'أذكار الصباح',
                      icon: Icons.wb_sunny_outlined,
                      onTap: () async {
                        await context.pushNamed(
                          AppRoutes.azkarView,
                          extra: {
                            'title': 'أذكار الصباح',
                            'azkarType': AzkarType.morning,
                          },
                        );
                      },
                    ),
                    _IslamicItem(
                      title: 'أذكار المساء',
                      icon: Icons.nightlight_round,
                      onTap: () async {
                        await context.pushNamed(
                          AppRoutes.azkarView,
                          extra: {
                            'title': 'أذكار المساء',
                            'azkarType': AzkarType.evening,
                          },
                        );
                      },
                    ),
                    _IslamicItem(
                      title: 'أذكار النوم',
                      icon: Icons.bed_outlined,
                      onTap: () async {
                        await context.pushNamed(
                          AppRoutes.azkarView,
                          extra: {
                            'title': 'أذكار النوم',
                            'azkarType': AzkarType.sleeping,
                          },
                        );
                      },
                    ),
                    _IslamicItem(
                      title: 'القرآن الكريم',
                      icon: Icons.menu_book_rounded,
                      onTap: () async {
                        await context.pushNamed(AppRoutes.quranIndexView);
                      },
                    ),
                    _IslamicItem(
                      title: 'أسماء الله الحسنى',
                      icon: Icons.all_inclusive_rounded,
                      onTap: () async {
                        await context.pushNamed(AppRoutes.asmaaIndexView);
                      },
                    ),
                    _IslamicItem(
                      title: 'حصن المسلم',
                      icon: Icons.auto_stories_rounded,
                      onTap: () async {
                        await context.pushNamed(AppRoutes.hisnIndexView);
                      },
                    ),
                    _IslamicItem(
                      title: 'السنن',
                      icon: Icons.mosque_rounded,
                      onTap: () async {
                        await context.pushNamed(AppRoutes.sunanView);
                      },
                    ),
                    _IslamicItem(
                      title: 'حسبة الصلوات الفائتة',
                      icon: Icons.calculate_outlined,
                      onTap: () async {
                        await context.pushNamed(AppRoutes.missedPrayersScreen);
                      },
                    ),
                  ];

                  return SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount;

                        if (constraints.maxWidth >= 900) {
                          crossAxisCount = 4;
                        } else if (SizeConfig.isTablet) {
                          crossAxisCount = 3;
                        } else {
                          crossAxisCount = 2;
                        }

                        return GridView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: items.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(20.r),
                              onTap: item.onTap,
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                color: Colors.white.withValues(alpha: .92),
                                child: Padding(
                                  padding: EdgeInsets.all(20.r),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 40.r,
                                        color: AppColors.primaryColor.withAlpha(
                                          200,
                                        ),
                                      ),
                                      16.verticalSpace,
                                      Text(
                                        item.title,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyle.style18W900
                                            .copyWith(
                                              fontFamily: AppFonts.amiri,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IslamicItem {
  const _IslamicItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;
}
