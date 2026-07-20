import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_lesson.dart';
import 'package:s/features/islamic_section/asmaa/presentation/cubit/asmaa_cubit.dart';
import 'package:s/features/islamic_section/notes/presentation/utils/notes_section_type.dart';

class AsmaaIndexView extends StatelessWidget {
  const AsmaaIndexView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'أسماء الله الحسنى',
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
                  extra: NotesSectionType.asmaa,
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
        body: BlocBuilder<AsmaaCubit, AsmaaState>(
          builder: (context, state) {
            if (state is AsmaaLoading) {
              return const Center(
                child: LoadingWidget(
                  color: AppColors.primaryColor,
                ),
              );
            }

            if (state is AsmaaError) {
              return Center(
                child: Text(
                  state.message,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (state is AsmaaLoaded) {
              return Column(
                children: [
                  if (state.lastReadLessonId != null)
                    _buildContinueReadingCard(
                      context,
                      state.lessons,
                      state.lastReadLessonId!,
                    ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: state.lessons.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: AppColors.thirdColor,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final lesson = state.lessons[index];
                        final isLastRead = lesson.id == state.lastReadLessonId;

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
                                '${lesson.id}',
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
                            lesson.title,
                            style: AppTextStyle.style18W900.copyWith(
                              fontFamily: AppFonts.amiri,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          subtitle: Text(
                            'شرح وتأملات في اسم الله',
                            style: AppTextStyle.style12W800.copyWith(
                              color: AppColors.secondaryColor,
                              fontFamily: AppFonts.amiri,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: AppColors.secondaryColor,
                          ),
                          onTap: () async {
                            await _navigateToReading(context, lesson);
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
    List<AsmaaLesson> lessons,
    int lastReadId,
  ) {
    final lastLesson = lessons.firstWhere((s) => s.id == lastReadId);

    return GestureDetector(
      onTap: () => _navigateToReading(context, lastLesson),
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
                    lastLesson.title,
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
                            Icons.auto_stories_rounded,
                            color: AppColors.primaryColor,
                            size: 28.r,
                          ),
                          10.horizontalSpace,
                          Text(
                            'عن الكتاب',
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
            يُعد كتاب «أسماء الله الحسنى» للدكتور محمد راتب النابلسي من أشهر الكتب المعاصرة التي تناولت هذا الباب العظيم، حيث يشرح أسماء الله الحسنى بأسلوب سهل يجمع بين الأدلة الشرعية والتأمل في معانيها وآثارها في حياة المسلم.
            
            ويهدف الكتاب إلى تعريف القارئ بربه سبحانه وتعالى، وترسيخ الإيمان من خلال فهم أسماء الله الحسنى، وربط هذه المعرفة بالسلوك والعبادة.
            
            وفي هذه الدروس ستتعرف على معاني كل اسم من أسماء الله الحسنى، وكيفية التعبد لله به، حتى تتحول المعرفة إلى يقين، واليقين إلى عمل، والعمل إلى قربٍ من الله سبحانه وتعالى.
            ''',
                            textAlign: TextAlign.justify,
                            style: AppTextStyle.style18W800.copyWith(
                              fontFamily: AppFonts.amiri,
                              color: AppColors.primaryColor,
                              height: 2,
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

  Future<void> _navigateToReading(
    BuildContext context,
    AsmaaLesson lesson,
  ) async {
    await context.pushNamed(
      AppRoutes.asmaaReadingView,
      extra: lesson,
    );
  }
}
