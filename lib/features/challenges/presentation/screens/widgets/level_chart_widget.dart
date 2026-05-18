import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';
import 'package:s/features/challenges/presentation/screens/widgets/analysis_widgets/legend_widget.dart';
import 'package:s/features/challenges/presentation/screens/widgets/analysis_widgets/pie_chart_section_widget.dart';

class LevelChart extends StatelessWidget {
  const LevelChart({
    required this.challenges,
    super.key,
  });

  final List<ChallengeModel> challenges;

  @override
  Widget build(BuildContext context) {
    final total = challenges.length;
    if (total == 0) return const SizedBox.shrink();

    final lightCount = challenges
        .where((c) => c.level == ChallengeLevel.light)
        .length;
    final mediumCount = challenges
        .where((c) => c.level == ChallengeLevel.medium)
        .length;
    final strongCount = challenges
        .where((c) => c.level == ChallengeLevel.strong)
        .length;

    return Column(
      children: [
        Text(AppTexts.analysisByLevel, style: AppTextStyle.style14Bold),
        20.verticalSpace,
        SizedBox(
          height: 200.r,
          child: PieChart(
            PieChartData(
              sections: [
                if (lightCount > 0)
                  buildPieChartSection(
                    value: lightCount.toDouble(),
                    title: '${(lightCount / total * 100).toStringAsFixed(0)}%',
                    color: AppColors.successColor,
                    radius: 65.r,
                  ),
                if (mediumCount > 0)
                  buildPieChartSection(
                    value: mediumCount.toDouble(),
                    title: '${(mediumCount / total * 100).toStringAsFixed(0)}%',
                    color: AppColors.activeColor,
                    radius: 60.r,
                  ),
                if (strongCount > 0)
                  buildPieChartSection(
                    value: strongCount.toDouble(),
                    title: '${(strongCount / total * 100).toStringAsFixed(0)}%',
                    color: AppColors.errorColor,
                    radius: 60.r,
                  ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40.r,
            ),
          ),
        ),
        24.verticalSpace,
        Legend(
          items: [
            LegendItem(
              color: AppColors.successColor,
              text: AppTexts.light,
              count: lightCount,
            ),
            LegendItem(
              color: AppColors.activeColor,
              text: AppTexts.medium,
              count: mediumCount,
            ),
            LegendItem(
              color: AppColors.errorColor,
              text: AppTexts.hard,
              count: strongCount,
            ),
          ],
        ),
      ],
    );
  }
}
