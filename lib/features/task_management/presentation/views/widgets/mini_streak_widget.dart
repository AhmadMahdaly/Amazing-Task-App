import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

class MiniStreakWidget extends StatelessWidget {
  const MiniStreakWidget({
    required this.currentStreak,
    required this.isActiveToday,
    super.key,
  });
  final int currentStreak;
  final bool isActiveToday;

  @override
  Widget build(BuildContext context) {
    final activeColor = isActiveToday
        ? AppColors.orangeColor
        : AppColors.buttonColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: activeColor.withAlpha(20),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: activeColor.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: activeColor,
            size: 14.r,
          ),
          4.horizontalSpace,
          Text(
            '$currentStreak',
            style: AppTextStyle.style10Bold.copyWith(
              color: activeColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
