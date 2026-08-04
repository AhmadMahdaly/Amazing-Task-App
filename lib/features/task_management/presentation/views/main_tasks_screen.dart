// ignore_for_file: no_default_cases

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/functions/navigation_preferences.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/suggestions_bottom_sheet.dart';
import 'package:s/features/task_management/presentation/views/widgets/add_task_bottom_sheet.dart';
import 'package:s/features/task_management/presentation/views/widgets/body_content.dart';
import 'package:s/features/task_management/presentation/views/widgets/tasks_drawer.dart';

class MainTasksScreen extends StatelessWidget {
  const MainTasksScreen({super.key});

  Map<String, BottomNavItemData> _getNavData(BuildContext context) {
    return {
      'myDay': BottomNavItemData(
        icon: Icons.wb_sunny_outlined,
        label: AppTexts.myDay,
        onTap: () => context.read<TasksCubit>().loadTasks(
          filter: TaskFilter.myDay,
          title: AppTexts.myDay,
        ),
      ),
      'important': BottomNavItemData(
        icon: Icons.star_border,
        label: AppTexts.important,
        onTap: () => context.read<TasksCubit>().loadTasks(
          filter: TaskFilter.important,
          title: AppTexts.important,
        ),
      ),
      'planned': BottomNavItemData(
        icon: Icons.calendar_today,
        label: AppTexts.planned,
        onTap: () => context.read<TasksCubit>().loadTasks(
          filter: TaskFilter.planned,
          title: AppTexts.planned,
        ),
      ),
      'tasks': BottomNavItemData(
        icon: Icons.home_outlined,
        label: AppTexts.tasks,
        onTap: () => context.read<TasksCubit>().loadTasks(
          filter: TaskFilter.allTasks,
          title: AppTexts.tasks,
        ),
      ),
      'aiTracker': BottomNavItemData(
        icon: Icons.auto_awesome_rounded,
        label: 'AI Tracker',
        onTap: () => context.pushNamed(AppRoutes.aiTrackerMainView),
      ),
      'challenges': BottomNavItemData(
        icon: Icons.add_task_rounded,
        label: 'Challenges',
        onTap: () => context.pushNamed(AppRoutes.challengesScreen),
      ),
      'islamic': BottomNavItemData(
        icon: Icons.mosque_outlined,
        label: AppTexts.islamicSection,
        onTap: () => context.pushNamed(AppRoutes.islamicHomeView),
      ),
      'notes': BottomNavItemData(
        icon: Icons.book_outlined,
        label: AppTexts.myNote,
        onTap: () => context.pushNamed(AppRoutes.noteView),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: NavigationPreferences.navItemsNotifier,
      builder: (context, userNavKeys, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = SizeConfig.isTablet;
            final navMap = _getNavData(context);

            final activeNavItems = userNavKeys
                .where(navMap.containsKey)
                .map((k) => navMap[k]!)
                .toList();

            return BlocBuilder<WallpaperCubit, WallpaperState>(
              builder: (context, wallpaperState) {
                return Scaffold(
                  resizeToAvoidBottomInset: false,
                  backgroundColor: wallpaperState.settings.hasWallpaper
                      ? Colors.transparent
                      : AppColors.primaryColor,
                  drawer: isTablet ? null : const TasksDrawer(),
                  bottomNavigationBar: !isTablet && activeNavItems.length > 1
                      ? BlocBuilder<TasksCubit, TasksState>(
                          builder: (context, tasksState) {
                            return BottomNavigationBar(
                              backgroundColor: AppColors.forthColor,
                              selectedItemColor: AppColors.white,
                              unselectedItemColor: AppColors.white.withAlpha(
                                170,
                              ),
                              type: BottomNavigationBarType.fixed,
                              currentIndex: _getCurrentSelectedIndex(
                                activeNavItems,
                                tasksState,
                              ),
                              onTap: (index) => activeNavItems[index].onTap(),
                              items: activeNavItems
                                  .map(
                                    (e) => BottomNavigationBarItem(
                                      icon: Icon(e.icon),
                                      label: e.label,
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        )
                      : null,
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

                        final mainContent = RefreshIndicator(
                          onRefresh: () async {
                            await context.read<TasksCubit>().loadTasks();
                          },
                          child: CustomScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            slivers: [
                              SliverAppBar(
                                expandedHeight: 110.h,
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                scrolledUnderElevation: 0,
                                surfaceTintColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                floating: true,
                                pinned: true,
                                actions: [
                                  if (state is TasksLoaded &&
                                      state.currentFilter == TaskFilter.myDay)
                                    IconButton(
                                      tooltip: AppTexts.daySchedule,
                                      icon: Icon(
                                        Icons.mosque,
                                        color: AppColors.white,
                                        size: 24.r,
                                      ),
                                      onPressed: () async {
                                        await context.pushNamed(
                                          AppRoutes.islamicHomeView,
                                        );
                                      },
                                    ),
                                  12.horizontalSpace,
                                ],
                                flexibleSpace: FlexibleSpaceBar(
                                  title:
                                      state is TasksLoaded &&
                                          state.currentFilter ==
                                              TaskFilter.myDay
                                      ? Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              screenTitle,
                                              style: AppTextStyle.style18Bold
                                                  .copyWith(
                                                    color: AppColors.white,
                                                  ),
                                            ),
                                            Text(
                                              formatFullDate(DateTime.now()),
                                              style: AppTextStyle.style12W400
                                                  .copyWith(
                                                    color: AppColors.white,
                                                  ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          screenTitle,
                                          style: AppTextStyle.style18Bold
                                              .copyWith(
                                                color: AppColors.white,
                                              ),
                                        ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: BodyContent(
                                  state: state,
                                  currentTasks: currentTasks,
                                  context: context,
                                ),
                              ),
                            ],
                          ),
                        );

                        if (isTablet) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: constraints.maxWidth * 0.4,
                                child: const TasksDrawer(isPermanent: true),
                              ),
                              Expanded(child: mainContent),
                            ],
                          );
                        }

                        return mainContent;
                      },
                    ),
                  ),
                  floatingActionButton: BlocBuilder<TasksCubit, TasksState>(
                    builder: (context, state) {
                      var isMyDay = false;
                      String? listId;

                      if (state is TasksLoaded) {
                        isMyDay = state.currentFilter == TaskFilter.myDay;
                        if (state.currentFilter == TaskFilter.customList) {
                          listId = state.currentListId;
                        }
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FloatingActionButton(
                            heroTag: 'my_notes_fab',
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(320.r),
                            ),
                            onPressed: () async {
                              await context.pushNamed(AppRoutes.noteView);
                            },
                            backgroundColor: AppColors.white,
                            child: Icon(
                              Icons.book_outlined,
                              size: 24.r,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          24.horizontalSpace,
                          if (isMyDay) ...[
                            FloatingActionButton.extended(
                              heroTag: 'suggestions_fab',
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(320.r),
                              ),
                              onPressed: () async {
                                await showModalBottomSheet<void>(
                                  context: context,
                                  isScrollControlled: true,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) =>
                                      const SuggestionsBottomSheet(),
                                );
                              },
                              backgroundColor: AppColors.white,
                              label: Text(
                                AppTexts.suggestions,
                                style: AppTextStyle.style12W400.copyWith(
                                  fontSize: 10.sp,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              icon: Icon(
                                Icons.lightbulb_outline,
                                size: 22.r,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            16.horizontalSpace,
                          ],

                          FloatingActionButton(
                            heroTag: 'add_task_fab',
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(320.r),
                            ),
                            onPressed: () async {
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
                            backgroundColor: AppColors.white,
                            child: Icon(
                              Icons.add,
                              size: 28.r,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  int _getCurrentSelectedIndex(
    List<BottomNavItemData> activeItems,
    TasksState tasksState,
  ) {
    if (tasksState is TasksLoaded) {
      var index = 0;
      switch (tasksState.currentFilter) {
        case TaskFilter.myDay:
          index = activeItems.indexWhere((e) => e.label == AppTexts.myDay);
        case TaskFilter.important:
          index = activeItems.indexWhere((e) => e.label == AppTexts.important);
        case TaskFilter.planned:
          index = activeItems.indexWhere((e) => e.label == AppTexts.planned);
        case TaskFilter.allTasks:
          index = activeItems.indexWhere((e) => e.label == AppTexts.tasks);
        default:
          index = 0;
      }
      return index >= 0 ? index : 0;
    }
    return 0;
  }
}

class BottomNavItemData {
  BottomNavItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}
