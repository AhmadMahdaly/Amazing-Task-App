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
          color: AppColors.white,
          size: 50.r,
        ),
        8.verticalSpace,
        Text(
          AppTexts.noTasksInThisList,
          style: AppTextStyle.style14Bold.copyWith(
            color: AppColors.white,
          ),
          textAlign: TextAlign.center,
        ),
        20.verticalSpace,
      ],
    );
  }
}
