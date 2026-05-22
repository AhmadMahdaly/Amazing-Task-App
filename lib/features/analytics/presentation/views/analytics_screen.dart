import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/utils/app_icons_helper.dart';
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
      backgroundColor: AppColors.white,
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, tasksState) {
          if (tasksState is TasksLoading) {
            return const Center(child: CircularProgressIndicator());
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
            return _buildEmptyState(context);
          }

          final summary = computeSummary(tasks);
          final dailyStats = computeDailyStats(tasks);
          final monthlyStats = computeMonthlyStats(tasks);

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
                    expandedHeight: 100.h,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    backgroundColor: AppColors.primaryColor,
                    flexibleSpace: FlexibleSpaceBar(
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
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.overview,
                            style: AppTextStyle.style14Bold.copyWith(
                              color: AppColors.forthColor,
                            ),
                          ),
                          12.verticalSpace,
                          _OverviewGrid(summary: summary),
                          20.verticalSpace,
                          TabBar(
                            controller: _tabController,
                            labelColor: AppColors.primaryColor,
                            unselectedLabelColor: AppColors.secondaryColor,
                            indicatorColor: AppColors.primaryColor,
                            labelStyle: AppTextStyle.style12W700,
                            tabs: [
                              Tab(text: AppTexts.dailyStats),
                              Tab(text: AppTexts.monthlyStats),
                            ],
                          ),
                          16.verticalSpace,
                          SizedBox(
                            height: 400.h,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _DailyStatsPanel(stats: dailyStats),
                                _MonthlyStatsPanel(stats: monthlyStats),
                              ],
                            ),
                          ),
                          20.verticalSpace,
                          Text(
                            AppTexts.perListBreakdown,
                            style: AppTextStyle.style14W700.copyWith(
                              color: AppColors.forthColor,
                            ),
                          ),
                          12.verticalSpace,
                          ...listStats.map(
                            (s) => _ListStatTile(
                              title: s.listId.isEmpty
                                  ? AppTexts.generalTasks
                                  : s.title,
                              stats: s,
                              icon: listIcons[s.listId] ?? 0,
                            ),
                          ),
                          32.verticalSpace,
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

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          title: Text(AppTexts.analytics, style: AppTextStyle.style9W300),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Text(
                AppTexts.noAnalyticsData,
                textAlign: TextAlign.center,
                style: AppTextStyle.style14W300.copyWith(
                  color: AppColors.secondaryColor,
                ),
              ),
            ),
          ),
        ),
      ],
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
        final cards = [
          _StatCard(
            label: AppTexts.total,
            value: '${summary.totalTasks}',
            icon: Icons.task_alt,
          ),
          _StatCard(
            label: AppTexts.completed,
            value: '${summary.completedTasks}',
            icon: Icons.check_circle_outline,
          ),
          _StatCard(
            label: AppTexts.today,
            value: '${summary.todayCompleted}/${summary.todayScheduled}',
            icon: Icons.wb_sunny_outlined,
          ),
          _StatCard(
            label: AppTexts.completionRate,
            value:
                '${(summary.todayCompletionRate * 100).round()}${AppTexts.percent}',
            icon: Icons.trending_up,
          ),
          _StatCard(
            label: AppTexts.overdue,
            value: '${summary.overdueCount}',
            icon: Icons.warning_amber_outlined,
            accent: summary.overdueCount > 0 ? Colors.orange : null,
          ),
          _StatCard(
            label: AppTexts.recurring,
            value: '${summary.recurringTasks}',
            icon: Icons.repeat,
          ),
        ];

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 1.4,
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
    this.accent,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: accent ?? AppColors.primaryColor, size: 22.r),
          Text(
            value,
            textAlign: TextAlign.center,
            style: AppTextStyle.style16Bold.copyWith(
              color: AppColors.forthColor,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 11.sp,
              color: AppColors.secondaryColor,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DailyStatsPanel extends StatelessWidget {
  const _DailyStatsPanel({required this.stats});

  final List<DayTaskStats> stats;

  @override
  Widget build(BuildContext context) {
    final maxCompleted = stats
        .map((s) => s.completedCount)
        .fold(0, (a, b) => a > b ? a : b);
    final maxValue = maxCompleted > 0 ? maxCompleted : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.last14Days,
          style: AppTextStyle.style12W300.copyWith(
            color: AppColors.secondaryColor,
          ),
        ),
        8.verticalSpace,
        _LegendRow(),
        12.verticalSpace,
        Expanded(
          child: ListView.separated(
            itemCount: stats.length,
            separatorBuilder: (context, index) => 8.verticalSpace,
            itemBuilder: (context, index) {
              final reversedStats = stats.reversed.toList();
              final day = reversedStats[index];
              return _DayStatRow(day: day, maxValue: maxValue);
            },
          ),
        ),
      ],
    );
  }
}

class _DayStatRow extends StatelessWidget {
  const _DayStatRow({required this.day, required this.maxValue});

  final DayTaskStats day;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final label = '${day.date.day}/${day.date.month}';
    final rate = (day.completionRate * 100).round();

    return Row(
      children: [
        SizedBox(
          width: 42.w,
          child: Text(
            label,
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 11.sp,
              color: AppColors.secondaryColor,
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              _Bar(
                value: day.scheduledCount,
                max: maxValue,
                color: AppColors.thirdColor,
              ),
              4.verticalSpace,
              _Bar(
                value: day.completedCount,
                max: maxValue,
                color: AppColors.successColor,
              ),
            ],
          ),
        ),
        8.horizontalSpace,
        SizedBox(
          width: 36.w,
          child: Text(
            '$rate${AppTexts.percent}',
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class _MonthlyStatsPanel extends StatelessWidget {
  const _MonthlyStatsPanel({required this.stats});

  final List<MonthTaskStats> stats;

  static const _monthNames = [
    '',
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final maxCompleted = stats
        .map((s) => s.completedCount)
        .fold(0, (a, b) => a > b ? a : b);
    final maxValue = maxCompleted > 0 ? maxCompleted : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.last6Months,
          style: AppTextStyle.style12W300.copyWith(
            color: AppColors.secondaryColor,
          ),
        ),
        12.verticalSpace,
        Expanded(
          child: ListView.separated(
            itemCount: stats.length,
            separatorBuilder: (context, index) => 12.verticalSpace,
            itemBuilder: (context, index) {
              final reversedStats = stats.reversed.toList();
              final month = reversedStats[index];
              final label = '${_monthNames[month.month]} ${month.year}';
              final rate = (month.completionRate * 100).round();

              return Container(
                padding: EdgeInsets.all(12.w),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(label, style: AppTextStyle.style12Bold),
                        Text(
                          '$rate${AppTexts.percent}',
                          style: AppTextStyle.style9W300.copyWith(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    8.verticalSpace,
                    _Bar(
                      value: month.completedCount,
                      max: maxValue,
                      color: AppColors.primaryColor,
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        _MiniStat(
                          label: AppTexts.scheduled,
                          value: '${month.scheduledCount}',
                        ),
                        _MiniStat(
                          label: AppTexts.completed,
                          value: '${month.completedCount}',
                        ),
                        _MiniStat(
                          label: AppTexts.created,
                          value: '${month.createdCount}',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyle.style12Bold),
          Text(
            label,
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 10.sp,
              color: AppColors.secondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.value,
    required this.max,
    required this.color,
  });

  final int value;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final fraction = value / max;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: fraction.clamp(0.0, 1.0),
              minHeight: 8.h,
              backgroundColor: AppColors.secondaryColor.withAlpha(30),
              color: color,
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          '$value',
          style: AppTextStyle.style9W300.copyWith(fontSize: 10.sp),
        ),
      ],
    );
  }
}

class _LegendRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _LegendDot(color: AppColors.thirdColor, label: AppTexts.scheduled),
        SizedBox(width: 16.w),
        _LegendDot(color: AppColors.successColor, label: AppTexts.completed),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10.r,
          height: 10.r,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: AppTextStyle.style9W300.copyWith(
            fontSize: 11.sp,
            color: AppColors.secondaryColor,
          ),
        ),
      ],
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
