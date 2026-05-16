import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/widgets/add_task_bottom_sheet.dart';
import 'package:s/features/task_management/presentation/views/widgets/completed_tasks_section.dart';
import 'package:s/features/task_management/presentation/views/widgets/task_item_widget.dart';
import 'package:s/features/task_management/presentation/views/widgets/tasks_drawer.dart';

class MainTasksScreen extends StatelessWidget {
  const MainTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = SizeConfig.isTablet;

        return BlocBuilder<WallpaperCubit, WallpaperState>(
          builder: (context, wallpaperState) {
            return Scaffold(
              backgroundColor: wallpaperState.settings.hasWallpaper
                  ? Colors.transparent
                  : AppColors.scaffoldBackgroundLightColor,
              drawer: isTablet ? null : const TasksDrawer(),
              body: AppWallpaper(
                settings: wallpaperState.settings,
                child: BlocBuilder<TasksCubit, TasksState>(
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
                    expandedHeight: 110.h,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: state is TasksLoaded &&
                              state.currentFilter == TaskFilter.myDay
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  screenTitle,
                                  style: AppTextStyle.style18Bold.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  formatFullDate(DateTime.now()),
                                  style: AppTextStyle.style12W400.copyWith(
                                    color: Colors.white.withAlpha(200),
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              screenTitle,
                              style: AppTextStyle.style18Bold.copyWith(
                                color: Colors.white,
                              ),
                            ),
                      // background: Container(
                      //   decoration: const BoxDecoration(
                      //     gradient: LinearGradient(
                      //       colors: [
                      //         AppColors.primaryColor,
                      //         AppColors.thirdColor,
                      //       ],
                      //       begin: Alignment.topCenter,
                      //       end: Alignment.bottomCenter,
                      //     ),
                      //   ),
                      // ),
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
              ),
              floatingActionButton: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(320.r),
            ),
            onPressed: () async {
              final currentState = context.read<TasksCubit>().state;
              var isMyDay = false;
              String? listId;

              if (currentState is TasksLoaded) {
                isMyDay = currentState.currentFilter == TaskFilter.myDay;
                if (currentState.currentFilter == TaskFilter.customList) {
                  listId = currentState.currentListId;
                }
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
