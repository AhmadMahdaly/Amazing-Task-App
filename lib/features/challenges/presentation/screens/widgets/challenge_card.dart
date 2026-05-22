import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/directional_text.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';
import 'package:s/features/challenges/presentation/cubit/challenge_cubit/challenge_cubit.dart';
import 'package:s/features/challenges/presentation/screens/widgets/time_info_widget.dart';

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
        return AppColors.successColor;
      case ChallengeStatus.success:
        return AppColors.successColor.withAlpha(150);
      case ChallengeStatus.failed:
        return AppColors.errorColor.withAlpha(100);
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
        return AppColors.successColor;
      case ChallengeLevel.medium:
        return AppColors.secondaryColor;
      case ChallengeLevel.strong:
        return AppColors.errorColor;
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
          ? AppColors.errorColor.withAlpha(200)
          : challenge.status == ChallengeStatus.success
          ? AppColors.successColor.withAlpha(200)
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
                    color: AppColors.secondaryColor,
                    size: 32.r,
                  ),
                );
              },
            ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        style: AppTextStyle.style9Bold.copyWith(
                          color: AppColors.white,
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
                        style: AppTextStyle.style9Bold.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    if (isActive)
                      PopupMenuButton<ChallengeStatus>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: AppColors.secondaryColor,
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
                                    color: AppColors.successColor,
                                  ),
                                  title: Text(
                                    AppTexts.success,
                                    style: AppTextStyle.style12Bold.copyWith(
                                      color: AppColors.successColor,
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<ChallengeStatus>(
                                value: ChallengeStatus.failed,
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.cancel,
                                    color: AppColors.errorColor,
                                  ),
                                  title: Text(
                                    AppTexts.failed,
                                    style: AppTextStyle.style12Bold.copyWith(
                                      color: AppColors.errorColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                      ),
                  ],
                ),
                12.verticalSpace,
                DirectionalText(
                  challenge.title,
                  style: AppTextStyle.style14Bold,
                  overflow: TextOverflow.ellipsis,
                ),

                4.horizontalSpace,

                DirectionalText(
                  challenge.description,
                  style: AppTextStyle.style12W500.copyWith(
                    color:
                        challenge.status == ChallengeStatus.failed ||
                            challenge.status == ChallengeStatus.success
                        ? AppColors.white
                        : AppColors.secondaryColor,
                  ),
                ),
                8.verticalSpace,
                Divider(
                  color:
                      challenge.status == ChallengeStatus.failed ||
                          challenge.status == ChallengeStatus.success
                      ? AppColors.white
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
