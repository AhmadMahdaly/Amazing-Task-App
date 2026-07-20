// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/islamic_section/quran/domain/entities/surah_entity.dart';
import 'package:s/features/islamic_section/quran/presentation/cubit/quran_cubit.dart';

class QuranIndexView extends StatelessWidget {
  const QuranIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'القرآن الكريم',
            style: AppTextStyle.style20W900.copyWith(
              fontFamily: AppFonts.amiri,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.highlight_alt_rounded,
                color: AppColors.buttonColor.withAlpha(150),
                size: 24.r,
              ),
              onPressed: () async {
                await context.pushNamed(AppRoutes.savedAyahsAndNotesView);
              },
            ),
            20.horizontalSpace,
          ],
        ),
        body: BlocBuilder<QuranCubit, QuranState>(
          builder: (context, state) {
            if (state is QuranLoading) {
              return const Center(
                child: LoadingWidget(
                  color: AppColors.primaryColor,
                ),
              );
            }

            if (state is QuranError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is QuranLoaded) {
              final bookmarkedSurahNumber =
                  CacheHelper.getData('bookmarked_surah') as int?;
              final bookmarkedAyah =
                  CacheHelper.getData('bookmarked_ayah') as int?;

              return Column(
                children: [
                  Column(
                    children: [
                      16.verticalSpace,
                      if (bookmarkedSurahNumber != null &&
                          bookmarkedAyah != null)
                        _buildBookmarkCard(
                          context,
                          context.read<QuranCubit>(),
                          state.surahs,
                          bookmarkedSurahNumber,
                          bookmarkedAyah,
                        ),
                      if (state.lastReadSurahNumber != null)
                        _buildContinueReadingCard(
                          context,
                          state.surahs,
                          state.lastReadSurahNumber!,
                        ),
                    ],
                  ),

                  Expanded(
                    child: ListView.separated(
                      itemCount: state.surahs.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: AppColors.thirdColor,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final surah = state.surahs[index];
                        final isLastRead =
                            surah.number == state.lastReadSurahNumber;

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.r,
                            vertical: 4.r,
                          ),
                          leading: Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isLastRead
                                  ? AppColors.primaryColor
                                  : AppColors.primaryColor.withAlpha(20),
                            ),
                            child: Center(
                              child: Text(
                                '${surah.number}',
                                style: AppTextStyle.style14W500.copyWith(
                                  color: isLastRead
                                      ? Colors.white
                                      : AppColors.primaryColor,
                                  fontFamily: AppFonts.amiri,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            surah.name,
                            style: AppTextStyle.style18W900.copyWith(
                              fontFamily: AppFonts.amiri,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            '${surah.revelationType == "Meccan" ? "مكية" : "مدنية"} • آياتها ${surah.numberOfAyahs}',
                            style: AppTextStyle.style12W800.copyWith(
                              color: AppColors.secondaryColor,
                              fontFamily: AppFonts.amiri,
                            ),
                          ),
                          trailing: Text(
                            'ص ${surah.startPage}',
                            style: AppTextStyle.style12W500.copyWith(
                              color: AppColors.secondaryColor,
                              fontFamily: AppFonts.amiri,
                            ),
                          ),
                          onTap: () async {
                            await _navigateToReading(context, surah);
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildContinueReadingCard(
    BuildContext context,
    List<SurahEntity> surahs,
    int lastReadId,
  ) {
    final lastSurah = surahs.firstWhere((s) => s.number == lastReadId);

    return GestureDetector(
      onTap: () => _navigateToReading(context, lastSurah),
      child: Container(
        margin: EdgeInsets.all(16.r),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العودة للقراءة',
                    style: AppTextStyle.style12W500.copyWith(
                      color: AppColors.secondaryColor,
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  8.verticalSpace,
                  Text(
                    'سورة ${lastSurah.name}',
                    style: AppTextStyle.style20W800.copyWith(
                      color: AppColors.primaryColor,
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.menu_book, color: AppColors.primaryColor, size: 40.r),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkCard(
    BuildContext context,
    QuranCubit cubit,
    List<SurahEntity> surahs,
    int surahNumber,
    int ayahNumber,
  ) {
    final bookmarkedSurah = surahs.firstWhere((s) => s.number == surahNumber);

    return GestureDetector(
      onLongPress: () {
        showDialog<void>(
          context: context,
          builder: (context) => Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(
                'حذف العلامة المرجعية',
                style: AppTextStyle.style18W900.copyWith(
                  fontFamily: AppFonts.amiri,
                  color: AppColors.primaryColor,
                ),
              ),
              content: Text(
                'هل أنت متأكد من حذف هذه العلامة المرجعية؟',
                style: AppTextStyle.style14W500.copyWith(
                  fontFamily: AppFonts.amiri,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    CacheHelper.removeData('bookmarked_surah');
                    CacheHelper.removeData('bookmarked_ayah');
                    CacheHelper.removeData('bookmarked_offset');

                    cubit.refreshIndex();

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم حذف العلامة المرجعية')),
                    );
                  },
                  child: Text(
                    'حذف',
                    style: AppTextStyle.style14W500.copyWith(
                      color: AppColors.errorColor,
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'إلغاء',
                    style: AppTextStyle.style14W500.copyWith(
                      color: Colors.grey,
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onTap: () async {
        await CacheHelper.saveData(key: 'is_from_bookmark', value: true);
        if (context.mounted) {
          await _navigateToReading(context, bookmarkedSurah);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withAlpha(20),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'العلامة المرجعية:',
                  style: AppTextStyle.style14W300.copyWith(
                    color: AppColors.secondaryColor,
                    fontFamily: AppFonts.amiri,
                  ),
                ),
                4.horizontalSpace,
                Text(
                  'سورة ${bookmarkedSurah.name}',
                  style: AppTextStyle.style16W500.copyWith(
                    color: AppColors.primaryColor,
                    fontFamily: AppFonts.amiri,
                  ),
                ),
                Text(
                  ' - آية رقم: $ayahNumber',
                  style: AppTextStyle.style16W500.copyWith(
                    color: AppColors.primaryColor,
                    fontFamily: AppFonts.amiri,
                  ),
                ),
              ],
            ),

            Icon(Icons.bookmark, color: AppColors.primaryColor, size: 24.r),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToReading(
    BuildContext context,
    SurahEntity surah,
  ) async {
    await context.pushNamed(
      AppRoutes.surahReadingView,
      extra: surah,
    );
  }
}
