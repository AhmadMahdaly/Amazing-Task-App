// ignore_for_file: avoid_field_initializers_in_const_classes

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';
import 'package:s/features/challenges/presentation/cubit/challenge_cubit/challenge_cubit.dart';

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
              ? Colors.transparent
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
                      child: Text(
                        AppTexts.noChallengesCurrently,
                        style: AppTextStyle.style18W500,
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
                return Center(child: Text(AppTexts.startByAddingChallenge));
              },
            ),
          ),
        );
      },
    );
  }
}

class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    required this.challenge,
    required this.cardColor,
    super.key,
  });
  final ChallengeModel challenge;

  final Color cardColor;

  Color _getStatusColor(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return Colors.green;
      case ChallengeStatus.success:
        return Colors.green.withAlpha(150);
      case ChallengeStatus.failed:
        return Colors.red.withAlpha(100);
    }
  }

  String _getStatusText(ChallengeStatus status) {
    switch (status) {
      case ChallengeStatus.active:
        return AppTexts.active;
      case ChallengeStatus.success:
        return AppTexts.success;
      case ChallengeStatus.failed:
        return AppTexts.failed;
    }
  }

  Color _getHaradnessColor(ChallengeLevel status) {
    switch (status) {
      case ChallengeLevel.light:
        return Colors.green;
      case ChallengeLevel.medium:
        return Colors.blue;
      case ChallengeLevel.strong:
        return Colors.lime;
    }
  }

  String _getHaradnessText(ChallengeLevel status) {
    switch (status) {
      case ChallengeLevel.light:
        return AppTexts.light;
      case ChallengeLevel.medium:
        return AppTexts.medium;
      case ChallengeLevel.strong:
        return AppTexts.hard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isActive = challenge.status == ChallengeStatus.active;
    final now = DateTime.now();
    final remainingTime = challenge.endDate.difference(now);

    return Card(
      color: challenge.status == ChallengeStatus.failed
          ? Colors.redAccent
          : challenge.status == ChallengeStatus.success
          ? AppColors.primaryColor
          : cardColor,
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (challenge.imagePath != null && challenge.imagePath!.isNotEmpty)
            Image.file(
              File(challenge.imagePath!),
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.grey,
                    size: 50.r,
                  ),
                );
              },
            ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8.w,
                  children: [
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getHaradnessColor(challenge.level),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _getHaradnessText(challenge.level),
                        style: AppTextStyle.style12Bold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(challenge.status),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _getStatusText(challenge.status),
                        style: AppTextStyle.style12Bold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (isActive)
                      PopupMenuButton<ChallengeStatus>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.black54,
                        ),
                        onSelected: (result) async {
                          await context
                              .read<ChallengeCubit>()
                              .updateChallengeStatus(
                                challenge.id,
                                result,
                              );
                        },
                        itemBuilder: (context) =>
                            <PopupMenuEntry<ChallengeStatus>>[
                              PopupMenuItem<ChallengeStatus>(
                                value: ChallengeStatus.success,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    AppTexts.success,
                                    style: AppTextStyle.style12Bold.copyWith(
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<ChallengeStatus>(
                                value: ChallengeStatus.failed,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ),
                                  title: Text(
                                    AppTexts.failed,
                                    style: AppTextStyle.style12Bold.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                      ),
                  ],
                ),

                Text(
                  challenge.title,
                  style: AppTextStyle.style20Bold,
                  overflow: TextOverflow.ellipsis,
                ),

                4.horizontalSpace,

                Text(
                  challenge.description,
                  style: AppTextStyle.style14W500.copyWith(
                    color:
                        challenge.status == ChallengeStatus.failed ||
                            challenge.status == ChallengeStatus.success
                        ? Colors.white
                        : Colors.grey[700],
                  ),
                ),
                8.verticalSpace,
                Divider(
                  color:
                      challenge.status == ChallengeStatus.failed ||
                          challenge.status == ChallengeStatus.success
                      ? Colors.white
                      : null,
                ),
                4.verticalSpace,
                if (isActive && !remainingTime.isNegative)
                  TimeInfo(
                    challenge: challenge,
                    label: AppTexts.timeRemaining,
                    value: _formatDuration(remainingTime),
                    icon: Icons.timer_outlined,
                  )
                else if (challenge.completionDate != null)
                  TimeInfo(
                    challenge: challenge,
                    label: AppTexts.completionDate,
                    value: DateFormat(
                      'dd MMMM yyyy - hh:mm a',
                    ).format(challenge.completionDate!),
                    icon: Icons.check_circle_outline,
                  )
                else
                  TimeInfo(
                    challenge: challenge,
                    label: AppTexts.status,
                    value: AppTexts.timeExpired,
                    icon: Icons.hourglass_disabled_outlined,
                  ),

                4.verticalSpace,
                TimeInfo(
                  challenge: challenge,
                  label: AppTexts.challengePeriod,
                  value:
                      '${DateFormat('dd MMM yyyy').format(challenge.startDate)} - ${DateFormat('dd MMM yyyy').format(challenge.endDate)}',
                  icon: Icons.date_range_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return AppTexts.timeExpired;

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);

    if (days > 0) {
      return '$days ${AppTexts.day} $hours ${AppTexts.hour} $minutes ${AppTexts.minute}';
    } else if (hours > 0) {
      return '$hours ${AppTexts.hour} $minutes ${AppTexts.minute}';
    } else {
      return '$minutes ${AppTexts.minute}';
    }
  }
}

class TimeInfo extends StatelessWidget {
  const TimeInfo({
    required this.label,
    required this.value,
    required this.icon,
    required this.challenge,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final ChallengeModel challenge;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.r,
          color:
              challenge.status == ChallengeStatus.failed ||
                  challenge.status == ChallengeStatus.success
              ? Colors.white
              : Colors.grey[600],
        ),
        8.horizontalSpace,
        Text(
          '$label: ',
          style: AppTextStyle.style12Bold.copyWith(
            color:
                challenge.status == ChallengeStatus.failed ||
                    challenge.status == ChallengeStatus.success
                ? Colors.white
                : null,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyle.style12W500.copyWith(
              color:
                  challenge.status == ChallengeStatus.failed ||
                      challenge.status == ChallengeStatus.success
                  ? Colors.white
                  : Colors.grey[800],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
