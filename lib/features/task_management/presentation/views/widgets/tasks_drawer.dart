import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/utils/app_icons_helper.dart';
import 'package:s/core/wallpaper/wallpaper_picker_sheet.dart';
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
                                backgroundColor: AppColors.white.withAlpha(
                                  33,
                                ),
                                color: AppColors.white,
                              ),
                              Center(
                                child: Icon(
                                  Icons.auto_graph,
                                  color: AppColors.white,
                                  size: 20.r,
                                ),
                              ),
                            ],
                          ),
                        ),
                        20.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppTexts.todayProgress,
                                style: AppTextStyle.style12Bold.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                              4.verticalSpace,
                              Text(
                                totalToday == 0
                                    ? AppTexts.noTasksToday
                                    : '${AppTexts.completedTasks} $completedToday ${AppTexts.of} $totalToday',
                                style: AppTextStyle.style9W300.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: AppColors.white.withAlpha(180),
                          size: 22.r,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Divider(color: AppColors.white.withAlpha(77)),

            _buildDrawerItem(
              icon: Icons.wb_sunny_outlined,
              title: AppTexts.myDay,

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
                          color: AppColors.errorColor,
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
                            color: AppColors.white.withAlpha(128),
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
            Row(
              children: [
                8.horizontalSpace,
                IconButton(
                  icon: const Icon(Icons.wallpaper_outlined),
                  onPressed: () {
                    unawaited(showWallpaperPickerSheet(context));
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.add_task_rounded),
                  onPressed: () async {
                    await context.pushNamed(AppRoutes.challengesScreen);
                  },
                ),
              ],
            ),
            Divider(color: AppColors.white.withAlpha(55)),

            _buildDrawerItem(
              icon: Icons.add,
              title: AppTexts.newList,
              iconColor: AppColors.white,
              textColor: AppColors.white,
              isBold: true,
              context: context,
              onTap: () async {
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
        color: iconColor ?? AppColors.white,
        size: 24.r,
      ),
      title: Text(
        title,
        style: AppTextStyle.style12W300.copyWith(
          fontSize: 10.sp,
          color: textColor ?? AppColors.white,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: count != null
          ? Text(
              count,
              style: AppTextStyle.style9W300.copyWith(
                color: AppColors.white,
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
        leading: Icon(
          AppIconsHelper.getIconFromCode(list.iconCode),
          color: Colors.white,
          size: 24.r,
        ),
        title: Text(
          list.title,
          style: AppTextStyle.style12W300.copyWith(
            fontSize: 10.sp,
            color: AppColors.white,
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
            color: AppColors.white.withAlpha(75),
          ),
          color: AppColors.white,
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
              child: Text(AppTexts.edit, style: AppTextStyle.style9W300),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text(
                AppTexts.delete,
                style: AppTextStyle.style9W300.copyWith(
                  color: AppColors.errorColor,
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
        title: Text(AppTexts.deleteList, style: AppTextStyle.style12Bold),
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
                color: AppColors.errorColor,
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
    final viewingDeletedList =
        stateBefore is TasksLoaded &&
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
          style: AppTextStyle.style12W300.copyWith(color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
