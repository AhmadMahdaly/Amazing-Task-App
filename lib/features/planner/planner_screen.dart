import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/features/planner/monthly_planner_view.dart';

class PlannerScreen extends StatelessWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),

        title: Text(AppTexts.planning, style: AppTextStyle.style16Bold),
        centerTitle: true,
      ),
      body: const MonthlyPlannerView(),
    );
  }
}
