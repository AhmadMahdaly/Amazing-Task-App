import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/directional_text.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/repeat_format_utils.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class TaskItemWidget extends StatelessWidget {
  const TaskItemWidget({
    required this.task,
    this.showCompletedDate = false,
    super.key,
  });

  final TaskEntity task;
  final bool showCompletedDate;

  void _openDetail(BuildContext context) {
    unawaited(context.push('/task/${task.id}'));
  }

  @override
  Widget build(BuildContext context) {
    final dateText = task.isCompleted
        ? (showCompletedDate || task.completedAt != null
              ? formatCompletedDate(task.completedAt)
              : '')
        : formatTaskDate(task.dueDate);
    final repeatText = formatRepeatMode(task.repeatMode);
    final stepsText = task.hasSteps
        ? '${task.completedSteps}/${task.totalSteps} ${AppTexts.stepsProgress}'
        : '';

    final showRepeat = repeatText.isNotEmpty && !task.isCompleted;
    final hasSubtitle =
        dateText.isNotEmpty || showRepeat || stepsText.isNotEmpty;

    final isOverdue =
        !task.isCompleted &&
        task.dueDate != null &&
        task.dueDate!.isBefore(
          DateTime(
            DateTime.now().year,
            DateTime.now().month,
            DateTime.now().day,
          ),
        );

    final currentState = context.read<TasksCubit>().state;
    var isMyDayView = false;
    if (currentState is TasksLoaded) {
      isMyDayView = currentState.currentFilter == TaskFilter.myDay;
    }

    return Dismissible(
      key: ValueKey('${task.id}_dismissible'),
      direction: DismissDirection.horizontal,
      background: Container(
        color: isMyDayView ? AppColors.primaryColor : Colors.orangeAccent,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Icon(
          isMyDayView ? Icons.next_plan_outlined : Icons.wb_sunny_outlined,
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
            await cubit.addToMyDay(task);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppTexts.taskAddedToMyDay,
                    style: AppTextStyle.style9W300.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.orangeAccent,
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
      onDismissed: (direction) async {
        final cubit = context.read<TasksCubit>();

        if (direction == DismissDirection.startToEnd) {
          await cubit.postponeToTomorrow(task);
        } else {
          if (isMyDayView) {
            await cubit.removeFromMyDay(task);
          } else {
            await cubit.deleteTask(task.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppTexts.taskDeleted,
                    style: AppTextStyle.style9W300.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          }
        }
      },
      child: Material(
        color: AppColors.scaffoldBackgroundLightColor,
        borderRadius: BorderRadius.circular(8.r),
        child: InkWell(
          onTap: () => _openDetail(context),
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: AppColors.scaffoldBackgroundLightColor,
              borderRadius: BorderRadius.circular(8.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 4.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              subtitle: hasSubtitle
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (dateText.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                task.isCompleted
                                    ? Icons.event_available
                                    : Icons.schedule,
                                size: 12.r,
                                color: task.isCompleted
                                    ? AppColors.thirdColor
                                    : (isOverdue
                                          ? Colors.red
                                          : AppColors.secondaryColor),
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: DirectionalText(
                                  dateText,
                                  style: AppTextStyle.style9W300.copyWith(
                                    fontSize: 11.sp,
                                    color: task.isCompleted
                                        ? AppColors.thirdColor
                                        : (isOverdue
                                              ? Colors.red
                                              : AppColors.secondaryColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (stepsText.isNotEmpty) ...[
                          SizedBox(height: 2.h),
                          Row(
                            children: [
                              Icon(
                                Icons.checklist,
                                size: 12.r,
                                color: AppColors.secondaryColor,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: DirectionalText(
                                  stepsText,
                                  style: AppTextStyle.style9W300.copyWith(
                                    fontSize: 11.sp,
                                    color: AppColors.secondaryColor,
                                  ),
                                ),
                              ),
                              if (task.hasSteps)
                                SizedBox(
                                  width: 60.w,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(2.r),
                                    child: LinearProgressIndicator(
                                      value: task.totalSteps > 0
                                          ? task.completedSteps /
                                                task.totalSteps
                                          : 0,
                                      minHeight: 4.h,
                                      backgroundColor: AppColors.secondaryColor
                                          .withAlpha(40),
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
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
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: DirectionalText(
                                    repeatText,
                                    style: AppTextStyle.style9W300.copyWith(
                                      fontSize: 11.sp,
                                      color: AppColors.secondaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  : null,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 4.h,
              ),
              leading: InkWell(
                onTap: () async {
                  await context.read<TasksCubit>().toggleTaskCompletion(task);
                },
                child: Icon(
                  task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: task.isCompleted
                      ? AppColors.primaryColor
                      : AppColors.secondaryColor,
                  size: 24.r,
                ),
              ),
              title: DirectionalText(
                task.title,
                style: AppTextStyle.style12W300.copyWith(
                  color: task.isCompleted
                      ? AppColors.secondaryColor
                      : AppColors.forthColor,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              trailing: IconButton(
                tooltip: task.isImportant
                    ? AppTexts.unmarkImportant
                    : AppTexts.markImportant,
                icon: Icon(
                  task.isImportant ? Icons.star : Icons.star_border,
                  color: task.isImportant
                      ? AppColors.primaryColor
                      : AppColors.secondaryColor,
                  size: 24.r,
                ),
                onPressed: () async {
                  await context.read<TasksCubit>().updateTask(
                    task.copyWith(isImportant: !task.isImportant),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
