import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

class EmptyTasksState extends StatelessWidget {
  const EmptyTasksState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(
          Icons.add_task_rounded,
          color: AppColors.white.withAlpha(150),
          size: 50.r,
        ),
        12.verticalSpace,
        Text(
          AppTexts.noTasksInThisList,
          style: AppTextStyle.style16W600.copyWith(
            color: AppColors.white.withAlpha(150),
          ),
          textAlign: TextAlign.center,
        ),
        20.verticalSpace,
      ],
    );
  }
}
