import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/islamic_section/hisn_azkar/presentation/cubit/hisn_cubit.dart';

class HisnIndexView extends StatelessWidget {
  const HisnIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75.h,
          title: Text(
            'حصن المسلم',
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
        body: BlocBuilder<HisnCubit, HisnState>(
          builder: (context, state) {
            if (state is HisnLoading) {
              return const Center(
                child: LoadingWidget(
                  color: AppColors.primaryColor,
                ),
              );
            }

            if (state is HisnError) {
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

            if (state is HisnLoaded) {
              return Column(
                children: [
                  16.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: CustomPrimaryTextfield(
                      onChanged: context.read<HisnCubit>().search,

                      text: 'ابحث عن ذكر...',
                      prefix: const Icon(
                        Icons.search,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 16.r),
                      itemCount: state.chapters.length,
                      separatorBuilder: (context, index) => Divider(
                        color: AppColors.thirdColor.withAlpha(40),
                        height: 1,
                        indent: 16.r,
                        endIndent: 16.r,
                      ),
                      itemBuilder: (context, index) {
                        final chapter = state.chapters[index];

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
                              color: AppColors.primaryColor.withAlpha(20),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppTextStyle.style14W500.copyWith(
                                  color: AppColors.primaryColor,
                                  fontFamily: AppFonts.amiri,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            chapter.title,
                            style: AppTextStyle.style18W900.copyWith(
                              color: AppColors.primaryColor,
                              fontFamily: AppFonts.amiri,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16.r,
                            color: AppColors.secondaryColor,
                          ),
                          onTap: () async {
                            await context.pushNamed(
                              AppRoutes.hisnReadingView,
                              extra: chapter,
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
                          Text(
                            'عن حصن المسلم',
                            style: AppTextStyle.style20W900.copyWith(
                              fontFamily: AppFonts.amiri,
                              color: AppColors.primaryColor,
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
            يُعد كتاب «حصن المسلم من أذكار الكتاب والسنة» من أشهر كتب الأذكار في العالم الإسلامي، وقد ألّفه الشيخ سعيد بن علي بن وهف القحطاني، وجمع فيه الأذكار والأدعية الصحيحة الواردة في القرآن الكريم والسنة النبوية.
            
            يمتاز الكتاب بسهولة ترتيبه، حيث قُسمت الأذكار بحسب المناسبات والأحوال اليومية، مثل أذكار الصباح والمساء، والنوم، والاستيقاظ، والصلاة، والسفر، والطعام، وغيرها، مع الاقتصار على الأحاديث الصحيحة أو الحسنة.
            
            ومن خلال هذا القسم يمكنك الوصول إلى الأذكار بسهولة، وقراءتها في وقتها، والمواظبة عليها لتكون معينًا لك على ذكر الله في مختلف أحوالك، اقتداءً بهدي النبي ﷺ.
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
                                    'احرص على المحافظة على هذه الأذكار يوميًا، فهي من أعظم أسباب طمأنينة القلب، وحفظ الله لعبده، واتباع سنة النبي ﷺ.',
                                    style: AppTextStyle.style18W500.copyWith(
                                      fontFamily: AppFonts.amiri,
                                      color: AppColors.primaryColor,
                                      height: 1.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          30.verticalSpace,
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
