import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_version_widget.dart';
import 'package:s/core/utils/app_icons_helper.dart';
import 'package:s/core/wallpaper/wallpaper_picker_sheet.dart';
import 'package:s/features/task_list/domain/entities/task_list_entity.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_list/presentation/views/add_list_bottom_sheet.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/customize_nav_bar_sheet.dart';

class TasksDrawer extends StatelessWidget {
  const TasksDrawer({super.key, this.isPermanent = false});
  final bool isPermanent;
  @override
  Widget build(BuildContext context) {
    final isTablet = SizeConfig.isTablet;
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
                // TaskAnalyticsSummary? summary;
                if (state is TasksLoaded) {
                  final tasks = state.allTasks;
                  final todayTasks = tasks.where(isTaskInMyDay).toList();

                  totalToday = todayTasks.length;
                  completedToday = todayTasks
                      .where((t) => t.isCompleted)
                      .length;

                  if (totalToday > 0) {
                    progress = completedToday / totalToday;
                  }
                  // summary = computeSummary(tasks);
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
                              // Center(
                              //   child: Text(
                              //     summary?.currentStreak.toString() ?? '0',
                              //     style: AppTextStyle.style16Bold.copyWith(
                              //       fontSize: 20.sp,
                              //       color: AppColors.white,
                              //     ),
                              //   ),
                              // ),
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

            // _buildDrawerItem(
            //   icon: Icons.access_time,
            //   title: AppTexts.daySchedule,
            //   count: context.select<TasksCubit, String>((cubit) {
            //     final state = cubit.state;
            //     if (state is TasksLoaded) {
            //       final count = state.allTasks
            //           .where(isTaskInMyDay)
            //           .where((t) => !t.isCompleted)
            //           .length;
            //       return count > 0 ? '$count' : '';
            //     }
            //     return '';
            //   }),
            //   context: context,
            //   onTap: () {
            //     unawaited(context.pushNamed(AppRoutes.dayScheduleScreen));
            //   },
            // ),
            _buildDrawerItem(
              icon: Icons.wb_sunny_outlined,
              title: AppTexts.myDay,
              count: context.select<TasksCubit, String>((cubit) {
                final state = cubit.state;
                if (state is TasksLoaded) {
                  final myDayCount = state.allTasks
                      .where(isTaskInMyDay)
                      .where((t) => !t.isCompleted)
                      .length;
                  return myDayCount > 0 ? '$myDayCount' : '';
                }
                return '';
              }),
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
              count: context.select<TasksCubit, String>((cubit) {
                final state = cubit.state;
                if (state is TasksLoaded) {
                  final importantCount = state.allTasks
                      .where((t) => t.isImportant)
                      .where((t) => !t.isCompleted)
                      .length;
                  return importantCount > 0 ? '$importantCount' : '';
                }
                return '';
              }),
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
              count: context.select<TasksCubit, String>((cubit) {
                final state = cubit.state;
                if (state is TasksLoaded) {
                  final plannedCount = state.allTasks
                      .where((t) => t.dueDate != null)
                      .where((t) => !t.isCompleted)
                      .length;
                  return plannedCount > 0 ? '$plannedCount' : '';
                }
                return '';
              }),
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
              count: context.select<TasksCubit, String>((cubit) {
                final state = cubit.state;
                if (state is TasksLoaded) {
                  final allCount = state.allTasks
                      .where((t) => t.listId == null)
                      .where((t) => !t.isCompleted)
                      .length;
                  return allCount > 0 ? '$allCount' : '';
                }
                return '';
              }),
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
                builder: (context, listsState) {
                  if (listsState is ListsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (listsState is ListsError) {
                    return Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        listsState.message,
                        style: AppTextStyle.style9W300.copyWith(
                          color: AppColors.errorColor,
                        ),
                      ),
                    );
                  } else if (listsState is ListsLoaded) {
                    if (listsState.lists.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return BlocBuilder<TasksCubit, TasksState>(
                      builder: (context, tasksState) {
                        final allTasks = tasksState is TasksLoaded
                            ? tasksState.allTasks
                            : <TaskEntity>[];

                        return ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: listsState.lists.length,
                          itemBuilder: (context, index) {
                            final list = listsState.lists[index];
                            final activeTasksCount = allTasks
                                .where(
                                  (t) => t.listId == list.id && !t.isCompleted,
                                )
                                .length;

                            return _buildCustomListTile(
                              context,
                              list,
                              activeTasksCount,
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // Divider(color: AppColors.white.withAlpha(55)),
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
                  showDragHandle: true,
                  backgroundColor: AppColors.white,
                  builder: (ctx) => const AddListBottomSheet(),
                );
              },
            ),
            Divider(color: AppColors.white.withAlpha(40)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                8.horizontalSpace,

                SpeedDial(
                  icon: Icons.settings,
                  iconTheme: IconThemeData(
                    color: AppColors.buttonColor.withAlpha(100),
                  ),
                  switchLabelPosition: true,
                  activeIcon: Icons.close_rounded,
                  backgroundColor: AppColors.transparent,
                  spacing: 10,
                  spaceBetweenChildren: 10,
                  elevation: 0,
                  mini: true,
                  activeForegroundColor: AppColors.transparent,
                  // activeBackgroundColor: AppColors.buttonColor,
                  overlayColor: AppColors.buttonColor,
                  overlayOpacity: .4,

                  direction: SpeedDialDirection.up,
                  animationCurve: Curves.easeOutBack,
                  animationDuration: const Duration(milliseconds: 250),
                  children: [
                    SpeedDialChild(
                      child: const Icon(Icons.restart_alt),
                      label: AppTexts.backupAndRestore,
                      onTap: () async {
                        await context.pushNamed(AppRoutes.backupScreen);
                      },
                    ),

                    if (!isTablet)
                      SpeedDialChild(
                        child: const Icon(Icons.edit_attributes_outlined),
                        label: 'Customize NavBar Sheet',
                        onTap: () async {
                          await Future.delayed(
                            const Duration(milliseconds: 300),
                          );
                          if (!context.mounted) return;
                          if (!isPermanent) {
                            Navigator.pop(context);
                          }
                          await showModalBottomSheet<void>(
                            context: context,
                            isScrollControlled: true,
                            showDragHandle: true,
                            backgroundColor: AppColors.white,
                            builder: (context) => const CustomizeNavBarSheet(),
                          );
                        },
                      ),

                    SpeedDialChild(
                      child: const Icon(Icons.wallpaper_outlined),
                      label: 'Change wallpaper',
                      onTap: () async {
                        await showWallpaperPickerSheet(context);
                      },
                    ),

                    // SpeedDialChild(
                    //   child: const Icon(Icons.auto_awesome_rounded),
                    //   label: 'AI Tracker',
                    //   onTap: () async {
                    //     await context.pushNamed(AppRoutes.aiTrackerMainView);
                    //   },
                    // ),
                  ],
                ),
                // if (isTablet)
                //   IconButton(
                //     tooltip: 'Change wallpaper',
                //     icon: const Icon(Icons.wallpaper_outlined),
                //     onPressed: () async {
                //       await showWallpaperPickerSheet(context);
                //     },
                //   ),
                IconButton(
                  tooltip: 'Add Challenge',
                  icon: const Icon(Icons.add_task_rounded),
                  onPressed: () async {
                    await context.pushNamed(AppRoutes.challengesScreen);
                  },
                ),
                IconButton(
                  tooltip: 'Open a planner',
                  icon: const Icon(Icons.calendar_month_outlined),
                  onPressed: () async {
                    await context.pushNamed(AppRoutes.plannerView);
                  },
                ),
                IconButton(
                  tooltip: AppTexts.islamicSection,
                  icon: const Icon(Icons.mosque_outlined),
                  onPressed: () async {
                    await context.pushNamed(AppRoutes.islamicHomeView);
                  },
                ),
              ],
            ),
            const AppVersionWidget(), 12.verticalSpace,
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
    int activeTasksCount,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            20.horizontalSpace,

            Icon(
              AppIconsHelper.getIconFromCode(list.iconCode),
              color: Colors.white,
              size: 24.r,
            ),
            16.horizontalSpace,
            Expanded(
              child: Text(
                overflow: TextOverflow.fade,
                softWrap: true,
                list.title,
                style: AppTextStyle.style12W300.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.white,
                ),
              ),
            ),
            if (activeTasksCount > 0)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 2.h,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withAlpha(50),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '$activeTasksCount',
                  style: AppTextStyle.style9W300.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
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
                  child: Text(
                    AppTexts.edit,
                    style: AppTextStyle.style9W300,
                  ),
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

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
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
