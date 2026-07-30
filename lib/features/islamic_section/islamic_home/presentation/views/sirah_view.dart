import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';

class SirahView extends StatelessWidget {
  const SirahView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'وَالسَّابِقُونَ الْأَوَّلُونَ',
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
                      title: 'أنبياء الله',
                      icon: Icons.history_edu_rounded,
                      onTap: () async {
                        await context.pushNamed(
                          AppRoutes.anbyaaIndexView,
                        );
                      },
                    ),
                    _IslamicItem(
                      title: 'صور من حياة الرسول',
                      icon: Icons.menu_book_rounded,
                      onTap: () async {
                        // await context.pushNamed(
                        //   AppRoutes.azkarView,
                        //   extra: {
                        //     'title': 'أذكار المساء',
                        //     'azkarType': AzkarType.evening,
                        //   },
                        // );
                      },
                    ),
                    _IslamicItem(
                      title: 'صور من حياة الصحابة',
                      icon: Icons.library_books_rounded,
                      onTap: () async {
                        // await context.pushNamed(
                        //   AppRoutes.azkarView,
                        //   extra: {
                        //     'title': 'أذكار المساء',
                        //     'azkarType': AzkarType.evening,
                        //   },
                        // );
                      },
                    ),
                    _IslamicItem(
                      title: 'صور من حياة الصحابيات',
                      icon: Icons.import_contacts_rounded,
                      onTap: () async {
                        // await context.pushNamed(
                        //   AppRoutes.azkarView,
                        //   extra: {
                        //     'title': 'أذكار المساء',
                        //     'azkarType': AzkarType.evening,
                        //   },
                        // );
                      },
                    ),

                    _IslamicItem(
                      title: 'صور من حياة التابعين',
                      icon: Icons.auto_stories_rounded,
                      onTap: () async {
                        await context.pushNamed(
                          AppRoutes.tabeenIndexView,
                        );
                      },
                    ),
                  ];

                  return SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView.builder(
                          padding: EdgeInsets.all(20.r),
                          itemCount: items.length,

                          itemBuilder: (context, index) {
                            final item = items[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(16.r),
                              onTap: item.onTap,
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                                color: Colors.white.withValues(alpha: .90),
                                child: Padding(
                                  padding: EdgeInsets.all(20.r),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 40.r,
                                        color: AppColors.primaryColor.withAlpha(
                                          200,
                                        ),
                                      ),
                                      16.horizontalSpace,
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
