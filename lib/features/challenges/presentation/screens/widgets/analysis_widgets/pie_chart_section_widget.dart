import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';

PieChartSectionData buildPieChartSection({
  required double value,
  required String title,
  required Color color,
  double radius = 50,
}) {
  return PieChartSectionData(
    color: color,
    value: value,
    title: title,
    radius: radius,
    titleStyle: AppTextStyle.style16Bold.copyWith(
      color: AppColors.white,
      shadows: [const Shadow(color: AppColors.forthColor, blurRadius: 2)],
    ),
  );
}
