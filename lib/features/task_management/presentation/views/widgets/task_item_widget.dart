import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/functions/play_sound.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/directional_text.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';
import 'package:s/features/task_management/domain/utils/repeat_format_utils.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class TaskItemWidget extends StatefulWidget {
  const TaskItemWidget({
    required this.task,
    this.showCompletedDate = false,
    this.inCalendarView = false, // 1. أضف هذا السطر
    super.key,
  });

  final TaskEntity task;
  final bool showCompletedDate;
  final bool inCalendarView; // 2. أضف هذا السطر

  @override
  State<TaskItemWidget> createState() => _TaskItemWidgetState();
}

class _TaskItemWidgetState extends State<TaskItemWidget> {
  bool _isHidden = false;

  void _openDetail(BuildContext context) {
    unawaited(context.push('/task/${widget.task.id}'));
  }

  @override
  Widget build(BuildContext context) {
    final dateText = widget.task.isCompleted
        ? (widget.showCompletedDate || widget.task.completedAt != null
              ? formatCompletedDate(widget.task.completedAt)
              : '')
        : formatTaskDate(widget.task.dueDate);
    final repeatText = formatRepeatMode(widget.task.repeatMode);
    final stepsText = widget.task.hasSteps
        ? '${widget.task.completedSteps}/${widget.task.totalSteps} ${AppTexts.stepsProgress}'
        : '';

    final showRepeat = repeatText.isNotEmpty && !widget.task.isCompleted;
    final hasSubtitle =
        dateText.isNotEmpty || showRepeat || stepsText.isNotEmpty;

    final isOverdue =
        !widget.task.isCompleted &&
        widget.task.dueDate != null &&
        widget.task.dueDate!.isBefore(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        );

    final currentState = context.read<TasksCubit>().state;
    var isMyDayView = false;

    if (!widget.inCalendarView && currentState is TasksLoaded) {
      isMyDayView = currentState.currentFilter == TaskFilter.myDay;
    }

    final alreadyInMyDay = isTaskInMyDay(widget.task);

    if (_isHidden) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      child: Dismissible(
        key: ValueKey('${widget.task.id}_dismissible'),
        direction: DismissDirection.horizontal,

        background: Container(
          color: isMyDayView
              ? AppColors.primaryColor
              : (alreadyInMyDay ? Colors.redAccent : Colors.orangeAccent),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Icon(
            isMyDayView
                ? Icons.next_plan_outlined
                : (alreadyInMyDay
                      ? Icons.remove_circle_outline
                      : Icons.wb_sunny_outlined),
            color: Colors.white,
          ),
        ),

        secondaryBackground: Container(
          color: Colors.redAccent,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Icon(
            isMyDayView ? Icons.remove_circle_outline : Icons.delete_outline,
            color: Colors.white,
          ),
        ),

        confirmDismiss: (direction) async {
          final cubit = context.read<TasksCubit>();

          if (direction == DismissDirection.startToEnd) {
            if (isMyDayView) {
              return true;
            } else {
              if (alreadyInMyDay) {
                await cubit.removeFromMyDay(widget.task);
              } else {
                await cubit.addToMyDay(widget.task);
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      alreadyInMyDay
                          ? AppTexts.unpinFromNotification
                          : AppTexts.taskAddedToMyDay,
                      style: AppTextStyle.style9W300.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: alreadyInMyDay
                        ? Colors.redAccent
                        : Colors.orangeAccent,
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
              return false;
            }
          } else {
            return true;
          }
        },

        onDismissed: (direction) {
          setState(() {
            _isHidden = true;
          });

          final cubit = context.read<TasksCubit>();

          if (direction == DismissDirection.startToEnd) {
            unawaited(cubit.removeFromMyDay(widget.task));
          } else {
            if (isMyDayView) {
              unawaited(cubit.removeFromMyDay(widget.task));
            } else {
              final snapshot = widget.task;
              unawaited(cubit.deleteTask(widget.task.id));

              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppTexts.taskDeleted,
                    style: AppTextStyle.style9W300.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  dismissDirection: DismissDirection.horizontal,
                  duration: const Duration(seconds: 4),
                  action: SnackBarAction(
                    label: AppTexts.undo,
                    textColor: Colors.white,
                    onPressed: () {
                      unawaited(cubit.restoreTask(snapshot));
                    },
                  ),
                ),
              );
            }
          }
        },
        child: Material(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4.r),
          child: InkWell(
            onTap: () => _openDetail(context),
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: ListTile(
                subtitle: hasSubtitle
                    ? Column(
                        children: [
                          if (dateText.isNotEmpty)
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      widget.task.isCompleted
                                          ? Icons.event_available
                                          : Icons.schedule,
                                      size: 12.r,
                                      color: widget.task.isCompleted
                                          ? AppColors.thirdColor
                                          : (isOverdue
                                                ? Colors.red
                                                : AppColors.secondaryColor),
                                    ),
                                    4.horizontalSpace,
                                    SizedBox(
                                      width: 100.w,
                                      child: DirectionalText(
                                        dateText,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyle.style9W300.copyWith(
                                          color: widget.task.isCompleted
                                              ? AppColors.thirdColor
                                              : (isOverdue
                                                    ? Colors.red
                                                    : AppColors.secondaryColor
                                                          .withAlpha(200)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                8.horizontalSpace,
                                if (showRepeat)
                                  Padding(
                                    padding: EdgeInsets.only(top: 2.h),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.repeat,
                                          size: 12.r,
                                          color: AppColors.secondaryColor,
                                        ),
                                        4.horizontalSpace,
                                        SizedBox(
                                          width: 60.w,
                                          child: DirectionalText(
                                            repeatText,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyle.style9W300
                                                .copyWith(
                                                  color: AppColors
                                                      .secondaryColor
                                                      .withAlpha(200),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          if (stepsText.isNotEmpty) ...[
                            2.verticalSpace,
                            Row(
                              children: [
                                Icon(
                                  Icons.checklist,
                                  size: 12.r,
                                  color: AppColors.secondaryColor,
                                ),
                                4.horizontalSpace,
                                Expanded(
                                  child: DirectionalText(
                                    stepsText,
                                    style: AppTextStyle.style9W300.copyWith(
                                      fontSize: 11.sp,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                ),
                                if (widget.task.hasSteps)
                                  SizedBox(
                                    width: 60.w,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(2.r),
                                      child: LinearProgressIndicator(
                                        value: widget.task.totalSteps > 0
                                            ? widget.task.completedSteps /
                                                  widget.task.totalSteps
                                            : 0,
                                        minHeight: 4.h,
                                        backgroundColor: AppColors
                                            .secondaryColor
                                            .withAlpha(40),
                                        color: AppColors.primaryColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      )
                    : null,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                leading: InkWell(
                  onTap: () async {
                    await context.read<TasksCubit>().toggleTaskCompletion(
                      widget.task,
                    );
                    await playSound();
                  },
                  child: Icon(
                    widget.task.isCompleted
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: widget.task.isCompleted
                        ? AppColors.primaryColor
                        : AppColors.secondaryColor,
                    size: 24.r,
                  ),
                ),
                title: DirectionalText(
                  widget.task.title,
                  style: AppTextStyle.style12W300.copyWith(
                    fontSize: 11.sp,
                    color: widget.task.isCompleted
                        ? AppColors.secondaryColor
                        : AppColors.forthColor,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                trailing: IconButton(
                  tooltip: widget.task.isImportant
                      ? AppTexts.unmarkImportant
                      : AppTexts.markImportant,
                  icon: Icon(
                    widget.task.isImportant ? Icons.star : Icons.star_border,
                    color: widget.task.isImportant
                        ? AppColors.primaryColor
                        : AppColors.secondaryColor,
                    size: 24.r,
                  ),
                  onPressed: () async {
                    await context.read<TasksCubit>().updateTask(
                      widget.task.copyWith(
                        isImportant: !widget.task.isImportant,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
