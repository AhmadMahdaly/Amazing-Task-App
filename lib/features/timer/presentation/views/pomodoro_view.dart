// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/timer/domian/entities/pomodoro_session_entity.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../controllers/pomodoro_cubit/pomodoro_cubit.dart';

class PomodoroView extends StatefulWidget {
  const PomodoroView({
    required this.taskId,
    required this.taskName,
    super.key,
  });
  final String taskId;
  final String taskName;

  @override
  State<PomodoroView> createState() => _PomodoroViewState();
}

class _PomodoroViewState extends State<PomodoroView> {
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<PomodoroCubit>().loadTaskTotalTime(widget.taskId);
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _descController.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: wallpaperState.settings.hasWallpaper
              ? Colors.transparent
              : AppColors.primaryColor,
          appBar: AppBar(
            title: Text(
              'Pomodoro',
              style: AppTextStyle.style16W600.copyWith(),
            ),
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () => context.pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: () async {
                  await context.pushNamed(
                    AppRoutes.pomodoroHistoryView,
                    extra: {
                      'taskId': widget.taskId,
                    },
                  );
                },
              ),
            ],
          ),
          body: AppWallpaper(
            settings: wallpaperState.settings,
            child: BlocBuilder<PomodoroCubit, PomodoroState>(
              builder: (context, state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    16.verticalSpace,
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: Text(
                        widget.taskName,
                        textAlign: TextAlign.center,
                        style: AppTextStyle.style16W600.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    16.verticalSpace,

                    AnimatedOpacity(
                      opacity: state.isRunning ? 0.0 : 1.0,
                      duration: const Duration(
                        milliseconds: 300,
                      ),
                      child: IgnorePointer(
                        ignoring: state.isRunning,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 16.r),
                          child: Row(
                            children: [
                              _buildChoiceChip(
                                context,
                                '5m',
                                TimerMode.min5,
                                state.selectedMode,
                              ),
                              8.horizontalSpace,
                              _buildChoiceChip(
                                context,
                                '10m',
                                TimerMode.min10,
                                state.selectedMode,
                              ),
                              8.horizontalSpace,
                              _buildChoiceChip(
                                context,
                                '25m',
                                TimerMode.min25,
                                state.selectedMode,
                              ),
                              8.horizontalSpace,
                              _buildChoiceChip(
                                context,
                                'Custom',
                                TimerMode.custom,
                                state.selectedMode,
                              ),
                              8.horizontalSpace,
                              _buildChoiceChip(
                                context,
                                'Open',
                                TimerMode.openEnded,
                                state.selectedMode,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    32.verticalSpace,

                    Center(
                      child: Container(
                        padding: EdgeInsets.all(40.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primaryColor.withAlpha(50),
                          border: Border.all(
                            color: AppColors.buttonColor,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          _formatTime(state.currentSeconds),
                          style: AppTextStyle.style16W600.copyWith(
                            fontSize: 48.r,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),

                    32.verticalSpace,

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!state.isRunning)
                          IconButton(
                            iconSize: 64.r,
                            icon: const Icon(
                              Icons.play_circle_fill,
                              color: AppColors.buttonColor,
                            ),
                            onPressed: () =>
                                context.read<PomodoroCubit>().startTimer(),
                          )
                        else
                          IconButton(
                            iconSize: 64.r,
                            icon: const Icon(
                              Icons.pause_circle_filled,
                              color: AppColors.white,
                            ),
                            onPressed: () =>
                                context.read<PomodoroCubit>().pauseTimer(),
                          ),
                      ],
                    ),

                    const Spacer(),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: TextField(
                        controller: _descController,
                        style: AppTextStyle.style12W500.copyWith(
                          color: AppColors.white,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What did you do in this session?',
                          hintStyle: AppTextStyle.style12W500.copyWith(
                            color: AppColors.secondaryColor,
                          ),
                          filled: true,
                          fillColor: AppColors.primaryColor.withAlpha(100),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    16.verticalSpace,

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.r),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: state.startTime != null
                            ? () {
                                context
                                    .read<PomodoroCubit>()
                                    .stopAndSaveSession(
                                      taskId: widget.taskId,
                                      taskName: widget.taskName,
                                      description:
                                          _descController.text.trim().isEmpty
                                          ? 'Focused Session'
                                          : _descController.text.trim(),
                                    );
                                _descController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Session saved successfully!',
                                    ),
                                  ),
                                );
                              }
                            : null,
                        child: Text(
                          'Save & End Session',
                          style: AppTextStyle.style14W600.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),

                    16.verticalSpace,

                    Center(
                      child: Text(
                        'Total time for this task: ${_formatTime(state.totalPreviousSeconds + state.actualSessionTime)}',
                        style: AppTextStyle.style12W500.copyWith(
                          color: AppColors.white.withAlpha(200),
                        ),
                      ),
                    ),
                    32.verticalSpace,
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildChoiceChip(
    BuildContext context,
    String label,
    TimerMode mode,
    TimerMode selectedMode,
  ) {
    return ChoiceChip(
      label: Text(
        label,
        style: selectedMode == mode
            ? AppTextStyle.style12W600
            : AppTextStyle.style12W500.copyWith(
                color: AppColors.primaryColor.withAlpha(150),
              ),
      ),
      selectedColor: AppColors.primaryColor.withAlpha(100),
      backgroundColor: Colors.transparent,
      selected: selectedMode == mode,
      onSelected: (val) async {
        if (val) {
          if (mode == TimerMode.custom) {
            await _showCustomTimeDialog(context);
          } else {
            context.read<PomodoroCubit>().selectMode(mode);
          }
        }
      },
    );
  }

  Future<void> _showCustomTimeDialog(BuildContext context) async {
    final minutesController = TextEditingController();

    final customMinutes = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Custom Timer',
            style: AppTextStyle.style14W600.copyWith(color: AppColors.white),
          ),
          content: TextField(
            controller: minutesController,
            keyboardType: TextInputType.number,
            style: AppTextStyle.style12W500.copyWith(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Enter minutes (e.g. 45)',
              hintStyle: AppTextStyle.style12W500.copyWith(
                color: AppColors.white,
              ),
              filled: true,
              fillColor: AppColors.white.withAlpha(100),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: AppColors.buttonColor,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(
                  color: AppColors.buttonColor,
                  width: 2,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: AppTextStyle.style12W500.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () {
                final text = minutesController.text.trim();
                if (text.isNotEmpty) {
                  final minutes = int.tryParse(text);
                  if (minutes != null && minutes > 0) {
                    Navigator.pop(
                      dialogContext,
                      minutes,
                    );
                  }
                }
              },
              child: Text(
                'Set',
                style: AppTextStyle.style12W600.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (customMinutes != null && context.mounted) {
      context.read<PomodoroCubit>().selectMode(
        TimerMode.custom,
        customMinutes: customMinutes,
      );
    }
  }
}
