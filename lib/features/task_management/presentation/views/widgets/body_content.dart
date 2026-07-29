// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/utilies/tasks_state_extensions.dart';
import 'package:s/features/task_management/presentation/views/widgets/completed_tasks_section.dart';
import 'package:s/features/task_management/presentation/views/widgets/empty_tasks_state.dart';
import 'package:s/features/task_management/presentation/views/widgets/task_item_widget.dart';

class BodyContent extends StatelessWidget {
  const BodyContent({
    required this.state,
    required this.currentTasks,
    required this.context,
    super.key,
  });

  final TasksState state;
  final List<TaskEntity> currentTasks;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    if (state is TasksLoading) {
      return SizedBox(
        height: 450.h,
        child: const Center(child: LoadingWidget()),
      );
    } else if (state is TasksLoaded) {
      if (currentTasks.isEmpty) {
        return SizedBox(
          height: SizeConfig.screenHeight / 2 + 100,
          child: const EmptyTasksState(),
        );
      }

      final isCompletedFilter = state.currentFilter == TaskFilter.completed;

      final activeTasks = currentTasks.where((t) => !t.isCompleted).toList();
      final completedTasks = currentTasks.where((t) => t.isCompleted).toList();

      if (isCompletedFilter) {
        return CompletedTasksSection(tasks: completedTasks);
      }

      return Column(
        children: [
          if (activeTasks.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              itemCount: activeTasks.length,
              onReorder: (oldIndex, newIndex) {
                unawaited(
                  context.read<TasksCubit>().reorderTasks(
                    oldIndex,
                    newIndex,
                    List.from(
                      activeTasks,
                    ),
                  ),
                );
              },
              itemBuilder: (context, index) {
                return TaskItemWidget(
                  key: ValueKey(activeTasks[index].id),
                  task: activeTasks[index],
                );
              },
            ),

          if (completedTasks.isNotEmpty)
            CompletedTasksSection(
              tasks: completedTasks,
              compact: true,
            ),
          24.verticalSpace,
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
