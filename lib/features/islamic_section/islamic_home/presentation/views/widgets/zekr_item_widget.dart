import 'package:flutter/material.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

class ZekrItemWidget extends StatelessWidget {
  const ZekrItemWidget({
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

  @override
  Widget build(BuildContext context) {
    // التحقق مما إذا كان الذكر قد اكتمل
    final isCompleted = currentCount == 0;

    return GestureDetector(
      onTap: isCompleted ? null : onTap, // تعطيل الضغط إذا انتهى العدد
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
            width: isCompleted ? 2 : 1,
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
            // نص الذكر
            Text(
              zekrText,
              style: AppTextStyle.style14W500.copyWith(
                color: isCompleted
                    ? Colors.grey.shade700
                    : AppColors.primaryColor,
                fontFamily: kPrimaryArFont,
                height: 1.5, // مسافة بين السطور لسهولة القراءة
              ),
              textAlign: TextAlign.justify,
            ),

            // فضل الذكر (إن وجد)
            if (benefit.isNotEmpty) ...[
              10.verticalSpace,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  benefit,
                  style: AppTextStyle.style12W500.copyWith(
                    color: AppColors.secondaryColor,
                    fontFamily: kPrimaryArFont,
                  ),
                ),
              ),
            ],

            16.verticalSpace,

            // قسم العداد
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : AppColors.primaryColor,
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
                        ? Icon(Icons.check, color: Colors.white, size: 24.r)
                        : Text(
                            '$currentCount',
                            style: AppTextStyle.style16Bold.copyWith(
                              color: Colors.white,
                            ),
                          ),
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
