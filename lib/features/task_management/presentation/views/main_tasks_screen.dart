import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/widgets/add_task_bottom_sheet.dart';
import 'package:s/features/task_management/presentation/views/widgets/task_item_widget.dart';
import 'package:s/features/task_management/presentation/views/widgets/tasks_drawer.dart';

class MainTasksScreen extends StatelessWidget {
  const MainTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = SizeConfig.isTablet;

        return Scaffold(
          backgroundColor: AppColors.scaffoldBackgroundLightColor,

          drawer: isTablet ? null : const TasksDrawer(),

          body: BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              var screenTitle = AppTexts.loading;
              var currentTasks = <TaskEntity>[];

              if (state is TasksLoaded) {
                screenTitle = state.title;
                currentTasks = state.tasks;
              } else if (state is TasksError) {
                screenTitle = AppTexts.thereIsAnError;
              }

              final mainContent = CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 150.h,
                    floating: false,
                    pinned: true,
                    backgroundColor: AppColors.primaryColor,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        screenTitle,
                        style: AppTextStyle.style9W300.copyWith(
                          fontSize: 22.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.thirdColor,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildBodyContent(state, currentTasks, context),
                  ),
                ],
              );

              if (isTablet) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: constraints.maxWidth * 0.4,
                      child: const TasksDrawer(isPermanent: true),
                    ),

                    Expanded(
                      child: mainContent,
                    ),
                  ],
                );
              }

              return mainContent;
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final currentState = context.read<TasksCubit>().state;
              var isMyDay = false;
              String? listId;

              if (currentState is TasksLoaded) {
                isMyDay = currentState.currentFilter == TaskFilter.myDay;
                listId = currentState.currentListId;
              }

              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => AddTaskBottomSheet(
                  isMyDayView: isMyDay,
                  currentListId: listId,
                ),
              );
            },
            backgroundColor: AppColors.primaryColor,
            child: Icon(Icons.add, size: 28.r, color: Colors.white),
          ),
        );
      },
    );
  }

  Widget _buildBodyContent(
    TasksState state,
    List<TaskEntity> currentTasks,
    BuildContext context,
  ) {
    if (state is TasksLoading) {
      return SizedBox(
        height: 300.h,
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (state is TasksLoaded) {
      if (currentTasks.isEmpty) {
        return SizedBox(
          height: 300.h,
          child: Center(
            child: Text(
              AppTexts.noTasksInThisList,
              style: AppTextStyle.style9W300,
            ),
          ),
        );
      }

      final activeTasks = currentTasks.where((t) => !t.isCompleted).toList();
      final completedTasks = currentTasks.where((t) => t.isCompleted).toList();

      return Column(
        children: [
          if (activeTasks.isNotEmpty)
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: activeTasks.length,
              onReorder: (oldIndex, newIndex) async {
                await context.read<TasksCubit>().reorderTasks(
                  oldIndex,
                  newIndex,
                  activeTasks,
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
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: false,
                iconColor: AppColors.secondaryColor,
                collapsedIconColor: AppColors.secondaryColor,
                title: Text(
                  '${AppTexts.completed}  ${completedTasks.length}',
                  style: AppTextStyle.style9W300.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.secondaryColor,
                  ),
                ),
                childrenPadding: EdgeInsets.symmetric(horizontal: 16.w),
                children: completedTasks
                    .map((t) => TaskItemWidget(key: ValueKey(t.id), task: t))
                    .toList(),
              ),
            ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
