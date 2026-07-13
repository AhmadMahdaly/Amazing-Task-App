import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/islamic_section/islamic_home/presentation/controllers/cubit/azkar_cubit.dart';

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
                'إن الدين عند الله الإسلام',
                style: AppTextStyle.style16Bold.copyWith(
                  fontFamily: kPrimaryArFont,
                ),
              ),
              backgroundColor: AppColors.primaryColor,
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
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
                      onTap: () {
                        // انتقل لصفحة القرآن الكريم
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
                        } else if (constraints.maxWidth >= 600) {
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
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1,
                              ),
                          itemBuilder: (context, index) {
                            final item = items[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: item.onTap,
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                color: Colors.white.withValues(alpha: .92),
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        item.icon,
                                        size: 50,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        item.title,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyle.style18Bold
                                            .copyWith(
                                              fontFamily: kPrimaryArFont,
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
