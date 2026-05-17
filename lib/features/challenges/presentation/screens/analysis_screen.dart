import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';
import 'package:s/features/challenges/presentation/cubit/challenge_cubit/challenge_cubit.dart';

class ChallengeAnalysisScreen extends StatelessWidget {
  const ChallengeAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.challengesAnalysis),
        centerTitle: true,
      ),

      body: BlocBuilder<ChallengeCubit, ChallengeState>(
        builder: (context, state) {
          if (state is ChallengeLoaded) {
            if (state.challenges.isEmpty) {
              return Center(
                child: Text(
                  AppTexts.notEnoughDataForAnalysis,
                  style: AppTextStyle.style12Bold,
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildStatusChart(context, state.challenges),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildLevelChart(context, state.challenges),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatusChart(
    BuildContext context,
    List<ChallengeModel> challenges,
  ) {
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
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        24.verticalSpace,
        SizedBox(
          height: 200.r,
          child: PieChart(
            PieChartData(
              sections: [
                if (activeCount > 0)
                  _buildPieChartSection(
                    value: activeCount.toDouble(),
                    title: '${(activeCount / total * 100).toStringAsFixed(0)}%',
                    color: Colors.blue,
                    radius: 65.r,
                  ),
                if (successCount > 0)
                  _buildPieChartSection(
                    value: successCount.toDouble(),
                    title:
                        '${(successCount / total * 100).toStringAsFixed(0)}%',
                    color: Colors.green,
                    radius: 60.r,
                  ),
                if (failedCount > 0)
                  _buildPieChartSection(
                    value: failedCount.toDouble(),
                    title: '${(failedCount / total * 100).toStringAsFixed(0)}%',
                    color: Colors.red,
                    radius: 60.r,
                  ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegend(
          items: [
            LegendItem(
              color: Colors.blue,
              text: AppTexts.active,
              count: activeCount,
            ),
            LegendItem(
              color: Colors.green,
              text: AppTexts.success,
              count: successCount,
            ),
            LegendItem(
              color: Colors.red,
              text: AppTexts.failed,
              count: failedCount,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelChart(
    BuildContext context,
    List<ChallengeModel> challenges,
  ) {
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
        Text(
          AppTexts.analysisByLevel,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 200.r,
          child: PieChart(
            PieChartData(
              sections: [
                if (lightCount > 0)
                  _buildPieChartSection(
                    value: lightCount.toDouble(),
                    title: '${(lightCount / total * 100).toStringAsFixed(0)}%',
                    color: Colors.greenAccent.shade700,
                    radius: 65.r,
                  ),
                if (mediumCount > 0)
                  _buildPieChartSection(
                    value: mediumCount.toDouble(),
                    title: '${(mediumCount / total * 100).toStringAsFixed(0)}%',
                    color: Colors.orangeAccent.shade700,
                    radius: 60.r,
                  ),
                if (strongCount > 0)
                  _buildPieChartSection(
                    value: strongCount.toDouble(),
                    title: '${(strongCount / total * 100).toStringAsFixed(0)}%',
                    color: Colors.redAccent.shade700,
                    radius: 60.r,
                  ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildLegend(
          items: [
            LegendItem(
              color: Colors.greenAccent.shade700,
              text: AppTexts.light,
              count: lightCount,
            ),
            LegendItem(
              color: Colors.orangeAccent.shade700,
              text: AppTexts.medium,
              count: mediumCount,
            ),
            LegendItem(
              color: Colors.redAccent.shade700,
              text: AppTexts.hard,
              count: strongCount,
            ),
          ],
        ),
      ],
    );
  }

  PieChartSectionData _buildPieChartSection({
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
      titleStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
  }

  Widget _buildLegend({required List<LegendItem> items}) {
    return Wrap(
      spacing: 24,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 16, height: 16, color: item.color),
            const SizedBox(width: 8),
            Text(
              '${item.text}: ${item.count}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class LegendItem {
  LegendItem({required this.color, required this.text, required this.count});
  final Color color;
  final String text;
  final int count;
}
