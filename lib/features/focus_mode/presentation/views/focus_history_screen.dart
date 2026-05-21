import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/focus_mode/data/models/focus_session_model.dart';
import 'package:s/features/focus_mode/presentation/controllers/cubit/focus_cubit.dart';

class FocusHistoryScreen extends StatelessWidget {
  const FocusHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTexts.focusHistory,
          style: AppTextStyle.style18Bold.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
      ),
      body: FutureBuilder<List<FocusSessionModel>>(
        future: context.read<FocusCubit>().getSessionHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return Center(
              child: Text(
                AppTexts.noRecordedSessionsYet,
                style: AppTextStyle.style12W300,
              ),
            );
          }

          sessions.sort((a, b) => b.endTime.compareTo(a.endTime));

          return ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: sessions.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _SessionTile(session: session);
            },
          );
        },
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  const _SessionTile({required this.session});
  final FocusSessionModel session;

  @override
  Widget build(BuildContext context) {
    final duration = session.durationInSeconds ~/ 60;
    final date = '${session.startTime.day}/${session.startTime.month}';
    final time =
        "${session.startTime.hour}:${session.startTime.minute.toString().padLeft(2, '0')}";

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(15), blurRadius: 6.r),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.timer, color: AppColors.primaryColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTexts.focusSession,
                  style: AppTextStyle.style12W300.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$date - $time',
                  style: AppTextStyle.style9W300.copyWith(
                    color: AppColors.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.successColor.withAlpha(30),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$duration ${AppTexts.minute}',
              style: AppTextStyle.style9W300.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.successColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
