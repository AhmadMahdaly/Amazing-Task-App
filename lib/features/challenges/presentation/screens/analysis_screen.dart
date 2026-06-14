import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/analytics/presentation/views/widgets/empty_analytics_state.dart';
import 'package:s/features/challenges/presentation/cubit/challenge_cubit/challenge_cubit.dart';
import 'package:s/features/challenges/presentation/screens/widgets/level_chart_widget.dart';
import 'package:s/features/challenges/presentation/screens/widgets/status_chart_widget.dart';

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
              return const EmptyAnalyticsState();
            }
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  StatusChart(challenges: state.challenges),
                  8.verticalSpace,
                  const Divider(),
                  8.verticalSpace,
                  LevelChart(challenges: state.challenges),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
