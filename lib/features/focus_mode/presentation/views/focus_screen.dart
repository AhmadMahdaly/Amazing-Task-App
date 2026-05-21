import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/focus_mode/presentation/controllers/cubit/focus_cubit.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({required this.task, super.key});

  final TaskEntity task;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  @override
  void initState() {
    super.initState();

    context.read<FocusCubit>().setupSession(widget.task, minutes: 25);
  }

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        toolbarHeight: 60.h,
        actions: [
          IconButton(
            onPressed: () => context.pushNamed(AppRoutes.focusHistoryScreen),
            icon: const Icon(Icons.history, color: AppColors.white),
          ),
          8.horizontalSpace,
        ],
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.white),
          onPressed: () {
            context.read<FocusCubit>().stopAndSaveEarly();
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocBuilder<WallpaperCubit, WallpaperState>(
        builder: (context, wallpaperState) {
          return AppWallpaper(
            settings: wallpaperState.settings,
            child: BlocConsumer<FocusCubit, FocusState>(
              listener: (context, state) {
                if (state is FocusCompleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${AppTexts.focusCycleCompleted} ${state.actualDurationSaved ~/ 60} ${AppTexts.minute}.',
                      ),
                      backgroundColor: AppColors.successColor,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              builder: (context, state) {
                var seconds = 25 * 60;
                var isRunning = false;
                var isPaused = false;

                if (state is FocusReady) {
                  seconds = state.secondsRemaining;
                } else if (state is FocusRunning) {
                  seconds = state.secondsRemaining;
                  isRunning = true;
                } else if (state is FocusPaused) {
                  seconds = state.secondsRemaining;
                  isPaused = true;
                }

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.task.title,
                        style: AppTextStyle.style18Bold.copyWith(
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      60.verticalSpace,

                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 250.r,
                            height: 250.r,
                            child: CircularProgressIndicator(
                              value: seconds / (25 * 60),
                              strokeWidth: 10.r,
                              backgroundColor: AppColors.white.withAlpha(33),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          ),
                          Text(
                            _formatTime(seconds),
                            style: AppTextStyle.style18Bold.copyWith(
                              fontSize: 32.sp,
                              color: AppColors.white,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      80.verticalSpace,

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isRunning)
                            FloatingActionButton(
                              heroTag: 'play_btn',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(320.r),
                              ),
                              backgroundColor: AppColors.white.withAlpha(200),
                              onPressed: () =>
                                  context.read<FocusCubit>().startTimer(),
                              child: Icon(
                                Icons.play_arrow,
                                color: AppColors.primaryColor,
                                size: 32.r,
                              ),
                            ),
                          if (isRunning)
                            FloatingActionButton(
                              heroTag: 'pause_btn',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(320.r),
                              ),
                              backgroundColor: AppColors.white.withAlpha(200),
                              onPressed: () =>
                                  context.read<FocusCubit>().pauseTimer(),
                              child: Icon(
                                Icons.pause,
                                color: AppColors.primaryColor,
                                size: 32.r,
                              ),
                            ),

                          if (isRunning || isPaused) ...[
                            SizedBox(width: 20.w),
                            FloatingActionButton(
                              heroTag: 'stop_btn',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(320.r),
                              ),
                              backgroundColor: AppColors.errorColor,
                              onPressed: () {
                                context.read<FocusCubit>().stopAndSaveEarly();
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.stop,
                                color: AppColors.white,
                                size: 32.r,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
