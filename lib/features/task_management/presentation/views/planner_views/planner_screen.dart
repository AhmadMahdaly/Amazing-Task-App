import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/features/task_management/presentation/views/planner_views/monthly_planner_view.dart';
import 'package:s/features/task_management/presentation/views/planner_views/weekly_planner_view.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          title: Text(AppTexts.planning, style: AppTextStyle.style16Bold),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: AppColors.white,
            indicatorWeight: 3,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withAlpha(150),
            labelStyle: AppTextStyle.style14Bold,
            tabs: [
              Tab(text: AppTexts.weekly),
              Tab(text: AppTexts.monthly),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            WeeklyPlannerView(),
            MonthlyPlannerView(),
          ],
        ),
      ),
    );
  }
}
