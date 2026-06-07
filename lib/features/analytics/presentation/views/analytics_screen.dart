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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            AppTexts.last6Months,
            style: AppTextStyle.style14Bold.copyWith(
              color: AppColors.forthColor,
            ),
          ),
        ),
        16.verticalSpace,
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            itemCount: stats.length,
            separatorBuilder: (context, index) => 16.verticalSpace,
            itemBuilder: (context, index) {
              final month = stats.reversed.toList()[index];
              return _MonthStatCard(
                month: month,
                monthName: _monthNames[month.month],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MonthStatCard extends StatelessWidget {
  const _MonthStatCard({required this.month, required this.monthName});

  final MonthTaskStats month;
  final String monthName;

  @override
  Widget build(BuildContext context) {
    final rate = (month.completionRate * 100).round();
    final isCurrentMonth =
        month.year == DateTime.now().year &&
        month.month == DateTime.now().month;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: isCurrentMonth
            ? AppColors.primaryColor.withAlpha(10)
            : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: isCurrentMonth
            ? Border.all(color: AppColors.primaryColor.withAlpha(50), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70.w,
            height: 70.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: month.completionRate),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return SizedBox(
                      width: 70.w,
                      height: 70.w,
                      child: CircularProgressIndicator(
                        value: value,
                        strokeWidth: 6.w,
                        backgroundColor: AppColors.secondaryColor.withAlpha(20),
                        color: AppColors.primaryColor,
                        strokeCap: StrokeCap.round,
                      ),
                    );
                  },
                ),
                Text(
                  '$rate%',
                  style: AppTextStyle.style14Bold.copyWith(
                    color: AppColors.primaryColor,
                    fontSize: 16.sp,
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
                  '$monthName ${month.year}',
                  style: AppTextStyle.style16Bold.copyWith(
                    color: AppColors.forthColor,
                  ),
                ),
                12.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniStat(
                      label: AppTexts.scheduled,
                      value: '${month.scheduledCount}',
                      color: AppColors.thirdColor,
                    ),
                    _MiniStat(
                      label: AppTexts.completed,
                      value: '${month.completedCount}',
                      color: AppColors.successColor,
                    ),
                    _MiniStat(
                      label: AppTexts.created,
                      value: '${month.createdCount}',
                      color: Colors.blueAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyle.style14Bold.copyWith(
            color: color,
            fontSize: 16.sp,
          ),
        ),
        2.verticalSpace,
        Text(
          label,
          style: AppTextStyle.style9W300.copyWith(
            fontSize: 10.sp,
            color: AppColors.secondaryColor,
            fontWeight: FontWeight.w500,
          ),
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
        16.horizontalSpace,
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
        6.horizontalSpace,
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
      backgroundColor: const Color(0xFFF8F9FA),
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
                                ),
                              ),
                              16.horizontalSpace,
                              Expanded(
                                child: _StreakCard(
                                  icon: Icons.emoji_events_rounded,
                                  iconColor: Colors.amber,
                                  title: 'Best Streak',
                                  value: '${summary.bestStreak}',
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

                          32.verticalSpace,
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 10.r,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TabBar(
                              controller: _tabController,
                              labelColor: AppColors.primaryColor,
                              unselectedLabelColor: AppColors.secondaryColor,
                              indicatorColor: AppColors.primaryColor,
                              indicatorWeight: 3,
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelStyle: AppTextStyle.style12W700,
                              dividerColor: Colors.transparent,
                              tabs: [
                                Tab(text: AppTexts.dailyStats),
                                Tab(text: AppTexts.monthlyStats),
                              ],
                            ),
                          ),
                          16.verticalSpace,
                          SizedBox(
                            height: 450.h,
                            child: TabBarView(
                              physics: const BouncingScrollPhysics(),
                              controller: _tabController,
                              children: [
                                _DailyStatsPanel(stats: dailyStats),
                                _MonthlyStatsPanel(stats: monthlyStats),
                              ],
                            ),
                          ),
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

  Widget _buildEmptyState(BuildContext context) {
    return const Scaffold(body: Center(child: Text('No Analytics Data')));
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
              Icon(icon, color: color.withOpacity(0.8), size: 24.r),
              Text(
                value,
                style: AppTextStyle.style16Bold.copyWith(
                  color: AppColors.forthColor,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 12.sp,
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.w500,
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
                style: AppTextStyle.style14Bold.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16.sp,
                ),
              ),
              8.verticalSpace,
              Text(
                'Keep up the great work!',
                style: AppTextStyle.style9W300.copyWith(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.sp,
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
                  style: AppTextStyle.style16Bold.copyWith(
                    color: Colors.white,
                    fontSize: 20.sp,
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
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
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
              color: iconColor.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24.r),
          ),
          12.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyle.style16Bold.copyWith(
                  fontSize: 20.sp,
                  color: AppColors.forthColor,
                ),
              ),
              Text(
                title,
                style: AppTextStyle.style9W300.copyWith(
                  color: AppColors.secondaryColor,
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

class _DailyStatsPanel extends StatelessWidget {
  const _DailyStatsPanel({required this.stats});

  final List<DayTaskStats> stats;

  @override
  Widget build(BuildContext context) {
    final maxScheduled = stats
        .map((s) => s.scheduledCount)
        .fold(0, (a, b) => a > b ? a : b);
    final maxCompleted = stats
        .map((s) => s.completedCount)
        .fold(0, (a, b) => a > b ? a : b);
    final maxValue = (maxScheduled > maxCompleted
        ? maxScheduled
        : maxCompleted);
    final safeMax = maxValue > 0 ? maxValue : 1;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 15.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTexts.last14Days,
                style: AppTextStyle.style14Bold.copyWith(
                  color: AppColors.forthColor,
                ),
              ),
              _LegendRow(),
            ],
          ),
          24.verticalSpace,
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,

              itemCount: stats.length,
              separatorBuilder: (context, index) => 16.horizontalSpace,
              itemBuilder: (context, index) {
                final day = stats.reversed.toList()[index];
                return _VerticalDayBar(day: day, maxValue: safeMax);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDayBar extends StatelessWidget {
  const _VerticalDayBar({required this.day, required this.maxValue});

  final DayTaskStats day;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final label = '${day.date.day}/${day.date.month}';
    final rate = (day.completionRate * 100).round();

    final scheduledFraction = (day.scheduledCount / maxValue).clamp(0.0, 1.0);
    final completedFraction = (day.completedCount / maxValue).clamp(0.0, 1.0);

    return SizedBox(
      width: 45.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$rate%',
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: rate >= 80
                  ? AppColors.successColor
                  : AppColors.secondaryColor,
            ),
          ),
          8.verticalSpace,
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _AnimatedVerticalBar(
                  fraction: scheduledFraction,
                  color: AppColors.thirdColor,
                ),
                4.horizontalSpace,

                _AnimatedVerticalBar(
                  fraction: completedFraction,
                  color: AppColors.successColor,
                ),
              ],
            ),
          ),
          12.verticalSpace,

          Text(
            label,
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 11.sp,
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedVerticalBar extends StatelessWidget {
  const _AnimatedVerticalBar({required this.fraction, required this.color});
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: fraction),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return FractionallySizedBox(
          heightFactor: value,
          child: Container(
            width: 12.w,
            decoration: BoxDecoration(
              color: value > 0 ? color : Colors.transparent,
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
        );
      },
    );
  }
}
