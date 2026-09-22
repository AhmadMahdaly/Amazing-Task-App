// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/timer/presentation/controllers/pomodoro_history_cubit/pomodoro_history_cubit.dart';

class PomodoroHistoryView extends StatefulWidget {
  const PomodoroHistoryView({super.key, this.taskId});
  final String? taskId;

  @override
  State<PomodoroHistoryView> createState() => _PomodoroHistoryViewState();
}

class _PomodoroHistoryViewState extends State<PomodoroHistoryView> {
  @override
  void initState() {
    super.initState();

    context.read<PomodoroHistoryCubit>().loadHistory(taskId: widget.taskId);
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Scaffold(
          backgroundColor: wallpaperState.settings.hasWallpaper
              ? Colors.transparent
              : AppColors.primaryColor,
          appBar: AppBar(
            title: Text(
              'Sessions History',
              style: AppTextStyle.style16W600.copyWith(),
            ),
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            ),
          ),
          body: AppWallpaper(
            settings: wallpaperState.settings,
            child: BlocBuilder<PomodoroHistoryCubit, PomodoroHistoryState>(
              builder: (context, state) {
                if (state is PomodoroHistoryLoading) {
                  return const Center(child: LoadingWidget());
                } else if (state is PomodoroHistoryLoaded) {
                  if (state.sessions.isEmpty) {
                    return Center(
                      child: Text(
                        'No sessions recorded yet.',
                        style: AppTextStyle.style14W600.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.all(16.r),
                    itemCount: state.sessions.length,
                    separatorBuilder: (context, index) => 12.verticalSpace,
                    itemBuilder: (context, index) {
                      final session = state.sessions[index];
                      final dateFormatted = DateFormat(
                        'dd MMM yyyy, hh:mm a',
                      ).format(session.startTime);

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          color: AppColors.primaryColor.withAlpha(100),
                          border: Border.all(
                            color: AppColors.buttonColor.withAlpha(50),
                            width: 1,
                          ),
                        ),
                        padding: EdgeInsets.all(12.r),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: AppColors.buttonColor.withAlpha(20),
                                shape: BoxShape.circle,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    color: AppColors.buttonColor,
                                    size: 24.r,
                                  ),
                                  4.verticalSpace,
                                  Text(
                                    _formatDuration(
                                      session.actualDurationInSeconds,
                                    ),
                                    style: AppTextStyle.style9W400.copyWith(
                                      color: AppColors.buttonColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            12.horizontalSpace,

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.taskName.isNotEmpty
                                        ? session.taskName
                                        : 'Focused Task',
                                    style: AppTextStyle.style14W600.copyWith(
                                      color: AppColors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  4.verticalSpace,
                                  Text(
                                    session.description,
                                    style: AppTextStyle.style12W500.copyWith(
                                      color: AppColors.white.withAlpha(200),
                                    ),
                                  ),
                                  8.verticalSpace,
                                  Text(
                                    dateFormatted,
                                    style: AppTextStyle.style9W300.copyWith(
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                session.mode.name.replaceAll('min', ''),
                                style: AppTextStyle.style9W400.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                } else if (state is PomodoroHistoryError) {
                  return Center(
                    child: Text(
                      'Error loading history',
                      style: AppTextStyle.style12W500.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}
