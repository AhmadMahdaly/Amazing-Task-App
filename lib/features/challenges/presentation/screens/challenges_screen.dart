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
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ChallengeLoaded) {
                  if (state.challenges.isEmpty) {
                    return Center(
                      child: Container(
                        height: 300.h,
                        width: 300.w,
                        padding: EdgeInsets.all(16.r),

                        decoration: BoxDecoration(
                          color: AppColors.errorColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.errorColor.withAlpha(77),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,

                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.errorColor,
                                  size: 30.r,
                                ),
                                8.horizontalSpace,
                                Text(
                                  AppTexts.howChallengesWork,
                                  style: AppTextStyle.style18Bold.copyWith(
                                    color: AppColors.buttonColor,
                                  ),
                                ),
                              ],
                            ),
                            12.verticalSpace,

                            Text(
                              AppTexts.challengeDescription,
                              style: AppTextStyle.style16W500.copyWith(
                                height: 1.6,
                                color: AppColors.buttonColor,
                              ),
                            ),
                          ],
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
                      horizontal: 24.w,
                      vertical: 8.h,
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
