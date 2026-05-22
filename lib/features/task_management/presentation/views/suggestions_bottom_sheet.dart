import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/directional_text.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class SuggestionsBottomSheet extends StatelessWidget {
  const SuggestionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              40.horizontalSpace,
              Text(
                AppTexts.suggestions,
                style: AppTextStyle.style18Bold.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              IconButton(
                tooltip: AppTexts.close,
                icon: Icon(
                  Icons.close,
                  color: AppColors.secondaryColor,
                  size: 24.r,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: BlocBuilder<TasksCubit, TasksState>(
              builder: (context, tasksState) {
                if (tasksState is! TasksLoaded) {
                  return const Center(child: CircularProgressIndicator());
                }

                final overdueTasks = <TaskEntity>[];
                final suggestedTasks = <TaskEntity>[];

                final now = DateTime.now();
                final today = DateTime(now.year, now.month, now.day);

                for (final t in tasksState.allTasks) {
                  if (t.isCompleted || isTaskInMyDay(t)) continue;

                  var isOverdue = false;
                  if (t.dueDate != null) {
                    final due = DateTime(
                      t.dueDate!.year,
                      t.dueDate!.month,
                      t.dueDate!.day,
                    );
                    if (due.isBefore(today)) {
                      isOverdue = true;
                    }
                  }

                  if (isOverdue) {
                    overdueTasks.add(t);
                  } else {
                    suggestedTasks.add(t);
                  }
                }

                if (overdueTasks.isEmpty && suggestedTasks.isEmpty) {
                  return Center(
                    child: Text(
                      AppTexts.noSuggestedTasksCurrently,
                      style: AppTextStyle.style12W300.copyWith(
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  );
                }

                return BlocBuilder<ListsCubit, ListsState>(
                  builder: (context, listsState) {
                    final listsMap = <String, String>{};
                    if (listsState is ListsLoaded) {
                      for (final list in listsState.lists) {
                        listsMap[list.id] = list.title;
                      }
                    }

                    return ListView(
                      children: [
                        if (overdueTasks.isNotEmpty) ...[
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Text(
                              AppTexts.yesterday,
                              style: AppTextStyle.style14Bold.copyWith(
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          ...overdueTasks.map(
                            (task) => _buildTaskItem(
                              context,
                              task,
                              listsMap,
                              isOverdue: true,
                            ),
                          ),
                          16.verticalSpace,
                        ],

                        if (suggestedTasks.isNotEmpty) ...[
                          if (overdueTasks.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              child: Text(
                                AppTexts.suggestions,
                                style: AppTextStyle.style14Bold.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ...suggestedTasks.map(
                            (task) => _buildTaskItem(
                              context,
                              task,
                              listsMap,
                              isOverdue: false,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    TaskEntity task,
    Map<String, String> listsMap, {
    required bool isOverdue,
  }) {
    final listName = task.listId != null
        ? listsMap[task.listId!] ?? AppTexts.customList
        : AppTexts.tasks;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: isOverdue
            ? Border.all(color: Colors.redAccent.withAlpha(50), width: 1)
            : null,
      ),
      child: ListTile(
        title: DirectionalText(
          task.title,
          style: AppTextStyle.style12W300.copyWith(
            fontWeight: FontWeight.bold,
            color: isOverdue ? Colors.redAccent : AppColors.forthColor,
          ),
        ),
        subtitle: Text(
          listName,
          style: AppTextStyle.style9W300.copyWith(
            color: AppColors.secondaryColor,
            fontSize: 11.sp,
          ),
        ),
        trailing: IconButton(
          tooltip: AppTexts.addToMyDay,
          icon: Icon(
            Icons.add,
            color: AppColors.primaryColor,
            size: 24.r,
          ),
          onPressed: () {
            unawaited(
              context.read<TasksCubit>().addToMyDay(task),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppTexts.addedToMyDaySuccess,
                  style: AppTextStyle.style9W300.copyWith(
                    color: Colors.white,
                  ),
                ),
                backgroundColor: AppColors.successColor,
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
      ),
    );
  }
}
