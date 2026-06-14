import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/missed_prayers/presentation/cubit/missed_prayers_cubit.dart';

class PrayerItemWidget extends StatelessWidget {
  const PrayerItemWidget({
    required this.prayerName,
    required this.countLeft,
    required this.progress,
    required this.type,
    super.key,
  });
  final String prayerName;
  final int countLeft;
  final double progress;
  final PrayerType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.buttonColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                prayerName,
                style: AppTextStyle.style16Bold,
              ),
              Text(
                '${AppTexts.remaining}: $countLeft',
                style: AppTextStyle.style14W500.copyWith(
                  color: AppColors.secondaryColor,
                ),
              ),
            ],
          ),
          8.verticalSpace,

          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryColor.withAlpha(100),
            color: AppColors.primaryColor,
            minHeight: 8.h,
            borderRadius: BorderRadius.circular(12.r),
          ),
          8.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => context
                    .read<MissedPrayersCubit>()
                    .performPrayer(type, isUndo: true),
                icon: Icon(
                  Icons.undo,
                  size: 24.sp,
                  color: AppColors.secondaryColor,
                ),
              ),
              8.horizontalSpace,

              ElevatedButton(
                onPressed: countLeft > 0
                    ? () =>
                          context.read<MissedPrayersCubit>().performPrayer(type)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 10.h,
                  ),
                ),
                child: Text(
                  AppTexts.done,
                  style: AppTextStyle.style14W500.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
