// ignore_for_file: avoid_field_initializers_in_const_classes

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';
import 'package:s/features/challenges/presentation/cubit/challenge_cubit/challenge_cubit.dart';
import 'package:s/features/challenges/presentation/screens/widgets/challenge_card.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});
  final _cardColors = const [
    Color(0xFFFFF3E0),
    Color(0xFFE0F7FA),
    Color(0xFFF1F8E9),
    Color(0xFFF3E5F5),
    Color(0xFFFFFDE7),
    Color(0xFFE3F2FD),
  ];
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Scaffold(
          backgroundColor: wallpaperState.settings.hasWallpaper
              ? AppColors.transparent
              : AppColors.primaryColor,
          appBar: AppBar(
            title: Text(AppTexts.yourChallengesList),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                onPressed: () =>
                    context.pushNamed(AppRoutes.challengeAnalysisScreen),
                icon: const Icon(Icons.bar_chart_outlined),
                tooltip: AppTexts.challengesAnalysis,
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(320.r),
            ),
            onPressed: () => context.pushNamed(AppRoutes.addChallengeScreen),
            backgroundColor: AppColors.white,
            child: Icon(
              Icons.add,
              size: 28.r,
              color: AppColors.primaryColor,
            ),
          ),
          body: AppWallpaper(
            settings: wallpaperState.settings,
            child: BlocBuilder<ChallengeCubit, ChallengeState>(
              builder: (context, state) {
                if (state is ChallengeLoading) {
                  return const Center(child: LoadingWidget());
                }
                if (state is ChallengeLoaded) {
                  if (state.challenges.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.r),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: 420.w),
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                            vertical: 28.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.buttonColor,
                            borderRadius: BorderRadius.circular(24.r),
                            border: Border.all(
                              color: AppColors.errorColor.withAlpha(40),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(18),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 84.r,
                                height: 84.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.errorColor.withAlpha(25),
                                ),
                                child: Icon(
                                  Icons.emoji_events_outlined,
                                  size: 42.r,
                                  color: AppColors.errorColor,
                                ),
                              ),

                              20.verticalSpace,

                              Text(
                                AppTexts.howChallengesWork,
                                textAlign: TextAlign.center,
                                style: AppTextStyle.style20Bold.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),

                              8.verticalSpace,

                              Divider(
                                color: AppColors.primaryColor.withAlpha(40),
                                thickness: 1,
                              ),

                              8.verticalSpace,

                              Text(
                                AppTexts.challengeDescription,
                                textAlign: TextAlign.justify,
                                style: AppTextStyle.style16W500.copyWith(
                                  // height: 0.8,
                                  color: AppColors.secondaryColor,
                                ),
                              ),

                              28.verticalSpace,

                              CustomPrimaryButton(
                                onPressed: () async {
                                  await context.pushNamed(
                                    AppRoutes.addChallengeScreen,
                                  );
                                },

                                text: AppTexts.addNewChallenge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final sortedChallenges =
                      List<ChallengeModel>.from(
                        state.challenges,
                      )..sort((a, b) {
                        if (a.status == ChallengeStatus.active &&
                            b.status != ChallengeStatus.active) {
                          return -1;
                        }
                        if (a.status != ChallengeStatus.active &&
                            b.status == ChallengeStatus.active) {
                          return 1;
                        }
                        return b.startDate.compareTo(a.startDate);
                      });

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    itemCount: sortedChallenges.length,
                    itemBuilder: (context, index) {
                      return ChallengeCard(
                        challenge: sortedChallenges[index],
                        cardColor: _cardColors[index % _cardColors.length],
                      );
                    },
                  );
                }
                if (state is ChallengeError) {
                  return Center(child: Text(state.message));
                }
                return Center(
                  child: Text(
                    AppTexts.startByAddingChallenge,
                    style: AppTextStyle.style12Bold.copyWith(
                      color: AppColors.buttonColor,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
