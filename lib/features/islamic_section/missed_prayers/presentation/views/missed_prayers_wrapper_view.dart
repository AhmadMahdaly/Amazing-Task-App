import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/features/islamic_section/missed_prayers/presentation/cubit/missed_prayers_cubit.dart';

import '../../../../../core/resources/app_colors.dart';
import 'prayers_tracking_view.dart';
import 'setup_calculation_view.dart';

class MissedPrayersWrapperView extends StatelessWidget {
  const MissedPrayersWrapperView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: BlocBuilder<MissedPrayersCubit, MissedPrayersState>(
          builder: (context, state) {
            if (state is MissedPrayersLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryColor),
              );
            }

            if (state is MissedPrayersLoaded) {
              return const PrayersTrackingView();
            }

            return const SetupCalculationView();
          },
        ),
      ),
    );
  }
}
