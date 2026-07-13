import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/resources/islamic_text.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/features/islamic_section/missed_prayers/presentation/cubit/missed_prayers_cubit.dart';
import 'package:s/features/islamic_section/missed_prayers/presentation/views/widgets/prayer_item_widget.dart';

class PrayersTrackingView extends StatelessWidget {
  const PrayersTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            IslamicTexts.trackingTitle,
            style: AppTextStyle.style16Bold.copyWith(
              fontFamily: kPrimaryArFont,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          actions: [
            BlocBuilder<MissedPrayersCubit, MissedPrayersState>(
              builder: (context, state) {
                if (state is MissedPrayersLoaded) {
                  return IconButton(
                    onPressed: () => context.pushNamed(
                      AppRoutes.settingsCalculationView,
                      extra: state.prayersData,
                    ),
                    icon: const Icon(Icons.settings),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<MissedPrayersCubit, MissedPrayersState>(
            builder: (context, state) {
              if (state is MissedPrayersLoaded) {
                final data = state.prayersData;
                final totalLeft =
                    data.fajrLeft +
                    data.dhuhrLeft +
                    data.asrLeft +
                    data.maghribLeft +
                    data.ishaLeft;
                final maxTotalTarget = data.totalTargetPerPrayer * 5;
                final overallProgress = maxTotalTarget > 0
                    ? (maxTotalTarget - totalLeft) / maxTotalTarget
                    : 1.0;

                return Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildOverallAnalyticsCard(overallProgress),
                      16.verticalSpace,
                      Expanded(
                        child: ListView(
                          children: [
                            PrayerItemWidget(
                              prayerName: IslamicTexts.fajr,
                              countLeft: data.fajrLeft,
                              progress: data.getProgress(data.fajrLeft),
                              type: PrayerType.fajr,
                            ),
                            PrayerItemWidget(
                              prayerName: IslamicTexts.dhuhr,
                              countLeft: data.dhuhrLeft,
                              progress: data.getProgress(data.dhuhrLeft),
                              type: PrayerType.dhuhr,
                            ),
                            PrayerItemWidget(
                              prayerName: IslamicTexts.asr,
                              countLeft: data.asrLeft,
                              progress: data.getProgress(data.asrLeft),
                              type: PrayerType.asr,
                            ),
                            PrayerItemWidget(
                              prayerName: IslamicTexts.maghrib,
                              countLeft: data.maghribLeft,
                              progress: data.getProgress(data.maghribLeft),
                              type: PrayerType.maghrib,
                            ),
                            PrayerItemWidget(
                              prayerName: IslamicTexts.isha,
                              countLeft: data.ishaLeft,
                              progress: data.getProgress(data.ishaLeft),
                              type: PrayerType.isha,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is MissedPrayersError) {
                return Center(
                  child: Text(
                    state.message,
                    style: AppTextStyle.style14W500.copyWith(
                      color: AppColors.errorColor,
                      fontFamily: kPrimaryArFont,
                    ),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOverallAnalyticsCard(double progress) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.thirdColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            IslamicTexts.overallProgressTitle,
            style: AppTextStyle.style14Bold.copyWith(
              color: AppColors.primaryColor,
              fontFamily: kPrimaryArFont,
            ),
          ),
          10.verticalSpace,

          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryColor.withAlpha(100),
            color: AppColors.primaryColor,
            minHeight: 10.h,
            borderRadius: BorderRadius.circular(12.r),
          ),
          8.verticalSpace,

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${IslamicTexts.completedRatio}: ${(progress * 100).toStringAsFixed(1)}%',
                style: AppTextStyle.style12W500.copyWith(
                  color: AppColors.secondaryColor,
                  fontFamily: kPrimaryArFont,
                ),
              ),
              Text(
                '${IslamicTexts.remainingRatio}: ${((1 - progress) * 100).toStringAsFixed(1)}%',
                style: AppTextStyle.style12W500.copyWith(
                  color: AppColors.secondaryColor,
                  fontFamily: kPrimaryArFont,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
