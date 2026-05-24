import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';
import 'package:s/features/challenges/presentation/screens/widgets/analysis_widgets/legend_widget.dart';
import 'package:s/features/challenges/presentation/screens/widgets/analysis_widgets/pie_chart_section_widget.dart';

class StatusChart extends StatelessWidget {
  const StatusChart({required this.challenges, super.key});
  final List<ChallengeModel> challenges;

  @override
  Widget build(BuildContext context) {
    final total = challenges.length;
    if (total == 0) return const SizedBox.shrink();

    final activeCount = challenges
        .where((c) => c.status == ChallengeStatus.active)
        .length;
    final successCount = challenges
        .where((c) => c.status == ChallengeStatus.success)
        .length;
    final failedCount = challenges
        .where((c) => c.status == ChallengeStatus.failed)
        .length;

    return Column(
      children: [
        Text(
          AppTexts.analysisByStatus,
          style: AppTextStyle.style16Bold,
        ),
        12.verticalSpace,
        SizedBox(
          height: 200.r,
          child: PieChart(
            PieChartData(
              sections: [
                if (activeCount > 0)
                  buildPieChartSection(
                    value: activeCount.toDouble(),
                    title: '${(activeCount / total * 100).toStringAsFixed(0)}%',
                    color: AppColors.activeColor,
                    radius: 65.r,
                  ),
                if (successCount > 0)
                  buildPieChartSection(
                    value: successCount.toDouble(),
                    title:
                        '${(successCount / total * 100).toStringAsFixed(0)}%',
                    color: AppColors.successColor,
                    radius: 60.r,
                  ),
                if (failedCount > 0)
                  buildPieChartSection(
                    value: failedCount.toDouble(),
                    title: '${(failedCount / total * 100).toStringAsFixed(0)}%',
                    color: AppColors.errorColor,
                    radius: 60.r,
                  ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40.r,
            ),
          ),
        ),
        8.verticalSpace,
        Legend(
          items: [
            LegendItem(
              color: AppColors.activeColor,
              text: AppTexts.active,
              count: activeCount,
            ),
            LegendItem(
              color: AppColors.successColor,
              text: AppTexts.success,
              count: successCount,
            ),
            LegendItem(
              color: AppColors.errorColor,
              text: AppTexts.failed,
              count: failedCount,
            ),
          ],
        ),
      ],
    );
  }
}
