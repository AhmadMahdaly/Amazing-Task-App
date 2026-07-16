import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
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
                              color: AppColors.primaryColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppTextStyle.style14W800.copyWith(
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
}
