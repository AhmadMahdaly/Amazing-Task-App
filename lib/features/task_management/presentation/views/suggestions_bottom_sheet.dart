import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
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

                final suggestedTasks = tasksState.allTasks
                    .where((t) => !t.isCompleted && !isTaskInMyDay(t))
                    .toList();

                if (suggestedTasks.isEmpty) {
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

                    return ListView.separated(
                      itemCount: suggestedTasks.length,
                      separatorBuilder: (context, index) => 8.verticalSpace,
                      itemBuilder: (context, index) {
                        final task = suggestedTasks[index];
                        final listName = task.listId != null
                            ? listsMap[task.listId!] ?? AppTexts.customList
                            : AppTexts.tasks;

                        return Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: ListTile(
                            title: Text(
                              task.title,
                              style: AppTextStyle.style12W300.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.forthColor,
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
                      },
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
}
