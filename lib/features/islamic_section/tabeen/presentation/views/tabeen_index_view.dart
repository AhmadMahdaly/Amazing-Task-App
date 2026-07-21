import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/islamic_section/notes/presentation/utils/notes_section_type.dart';
import 'package:s/features/islamic_section/tabeen/domain/entities/tabeen.dart';

import '../cubit/tabeen_cubit.dart';

class TabeenIndexView extends StatelessWidget {
  const TabeenIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'صور من حياة التابعين',
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
                await context.pushNamed(
                  AppRoutes.unifiedNotesView,
                  extra: NotesSectionType.arbaoon,
                );
              },
            ),
            IconButton(
              icon: Icon(
                Icons.info_outline_rounded,
                color: AppColors.buttonColor.withAlpha(150),
                size: 24.r,
              ),
              tooltip: 'عن الكتاب',
              onPressed: () => _showBookIntroduction(context),
            ),
            20.horizontalSpace,
          ],
        ),
        body: BlocBuilder<TabeenCubit, TabeenState>(
          builder: (context, state) {
            if (state is TabeenLoading) {
              return const LoadingWidget();
            }

            if (state is TabeenError) {
              return Center(
                child: Text(
                  state.message,
                  style: AppTextStyle.style14W500.copyWith(
                    color: AppColors.errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (state is! TabeenLoaded) {
              return Center(
                child: Text(
                  'لا توجد بيانات',
                  style: AppTextStyle.style14W500.copyWith(
                    color: AppColors.errorColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              children: [
                if (state.lastReadTabeen != null)
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: _ContinueReadingCard(
                      hadith: state.lastReadTabeen!,
                    ),
                  ),

                // 20.verticalSpace,
                // Text(
                //   'الأحاديث (${state.hadiths.length})',
                //   style: AppTextStyle.style20W900.copyWith(
                //     fontFamily: AppFonts.amiri,
                //   ),
                // ),
                // 12.verticalSpace,
                Expanded(
                  child: ListView.separated(
                    itemCount: state.tabeen.length,
                    separatorBuilder: (context, index) => Divider(
                      color: AppColors.thirdColor.withAlpha(50),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final hadith = state.tabeen[index];

                      final isLastRead = hadith.id == state.lastReadTabeen?.id;

                      return _TabeenTile(
                        hadith: hadith,
                        isLastRead: isLastRead,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showBookIntroduction(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: .75,
          minChildSize: .5,
          maxChildSize: .95,
          builder: (context, controller) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(height: 12.r),

                    Container(
                      width: 50.r,
                      height: 5.r,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.all(20.r),
                      child: Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: AppColors.primaryColor,
                            size: 28.r,
                          ),
                          10.horizontalSpace,
                          Expanded(
                            child: Text(
                              'عن صور من حياة التابعين',
                              style: AppTextStyle.style20W900.copyWith(
                                fontFamily: AppFonts.amiri,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: ListView(
                        controller: controller,
                        padding: EdgeInsets.symmetric(horizontal: 20.r),
                        children: [
                          Text(
                            '''
يُعد كتاب «صور من حياة التابعين» للأديب والمؤرخ الإسلامي عبد الرحمن رأفت الباشا من أبرز الكتب التي تناولت سير التابعين بأسلوب أدبي مؤثر، حيث يعرض نماذج مشرقة من حياة الجيل الذي تربى على أيدي صحابة رسول الله ﷺ، ونهل من علمهم وأخلاقهم.

يأخذك الكتاب في رحلة مع رجال ونساء عُرفوا بالإيمان، والعلم، والزهد، والصبر، والورع، والإخلاص، ليُبرز كيف أثمرت تربية الصحابة جيلًا حمل رسالة الإسلام ونشرها في الآفاق.

وفي هذا القسم ستتعرف على مواقف وقصص واقعية من حياة التابعين، تستلهم منها معاني الثبات، وحسن الخلق، والاجتهاد في الطاعة، لتكون هذه السير مصدرًا للعبرة، ودافعًا للاقتداء بالصالحين والسير على نهجهم.
''',
                            textAlign: TextAlign.justify,
                            style: AppTextStyle.style18W800.copyWith(
                              fontFamily: AppFonts.amiri,
                              color: AppColors.primaryColor,
                              height: 2,
                            ),
                          ),

                          SizedBox(height: 24.r),

                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor.withAlpha(15),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.lightbulb_outline_rounded,
                                  color: AppColors.primaryColor,
                                ),
                                12.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    'اقرأ هذه السير بقلبٍ متأمل، فليست مجرد أحداث تاريخية، بل نماذج عملية تُعين على تزكية النفس، وتقوي العزيمة، وتغرس حب الصالحين والاقتداء بهم.',
                                    style: AppTextStyle.style16W500.copyWith(
                                      fontFamily: AppFonts.amiri,
                                      color: AppColors.primaryColor,
                                      height: 1.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20.r),

                          Container(
                            padding: EdgeInsets.all(18.r),
                            decoration: BoxDecoration(
                              color: AppColors.buttonColor,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: AppColors.primaryColor.withAlpha(40),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.format_quote_rounded,
                                  color: AppColors.primaryColor,
                                  size: 30.r,
                                ),
                                SizedBox(height: 12.r),
                                Text(
                                  '﴿وَالسَّابِقُونَ الْأَوَّلُونَ مِنَ الْمُهَاجِرِينَ وَالْأَنصَارِ وَالَّذِينَ اتَّبَعُوهُم بِإِحْسَانٍ رَّضِيَ اللَّهُ عَنْهُمْ وَرَضُوا عَنْهُ﴾',
                                  textAlign: TextAlign.center,
                                  style: AppTextStyle.style18W900.copyWith(
                                    fontFamily: AppFonts.amiri,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 8.r),
                                Text(
                                  '[التوبة: 100]',
                                  style: AppTextStyle.style14W500.copyWith(
                                    fontFamily: AppFonts.amiri,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 30.r),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ContinueReadingCard extends StatelessWidget {
  const _ContinueReadingCard({
    required this.hadith,
  });

  final Tabeen hadith;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () async {
        await context.pushNamed(
          AppRoutes.arbaoonReadingView,
          extra: hadith,
        );
      },
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: .08),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'العودة للقراءة',
                    style: AppTextStyle.style14W500.copyWith(
                      fontFamily: AppFonts.amiri,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  6.verticalSpace,
                  Text(
                    hadith.title,
                    style: AppTextStyle.style20W900.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  // 4.verticalSpace,
                  // Text(
                  //   hadith.preview,
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  //   style: AppTextStyle.style14W600.copyWith(
                  //     fontFamily: AppFonts.amiri,
                  //   ),
                  // ),
                ],
              ),
            ),
            Icon(Icons.menu_book, color: AppColors.primaryColor, size: 40.r),
            // 16.horizontalSpace,
          ],
        ),
      ),
    );
  }
}

class _TabeenTile extends StatelessWidget {
  const _TabeenTile({
    required this.isLastRead,
    required this.hadith,
  });

  final Tabeen hadith;
  final bool isLastRead;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 18.w,
        // vertical: 10.h,
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
            '${hadith.id}',
            style: AppTextStyle.style14W500.copyWith(
              color: isLastRead ? Colors.white : AppColors.primaryColor,
              fontFamily: AppFonts.amiri,
            ),
          ),
        ),
      ),

      title: Text(
        hadith.title,
        style: AppTextStyle.style18W900.copyWith(
          fontFamily: AppFonts.amiri,
          color: AppColors.thirdColor,
        ),
      ),
      // subtitle: Padding(
      //   padding: EdgeInsets.only(top: 6.h),
      //   child: Text(
      //     hadith.preview,
      //     maxLines: 2,
      //     overflow: TextOverflow.ellipsis,
      //     style: AppTextStyle.style18W600.copyWith(
      //       fontFamily: AppFonts.amiri,
      //     ),
      //   ),
      // ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16.r,
      ),
      onTap: () async {
        await context.read<TabeenCubit>().saveLastRead(hadith);

        await context.pushNamed(
          AppRoutes.tabeenReadingView,
          extra: hadith,
        );
      },
    );
  }
}
