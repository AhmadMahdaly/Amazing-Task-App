import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

class ZekrItemWidget extends StatelessWidget {
  const ZekrItemWidget({
    required this.fontSize,
    required this.zekrText,
    required this.benefit,
    required this.totalCount,
    required this.currentCount,
    required this.onTap,
    super.key,
  });

  final String zekrText;
  final String benefit;
  final int totalCount;
  final int currentCount;
  final VoidCallback onTap;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    final isCompleted = currentCount == 0;

    final progress = totalCount > 0 ? currentCount / totalCount : 0.0;

    return GestureDetector(
      onTap: isCompleted ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isCompleted
              ? AppColors.buttonColor.withAlpha(100)
              : AppColors.buttonColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isCompleted ? Colors.green : AppColors.thirdColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              zekrText,
              style: AppTextStyle.style18W800.copyWith(
                color: AppColors.primaryColor,
                fontFamily: AppFonts.amiri,
                height: 2,
                fontSize: fontSize,
              ),
              textAlign: TextAlign.justify,
            ),

            16.verticalSpace,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (benefit.isNotEmpty) ...[
                        24.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.r,
                            vertical: 4.r,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(10),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            benefit,
                            style: AppTextStyle.style9W300.copyWith(
                              color: AppColors.primaryColor,
                              fontFamily: AppFonts.ar,
                            ),
                          ),
                        ),
                      ],
                      8.verticalSpace,
                    ],
                  ),
                ),
                20.horizontalSpace,
                SizedBox(
                  width: 56.r,
                  height: 56.r,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 1, end: progress),
                        duration: const Duration(milliseconds: 300),
                        builder: (context, value, _) {
                          return CircularProgressIndicator(
                            value: value,
                            strokeWidth: 3.r,
                            backgroundColor: Colors.grey.withAlpha(50),
                            color: isCompleted
                                ? Colors.green
                                : AppColors.primaryColor,
                          );
                        },
                      ),

                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 46.r,
                          height: 46.r,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? Colors.green
                                : AppColors.primaryColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color:
                                    (isCompleted
                                            ? Colors.green
                                            : AppColors.primaryColor)
                                        .withAlpha(50),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 22.r,
                                  )
                                : Text(
                                    '$currentCount',
                                    style: AppTextStyle.style16Bold.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$totalCount',
                  style: AppTextStyle.style9W500.copyWith(
                    color: AppColors.secondaryColor.withAlpha(20),
                    fontFamily: AppFonts.ar,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
