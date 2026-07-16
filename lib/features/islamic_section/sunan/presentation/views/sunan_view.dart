// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/islamic_section/sunan/presentation/cubit/sunan_cubit.dart';

class SunanView extends StatelessWidget {
  const SunanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'السنن في الإسلام',
              style: AppTextStyle.style16Bold.copyWith(
                fontFamily: kPrimaryArFont,
              ),
            ),
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            ),

            bottom: TabBar(
              indicatorColor: AppColors.white,
              labelStyle: AppTextStyle.style16W900.copyWith(
                fontFamily: AppFonts.amiri,
                color: AppColors.white,
              ),
              unselectedLabelColor: AppColors.buttonColor.withAlpha(200),
              tabs: const [
                Tab(text: 'أنواع السنن'),
                Tab(text: 'أقسام السنة'),
                Tab(text: 'السنن الإلهية'),
              ],
            ),
          ),
          body: BlocBuilder<SunanCubit, SunanState>(
            builder: (context, state) {
              if (state is SunanLoading) {
                return const Center(
                  child: LoadingWidget(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (state is SunanError) {
                return Center(
                  child: Text(
                    state.message,
                    style: AppTextStyle.style16W500.copyWith(
                      color: AppColors.errorColor,
                    ),
                  ),
                );
              }

              if (state is SunanLoaded) {
                return TabBarView(
                  children: [
                    _buildTypesOfSunanTab(
                      state.sunanData.typesOfSunan,
                      context,
                    ),

                    _buildSectionsOfSunnahTab(
                      state.sunanData.sectionsOfSunnah,
                    ),

                    _buildDivineSunanTab(state.sunanData.divineSunan),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTypesOfSunanTab(Map<String, dynamic> types, BuildContext ctx) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: types.entries.map((entry) {
        final title = entry.key.replaceAll('_', ' ');
        final content = entry.value as Map<String, dynamic>;

        return Card(
          elevation: 2,
          margin: EdgeInsets.only(bottom: 16.r),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Theme(
            data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text(
                title,
                style: AppTextStyle.style18W900.copyWith(
                  color: AppColors.primaryColor,
                  fontFamily: AppFonts.amiri,
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: content.entries.map((subEntry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ${subEntry.key.replaceAll('_', ' ')}:',
                              style: AppTextStyle.style18W800.copyWith(
                                color: AppColors.thirdColor,
                                fontFamily: AppFonts.amiri,
                              ),
                            ),
                            4.verticalSpace,
                            _buildDynamicContent(subEntry.value),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionsOfSunnahTab(List<dynamic> sections) {
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: sections.length,
      separatorBuilder: (context, index) => 16.verticalSpace,
      itemBuilder: (context, index) {
        final section = sections[index] as Map<String, dynamic>;

        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.buttonColor.withAlpha(100),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.thirdColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: section.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.r),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key.replaceAll('_', ' ')}: ',
                      style: AppTextStyle.style16W900.copyWith(
                        color: AppColors.primaryColor,
                        fontFamily: AppFonts.amiri,
                      ),
                    ),
                    Expanded(child: _buildDynamicContent(entry.value)),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDivineSunanTab(Map<String, dynamic> divineData) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: divineData.entries.map((entry) {
        return Card(
          elevation: 1,
          margin: EdgeInsets.only(bottom: 12.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key.replaceAll('_', ' '),
                  style: AppTextStyle.style16Bold.copyWith(
                    color: AppColors.primaryColor,
                    fontFamily: AppFonts.amiri,
                  ),
                ),
                8.verticalSpace,
                _buildDynamicContent(entry.value),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDynamicContent(dynamic content) {
    if (content is String) {
      return Text(
        content,
        style: AppTextStyle.style18W500.copyWith(
          height: 1.5,
          fontFamily: AppFonts.amiri,
        ),
      );
    } else if (content is List) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.map((item) {
          return Padding(
            padding: EdgeInsets.only(top: 4.r, right: 8.r),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⁃ ',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16.sp,
                    fontFamily: AppFonts.amiri,
                  ),
                ),
                Expanded(child: _buildDynamicContent(item)),
              ],
            ),
          );
        }).toList(),
      );
    } else if (content is Map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: content.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(top: 4.r),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${entry.key.replaceAll('_', ' ')}: ',
                    style: AppTextStyle.style16W800.copyWith(
                      color: AppColors.thirdColor,
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  TextSpan(
                    text: entry.value.toString(),
                    style: AppTextStyle.style16W500.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }
}
