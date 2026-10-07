import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/utils/app_icons_helper.dart';
import 'package:s/features/analytics/presentation/views/widgets/empty_analytics_state.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_management/domain/utils/task_analytics.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, tasksState) {
          if (tasksState is TasksLoading) {
            return const LoadingWidget();
          }

          if (tasksState is! TasksLoaded) {
            return Center(
              child: Text(
                AppTexts.thereIsAnError,
                style: AppTextStyle.style9W300.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            );
          }

          final tasks = tasksState.allTasks;
          if (tasks.isEmpty) {
            return const EmptyAnalyticsState();
          }

          final summary = computeSummary(tasks);

          return BlocBuilder<ListsCubit, ListsState>(
            builder: (context, listsState) {
              final listTitles = <String, String>{};
              final listIcons = <String, int?>{};
              if (listsState is ListsLoaded) {
                for (final list in listsState.lists) {
                  listTitles[list.id] = list.title;
                  listIcons[list.id] = list.iconCode;
                }
              }
              final listStats = computeListStats(tasks, listTitles);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 120.h,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => context.pop(),
                    ),
                    backgroundColor: AppColors.primaryColor,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsets.only(left: 48.w, bottom: 16.h),
                      title: Text(
                        AppTexts.analytics,
                        style: AppTextStyle.style16Bold.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      background: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor,
                              AppColors.thirdColor,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _ProductivityCard(summary: summary),
                          20.verticalSpace,
                          Row(
                            children: [
                              Expanded(
                                child: _StreakCard(
                                  icon: Icons.local_fire_department_rounded,
                                  iconColor: Colors.orange,
                                  title: 'Current Streak',
                                  value: '${summary.currentStreak}',
                                  isActive: summary.todayCompleted > 0,
                                ),
                              ),
                              16.horizontalSpace,
                              Expanded(
                                child: _StreakCard(
                                  icon: Icons.emoji_events_rounded,
                                  iconColor: Colors.amber,
                                  title: 'Best Streak',
                                  value: '${summary.bestStreak}',
                                  isActive: true,
                                ),
                              ),
                            ],
                          ),
                          32.verticalSpace,
                          Text(
                            AppTexts.overview,
                            style: AppTextStyle.style14Bold.copyWith(
                              color: AppColors.forthColor,
                            ),
                          ),
                          16.verticalSpace,
                          _OverviewGrid(summary: summary),

                          24.verticalSpace,
                          if (listStats.isNotEmpty) ...[
                            Text(
                              AppTexts.perListBreakdown,
                              style: AppTextStyle.style14Bold.copyWith(
                                color: AppColors.forthColor,
                              ),
                            ),
                            16.verticalSpace,
                            ...listStats.map(
                              (s) => _ListStatTile(
                                title: s.listId.isEmpty
                                    ? AppTexts.generalTasks
                                    : s.title,
                                stats: s,
                                icon: listIcons[s.listId] ?? 0,
                              ),
                            ),
                            40.verticalSpace,
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.summary});
  final TaskAnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 500 ? 3 : 2;

        final todayRate = summary.todayScheduled > 0
            ? ((summary.todayCompleted / summary.todayScheduled).clamp(
                        0.0,
                        1.0,
                      ) *
                      100)
                  .round()
            : 0;

        final cards = [
          _StatCard(
            label: AppTexts.total,
            value: '${summary.totalTasks}',
            icon: Icons.task_alt,
            color: AppColors.primaryColor,
          ),
          _StatCard(
            label: AppTexts.completed,
            value: '${summary.completedTasks}',
            icon: Icons.check_circle_rounded,
            color: AppColors.successColor,
          ),
          _StatCard(
            label: AppTexts.today,
            value: '${summary.todayCompleted}/${summary.todayScheduled}',
            icon: Icons.wb_sunny_rounded,
            color: Colors.amber,
          ),

          _StatCard(
            label: AppTexts.completionRate,
            value: '$todayRate${AppTexts.percent}',
            icon: Icons.trending_up_rounded,
            color: AppColors.thirdColor,
          ),

          _StatCard(
            label: AppTexts.overdue,
            value: '${summary.overdueCount}',
            icon: Icons.warning_amber_rounded,
            color: summary.overdueCount > 0
                ? Colors.redAccent
                : AppColors.successColor,
          ),
          _StatCard(
            label: AppTexts.recurring,
            value: '${summary.recurringTasks}',
            icon: Icons.repeat_rounded,
            color: Colors.blueAccent,
          ),
        ];

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
          childAspectRatio: 1.5,
          children: cards,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color.withAlpha(180), size: 24.r),
              Text(
                value,
                style: AppTextStyle.style18Bold.copyWith(
                  color: AppColors.forthColor,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: AppTextStyle.style12W500.copyWith(
              color: AppColors.secondaryColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProductivityCard extends StatelessWidget {
  const _ProductivityCard({required this.summary});
  final TaskAnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withAlpha(40),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, AppColors.thirdColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Productivity Score',
                style: AppTextStyle.style16Bold.copyWith(
                  color: Colors.white.withAlpha(210),
                ),
              ),
              8.verticalSpace,
              Text(
                'Keep up the great work!',
                style: AppTextStyle.style12W300.copyWith(
                  color: Colors.white.withAlpha(170),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 80.w,
            height: 80.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: 0,
                    end: summary.productivityScore / 100,
                  ),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return SizedBox(
                      width: 80.w,
                      height: 80.w,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withAlpha(30),
                        color: Colors.white,
                        strokeCap: StrokeCap.round,
                      ),
                    );
                  },
                ),
                Text(
                  '${summary.productivityScore.round()}%',
                  style: AppTextStyle.style20Bold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.isActive = true,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = isActive ? iconColor : Colors.grey.shade400;
    final effectiveBgColor = isActive
        ? iconColor.withAlpha(20)
        : Colors.grey.shade100;
    final effectiveValueColor = isActive
        ? AppColors.forthColor
        : Colors.grey.shade600;
    final effectiveTitleColor = isActive
        ? AppColors.secondaryColor
        : Colors.grey.shade500;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 10.r,
            color: Colors.black.withAlpha(8),
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: effectiveBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: effectiveIconColor, size: 24.r),
          ),
          12.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyle.style20Bold.copyWith(
                  color: effectiveValueColor,
                ),
              ),
              Text(
                title,
                style: AppTextStyle.style9W300.copyWith(
                  color: effectiveTitleColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ListStatTile extends StatelessWidget {
  const _ListStatTile({
    required this.icon,
    required this.title,
    required this.stats,
  });
  final int icon;
  final String title;
  final ListTaskStats stats;

  @override
  Widget build(BuildContext context) {
    final rate = (stats.completionRate * 100).round();

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 6.r,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            AppIconsHelper.getIconFromCode(icon),
            color: AppColors.primaryColor,
            size: 22.r,
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyle.style12Bold),
                Text(
                  '${stats.completedTasks} / ${stats.totalTasks} ${AppTexts.completed}',
                  style: AppTextStyle.style12W500.copyWith(
                    color: AppColors.secondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$rate${AppTexts.percent}',
            style: AppTextStyle.style9W300.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
