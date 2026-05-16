import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/wallpaper/wallpaper_picker_sheet.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/features/task_list/domain/entities/task_list_entity.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_list/presentation/views/add_list_bottom_sheet.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class TasksDrawer extends StatelessWidget {
  const TasksDrawer({super.key, this.isPermanent = false});
  final bool isPermanent;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.forthColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      shadowColor: Colors.transparent,
      clipBehavior: Clip.none,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                var progress = 0.0;
                var completedToday = 0;
                var totalToday = 0;

                if (state is TasksLoaded) {
                  final todayTasks = state.allTasks
                      .where(isTaskInMyDay)
                      .toList();

                  totalToday = todayTasks.length;
                  completedToday = todayTasks
                      .where((t) => t.isCompleted)
                      .length;

                  if (totalToday > 0) {
                    progress = completedToday / totalToday;
                  }
                }

                return InkWell(
                  onTap: () {
                    if (!isPermanent) {
                      Navigator.pop(context);
                    }
                    unawaited(context.push(AppRoutes.analyticsScreen));
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 20.h,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 45.r,
                          height: 45.r,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 4.r,
                                backgroundColor: AppColors.secondaryColor
                                    .withAlpha(33),
                                color: Colors.white,
                              ),
                              Center(
                                child: Icon(
                                  Icons.auto_graph,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTexts.todayProgress,
                                style: AppTextStyle.style9W300.copyWith(
                                  fontSize: 16.sp,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                totalToday == 0
                                    ? AppTexts.noTasksToday
                                    : '${AppTexts.completedTasks} $completedToday ${AppTexts.of} $totalToday',
                                style: AppTextStyle.style9W300.copyWith(
                                  fontSize: 11.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Colors.white.withAlpha(180),
                          size: 22.r,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Divider(color: Colors.white.withAlpha(77)),

            _buildDrawerItem(
              icon: Icons.wb_sunny_outlined,
              title: AppTexts.myDay,
              count: state.myDayTasks.length.toString(),
              context: context,
              onTap: () async {
                await context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.myDay,
                  title: AppTexts.myDay,
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.star_border,
              title: AppTexts.important,
              count: state.importantTasks.length.toString(),
              context: context,
              onTap: () async {
                await context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.important,
                  title: AppTexts.important,
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              title: AppTexts.planned,
              count: state.plannedTasks.length.toString(),
              context: context,
              onTap: () async {
                await context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.planned,
                  title: AppTexts.planned,
                );
              },
            ),
            // _buildDrawerItem(
            //   icon: Icons.task_alt,
            //   title: AppTexts.completed,
            //   context: context,
            //   onTap: () async {
            //     await context.read<TasksCubit>().loadTasks(
            //       filter: TaskFilter.completed,
            //       title: AppTexts.completed,
            //     );
            //   },
            // ),
            _buildDrawerItem(
              icon: Icons.home_outlined,
              title: AppTexts.tasks,
              count: state.allTasks.length.toString(),
              context: context,
              onTap: () async {
                await context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.allTasks,
                  title: AppTexts.tasks,
                );
              },
            ),

            // _buildDrawerItem(
            //   icon: Icons.bar_chart,
            //   title: AppTexts.analytics,
            //   context: context,
            //   onTap: () {
            //     unawaited(context.push(AppRoutes.analyticsScreen));
            //   },
            // ),
          
            Divider(color: AppColors.secondaryColor.withAlpha(77)),

            Expanded(
              child: BlocBuilder<ListsCubit, ListsState>(
                builder: (context, state) {
                  if (state is ListsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ListsError) {
                    return Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        state.message,
                        style: AppTextStyle.style9W300.copyWith(
                          color: Colors.redAccent,
                        ),
                      ),
                    );
                  } else if (state is ListsLoaded) {
                    if (state.lists.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        child: Text(
                          AppTexts.noCustomListsYet,
                          style: AppTextStyle.style9W300.copyWith(
                            color: Colors.white.withAlpha(128),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: state.lists.length,
                      itemBuilder: (context, index) {
                        final list = state.lists[index];

                        return _buildCustomListTile(context, list);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
  IconButton(
              icon: Icons.wallpaper_outlined,
              onPressed: () {
                unawaited(showWallpaperPickerSheet(context));
              },
            ),
            Divider(color: Colors.white.withAlpha(55)),

            _buildDrawerItem(
              icon: Icons.add,
              title: AppTexts.newList,
              iconColor: Colors.white,
              textColor: Colors.white,
              isBold: true,
              context: context,
              onTap: () async {
                if (!SizeConfig.isTablet) {
                  Navigator.pop(context);
                }
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const AddListBottomSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BuildContext context,
    String? count,
    Color? iconColor,
    Color? textColor,
    bool isBold = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.white,
        size: 24.r,
      ),
      title: Text(
        title,
        style: AppTextStyle.style12W300.copyWith(
          color: textColor ?? Colors.white,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: count != null
          ? Text(
              count,
              style: AppTextStyle.style9W300.copyWith(
                color: Colors.white,
              ),
            )
          : null,
      onTap: () {
        if (!isPermanent) {
          Navigator.pop(context);
        }

        onTap();
      },
    );
  }

  Widget _buildCustomListTile(
    BuildContext context,
    TaskListEntity list,
  ) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(Icons.list, color: Colors.white, size: 24.r),
        title: Text(
          list.title,
          style: AppTextStyle.style12W300.copyWith(
            color: Colors.white,
          ),
        ),
        trailing: Text(
          list.tasks.length.toString(),
          style: AppTextStyle.style9W300.copyWith(
            color: Colors.white,
          ),
        ),
        onTap: () {
          if (!isPermanent) {
            Navigator.pop(context);
          }
          unawaited(
            context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.customList,
                  title: list.title,
                  customListId: list.id,
                ),
          );
        },
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white.withAlpha(204),
          ),
          color: AppColors.scaffoldBackgroundLightColor,
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                if (!SizeConfig.isTablet) {
                  Navigator.pop(context);
                }
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => AddListBottomSheet(listToEdit: list),
                );
              case 'delete':
                await _confirmDeleteCustomList(
                  context,
                  list: list,
                );
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'edit',
              child: Text(AppTexts.edit, style: AppTextStyle.style12W300),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                AppTexts.delete,
                style: AppTextStyle.style12W300.copyWith(
                  color: Colors.redAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCustomList(
    BuildContext context, {
    required TaskListEntity list,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppTexts.deleteList,
          style: AppTextStyle.style14W300.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppTexts.confirmDeleteList,
          style: AppTextStyle.style12W300,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(AppTexts.cancel, style: AppTextStyle.style12W300),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              AppTexts.delete,
              style: AppTextStyle.style12W300.copyWith(
                color: Colors.redAccent,
              ),
            ),
          ),
        ],
      ),
    );

    if (!(confirmed ?? false) || !context.mounted) return;

    final tasksCubit = context.read<TasksCubit>();
    final listsCubit = context.read<ListsCubit>();
    final messenger = ScaffoldMessenger.of(context);

    final stateBefore = tasksCubit.state;
    final viewingDeletedList = stateBefore is TasksLoaded &&
        stateBefore.currentFilter == TaskFilter.customList &&
        stateBefore.currentListId == list.id;

    if (viewingDeletedList) {
      await tasksCubit.loadTasks(
        filter: TaskFilter.myDay,
        title: AppTexts.myDay,
      );
    }

    if (!isPermanent) {
      Navigator.pop(context);
    }

    await tasksCubit.deleteTasksForList(list.id);
    await listsCubit.deleteList(list.id);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          AppTexts.listDeleted,
          style: AppTextStyle.style12W300.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
