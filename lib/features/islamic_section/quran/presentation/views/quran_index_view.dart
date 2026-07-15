import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
              return Column(
                children: [
                  if (state.lastReadSurahNumber != null)
                    _buildContinueReadingCard(
                      context,
                      state.surahs,
                      state.lastReadSurahNumber!,
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
