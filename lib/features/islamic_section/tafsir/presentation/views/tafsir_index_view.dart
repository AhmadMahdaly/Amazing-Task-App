import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/islamic_section/quran/domain/entities/surah_entity.dart';
import 'package:s/features/islamic_section/quran/presentation/controllers/quran_cubit/quran_cubit.dart';
import 'package:s/features/islamic_section/tafsir/presentation/cubit/tafsir_cubit.dart';

class TafsirIndexView extends StatelessWidget {
  const TafsirIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70.h,
          title: Text(
            'التفسير الميسر',
            style: AppTextStyle.style20Bold.copyWith(
              color: AppColors.white,
              fontFamily: AppFonts.amiri,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),

          backgroundColor: AppColors.primaryColor,
          elevation: 0,
        ),
        body: BlocBuilder<QuranCubit, QuranState>(
          builder: (context, quranState) {
            if (quranState is QuranLoading) {
              return const Center(
                child: LoadingWidget(color: AppColors.primaryColor),
              );
            }

            if (quranState is QuranError) {
              return Center(
                child: Text(
                  quranState.message,
                  style: AppTextStyle.style12W500.copyWith(
                    color: AppColors.errorColor,
                  ),
                ),
              );
            }

            if (quranState is QuranLoaded) {
              return BlocBuilder<TafsirCubit, TafsirState>(
                builder: (context, tafsirState) {
                  if (tafsirState is TafsirLoading) {
                    return const Center(
                      child: LoadingWidget(color: AppColors.primaryColor),
                    );
                  }

                  if (tafsirState is TafsirLoaded) {
                    final lastReadTafsirId = tafsirState.lastReadSurahNumber;
                    return Column(
                      children: [
                        if (lastReadTafsirId != null)
                          _buildContinueReadingCard(
                            context,
                            quranState.surahs,
                            lastReadTafsirId,
                          ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: quranState.surahs.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: AppColors.thirdColor,
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final surah = quranState.surahs[index];
                              final isLastRead =
                                  surah.number ==
                                  tafsirState.lastReadSurahNumber;
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
                                trailing: Icon(
                                  Icons.menu_book_rounded,
                                  color: AppColors.secondaryColor,
                                  size: 20.r,
                                ),
                                onTap: () async {
                                  await context.pushNamed(
                                    AppRoutes.tafsirReadingView,
                                    extra: surah,
                                  );
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
    final surahIndex = surahs.indexWhere((s) => s.number == lastReadId);
    if (surahIndex == -1) return const SizedBox.shrink();

    final lastSurah = surahs[surahIndex];

    return GestureDetector(
      onTap: () async {
        await _navigateToReading(context, lastSurah);
      },
      child: Container(
        margin: EdgeInsets.all(16.r),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.buttonColor,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
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
                    'متابعة قراءة التفسير',
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
            Icon(
              Icons.bookmark_added_rounded,
              color: AppColors.primaryColor,
              size: 40.r,
            ),
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
      AppRoutes.tafsirReadingView,
      extra: surah,
    );
  }
}
