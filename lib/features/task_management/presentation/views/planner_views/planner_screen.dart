import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_management/presentation/views/planner_views/monthly_planner_view.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        toolbarHeight: 50.h,
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.white,
        title: Text(AppTexts.planning, style: AppTextStyle.style16Bold),
        centerTitle: true,
      ),
      body: const MonthlyPlannerView(),
    );
  }
}
