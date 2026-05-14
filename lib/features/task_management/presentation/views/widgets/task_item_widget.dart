import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class TaskItemWidget extends StatelessWidget {
  const TaskItemWidget({required this.task, super.key});
  final TaskEntity task;

  String _getRelativeDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(date.year, date.month, date.day);
    final diff = taskDate.difference(today).inDays;

    if (diff == 0) return AppTexts.today;
    if (diff == 1) return AppTexts.tomorrow;
    if (diff == -1) return AppTexts.yesterday;
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getRepeatText(String? mode) {
    if (mode == null) return '';

    if (mode.startsWith('custom:')) {
      final parts = mode.split(':');
      if (parts.length >= 3) {
        final count = parts[1];
        final unit = parts[2];
        var unitAr = '';
        if (unit == 'days') unitAr = AppTexts.days;
        if (unit == 'weeks') unitAr = AppTexts.weeks;
        if (unit == 'months') unitAr = AppTexts.months;
        if (unit == 'years') unitAr = AppTexts.years;

        return 'كل $count $unitAr';
      }
    }

    switch (mode) {
      case 'daily':
        return AppTexts.daily;
      case 'weekdays':
        return AppTexts.weekdays;
      case 'weekly':
        return AppTexts.weekly;
      case 'monthly':
        return AppTexts.monthly;
      case 'yearly':
        return AppTexts.yearly;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _getRelativeDate(task.dueDate);
    final repeatText = _getRepeatText(task.repeatMode);

    final showRepeat = repeatText.isNotEmpty && !task.isCompleted;
    final hasSubtitle = dateText.isNotEmpty || showRepeat;

    final isOverdue =
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

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppTexts.taskAddedToMyDay,
                  style: AppTextStyle.style9W300.copyWith(color: Colors.white),
                ),
                backgroundColor: Colors.orangeAccent,
                duration: const Duration(seconds: 1),
              ),
            );
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppTexts.taskDeleted,
                  style: AppTextStyle.style9W300.copyWith(color: Colors.white),
                ),
                backgroundColor: Colors.redAccent,
                duration: const Duration(seconds: 1),
              ),
            );
          }
        }
      },

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
              ? Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      AppTexts.tasks,
                      style: AppTextStyle.style9W300.copyWith(
                        fontSize: 11.sp,
                        color: AppColors.secondaryColor,
                      ),
                    ),

                    if (dateText.isNotEmpty) ...[
                      Text(
                        ' • $dateText',
                        style: AppTextStyle.style9W300.copyWith(
                          fontSize: 11.sp,
                          color: isOverdue && !task.isCompleted
                              ? Colors.red
                              : AppColors.secondaryColor,
                        ),
                      ),
                    ],

                    if (showRepeat) ...[
                      Text(
                        ' • ',
                        style: AppTextStyle.style9W300.copyWith(
                          fontSize: 11.sp,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                      Icon(
                        Icons.repeat,
                        size: 12.r,
                        color: AppColors.secondaryColor,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        repeatText,
                        style: AppTextStyle.style9W300.copyWith(
                          fontSize: 11.sp,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ],
                  ],
                )
              : null,

          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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
          title: Text(
            task.title,
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 14.sp,
              color: task.isCompleted
                  ? AppColors.secondaryColor
                  : AppColors.forthColor,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              task.isImportant ? Icons.star : Icons.star_border,
              color: task.isImportant
                  ? AppColors.primaryColor
                  : AppColors.secondaryColor,
              size: 24.r,
            ),
            onPressed: () async {
              final updatedTask = TaskEntity(
                id: task.id,
                title: task.title,
                isCompleted: task.isCompleted,
                dueDate: task.dueDate,
                reminderDate: task.reminderDate,
                repeatMode: task.repeatMode,
                completedSteps: task.completedSteps,
                totalSteps: task.totalSteps,
                isImportant: !task.isImportant,
                myDayDate: task.myDayDate,
                position: task.position,
                listId: task.listId,
              );
              await context.read<TasksCubit>().updateTask(updatedTask);
            },
          ),
        ),
      ),
    );
  }
}
