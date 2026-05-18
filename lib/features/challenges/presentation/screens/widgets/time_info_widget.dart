import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';

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
              ? AppColors.white
              : AppColors.secondaryColor,
        ),
        8.horizontalSpace,
        Text(
          '$label: ',
          style: AppTextStyle.style12Bold.copyWith(
            color:
                challenge.status == ChallengeStatus.failed ||
                    challenge.status == ChallengeStatus.success
                ? AppColors.white
                : null,
          ),
        ),
        Expanded(
          child: Text(
            '$value.',
            style: AppTextStyle.style12W500.copyWith(
              fontSize: 11.sp,
              color:
                  challenge.status == ChallengeStatus.failed ||
                      challenge.status == ChallengeStatus.success
                  ? AppColors.white
                  : AppColors.secondaryColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
