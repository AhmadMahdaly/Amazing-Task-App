import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/day_schedule/presentation/widgets/hour_slot_row.dart';
import 'package:s/features/day_schedule/presentation/widgets/schedule_task_card.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/day_schedule_utils.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/widgets/add_task_bottom_sheet.dart';

class DayScheduleScreen extends StatefulWidget {
  const DayScheduleScreen({super.key});

  @override
  State<DayScheduleScreen> createState() => _DayScheduleScreenState();
}

class _DayScheduleScreenState extends State<DayScheduleScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _hourKeys = {
    for (final hour in getOrderedDayHours()) hour: GlobalKey(),
  };
  Timer? _clockTimer;
  late DateTime _now;
  bool _isDragging = false;

  void _onDragStarted() {
    if (_isDragging) return;
    setState(() => _isDragging = true);
  }

  void _onDragEnded() {
    if (!_isDragging) return;
    setState(() => _isDragging = false);
  }

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentHour());
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToCurrentHour() {
    final currentHour = _now.hour;
    final key = _hourKeys[currentHour];
    final context = key?.currentContext;
    if (context == null) return;

    unawaited(
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
        alignment: 0.25,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Scaffold(
          backgroundColor: wallpaperState.settings.hasWallpaper
              ? Colors.transparent
              : AppColors.primaryColor,
          floatingActionButton: FloatingActionButton(
            heroTag: 'day_schedule_add',
            backgroundColor: AppColors.white,
            onPressed: () async {
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const AddTaskBottomSheet(
                  isMyDayView: true,
                ),
              );
            },
            child: Icon(Icons.add, color: AppColors.primaryColor, size: 28.r),
          ),
          body: AppWallpaper(
            settings: wallpaperState.settings,
            child: BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                if (state is TasksLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is! TasksLoaded) {
                  return Center(
                    child: Text(
                      AppTexts.thereIsAnError,
                      style: AppTextStyle.style12W300.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  );
                }

                final todayTasks = todayActiveTasks(state.allTasks);
                final unscheduled = unscheduledTasks(todayTasks);
                final scheduleDate = logicalScheduleDate(_now);

                return CustomScrollView(
                  controller: _scrollController,
                  physics: _isDragging
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      leading: IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.white,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppTexts.daySchedule,
                            style: AppTextStyle.style18Bold.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          Text(
                            formatFullDate(scheduleDate),
                            style: AppTextStyle.style12W400.copyWith(
                              color: AppColors.white.withAlpha(210),
                            ),
                          ),
                        ],
                      ),
                      actions: [
                        IconButton(
                          tooltip: AppTexts.organizeYourDay,
                          icon: Icon(
                            Icons.access_time_filled,
                            color: AppColors.white,
                            size: 22.r,
                          ),
                          onPressed: _scrollToCurrentHour,
                        ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: _UnscheduledSection(
                        tasks: unscheduled,
                        onDragStarted: _onDragStarted,
                        onDragEnded: _onDragEnded,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final hour = getOrderedDayHours()[index];
                            final hourTasks = tasksForHour(todayTasks, hour);

                            return HourSlotRow(
                              hour: hour,
                              tasks: hourTasks,
                              isCurrentHour: isCurrentHourSlot(hour, _now),
                              rowKey: _hourKeys[hour]!,
                              onDragStarted: _onDragStarted,
                              onDragEnded: _onDragEnded,
                            );
                          },
                          childCount: getOrderedDayHours().length,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _UnscheduledSection extends StatelessWidget {
  const _UnscheduledSection({
    required this.tasks,
    this.onDragStarted,
    this.onDragEnded,
  });

  final List<TaskEntity> tasks;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DragTarget<TaskEntity>(
        onWillAcceptWithDetails: (details) =>
            details.data.scheduledHour != null,
        onAcceptWithDetails: (details) {
          unawaited(
            context.read<TasksCubit>().clearTaskHour(details.data),
          );
        },
        hitTestBehavior: HitTestBehavior.translucent,
        builder: (context, candidateData, rejectedData) {
          final isHighlighted = candidateData.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isHighlighted
                    ? AppColors.thirdColor
                    : AppColors.secondaryColor.withAlpha(30),
                width: isHighlighted ? 2 : 1,
              ),
              color: isHighlighted
                  ? AppColors.thirdColor.withAlpha(20)
                  : AppColors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 18.r,
                      color: AppColors.primaryColor,
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: Text(
                        AppTexts.unscheduledTasks,
                        style: AppTextStyle.style12Bold.copyWith(
                          color: AppColors.forthColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${tasks.length}',
                        style: AppTextStyle.style12Bold.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                6.verticalSpace,
                Text(
                  AppTexts.dragTasksToHours,
                  style: AppTextStyle.style9W300.copyWith(
                    color: AppColors.secondaryColor,
                  ),
                ),
                10.verticalSpace,
                if (tasks.isEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Center(
                      child: Text(
                        isHighlighted
                            ? AppTexts.dropHere
                            : AppTexts.noTasksToday,
                        style: AppTextStyle.style12W300.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                  )
                else
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: tasks.length,
                    onReorder: (oldIndex, newIndex) {
                      unawaited(
                        context.read<TasksCubit>().reorderScheduleTasks(
                          scheduledHour: null,
                          oldIndex: oldIndex,
                          newIndex: newIndex,
                          tasksList: List<TaskEntity>.from(tasks),
                        ),
                      );
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        key: ValueKey(tasks[index].id),
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: ScheduleTaskCard(
                          task: tasks[index],
                          index: index,
                          onDragStarted: onDragStarted,
                          onDragEnded: onDragEnded,
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
