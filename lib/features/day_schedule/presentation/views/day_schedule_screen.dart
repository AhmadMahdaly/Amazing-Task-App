// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/day_schedule/presentation/views/widgets/hour_slot_row.dart';
import 'package:s/features/day_schedule/presentation/views/widgets/schedule_task_card.dart';
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

  Timer? _autoScrollTimer;
  double _scrollSpeed = 0;

  void _startAutoScroll(double speed) {
    _scrollSpeed = speed;
    if (_autoScrollTimer != null) return;

    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 16), (
      timer,
    ) {
      if (!_scrollController.hasClients) return;

      final currentOffset = _scrollController.offset;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final minScroll = _scrollController.position.minScrollExtent;

      var newOffset = currentOffset + _scrollSpeed;
      newOffset = newOffset.clamp(minScroll, maxScroll);

      if (currentOffset != newOffset) {
        _scrollController.jumpTo(newOffset);
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = null;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_isDragging) return;

    final dy = event.position.dy;
    final screenHeight = MediaQuery.of(context).size.height;
    const edgeSize = 120.0;

    if (dy < edgeSize) {
      final speed = -((edgeSize - dy) / edgeSize) * 15;
      _startAutoScroll(speed);
    } else if (dy > screenHeight - edgeSize) {
      final speed = ((dy - (screenHeight - edgeSize)) / edgeSize) * 15;
      _startAutoScroll(speed);
    } else {
      _stopAutoScroll();
    }
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

  void _onDragEnded() {
    if (!_isDragging) return;
    setState(() => _isDragging = false);
    _stopAutoScroll();
  }

  @override
  void dispose() {
    _stopAutoScroll();
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
          resizeToAvoidBottomInset: false,
          backgroundColor: wallpaperState.settings.hasWallpaper
              ? Colors.transparent
              : const Color(0xffF6F7FB),

          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'day_schedule_add',
            backgroundColor: AppColors.primaryColor,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
            onPressed: () async {
              await showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const AddTaskBottomSheet(
                  isMyDayView: true,
                ),
              );
            },
          ),

          body: AppWallpaper(
            settings: wallpaperState.settings,

            child: Listener(
              onPointerMove: _handlePointerMove,
              onPointerUp: (_) => _stopAutoScroll(),
              child: BlocBuilder<TasksCubit, TasksState>(
                builder: (context, state) {
                  if (state is TasksLoading) {
                    return const Center(
                      child: LoadingWidget(),
                    );
                  }

                  if (state is! TasksLoaded) {
                    return Center(
                      child: Text(
                        AppTexts.thereIsAnError,
                        style: AppTextStyle.style12W300.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  final todayTasks = todayActiveTasks(state.allTasks);

                  final completed = todayTasks
                      .where((e) => e.isCompleted)
                      .length;

                  final total = todayTasks.length;

                  final progress = total == 0 ? 0 : completed / total;

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
                        expandedHeight: 300.h,

                        backgroundColor: AppColors.primaryColor,

                        elevation: 0,

                        leading: IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: () => context.pop(),
                        ),

                        actions: [
                          IconButton(
                            icon: const Icon(Icons.schedule),
                            onPressed: _scrollToCurrentHour,
                          ),

                          const SizedBox(width: 8),
                        ],

                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,

                          background: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(20),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                mainAxisAlignment: MainAxisAlignment.end,

                                children: [
                                  Text(
                                    AppTexts.daySchedule,
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    formatFullDate(scheduleDate),
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: .85,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 22),

                                  Container(
                                    padding: const EdgeInsets.all(18),

                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: .12,
                                      ),

                                      borderRadius: BorderRadius.circular(18),
                                    ),

                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            _StatItem(
                                              title: 'Tasks',
                                              value: total.toString(),
                                            ),

                                            const Spacer(),

                                            _StatItem(
                                              title: 'Done',
                                              value: completed.toString(),
                                            ),

                                            const Spacer(),

                                            _StatItem(
                                              title: 'Left',
                                              value: (total - completed)
                                                  .toString(),
                                            ),
                                          ],
                                        ),

                                        const SizedBox(height: 18),

                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),

                                          child: LinearProgressIndicator(
                                            value: progress.toDouble(),

                                            minHeight: 8,

                                            backgroundColor: Colors.white24,

                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                  Colors.white,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: _UnscheduledSection(
                          tasks: unscheduled,
                          onDragStarted: _onDragStarted,
                          onDragEnded: _onDragEnded,
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.only(
                          bottom: 120,
                          top: 10,
                        ),

                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final hour = getOrderedDayHours()[index];

                              final hourTasks = tasksForHour(
                                todayTasks,
                                hour,
                              );

                              return HourSlotRow(
                                hour: hour,
                                tasks: hourTasks,

                                isCurrentHour: isCurrentHourSlot(
                                  hour,
                                  _now,
                                ),

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
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _UnscheduledSection extends StatefulWidget {
  const _UnscheduledSection({
    required this.tasks,
    this.onDragStarted,
    this.onDragEnded,
  });

  final List<TaskEntity> tasks;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  State<_UnscheduledSection> createState() => _UnscheduledSectionState();
}

class _UnscheduledSectionState extends State<_UnscheduledSection> {
  bool expanded = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),

      child: DragTarget<TaskEntity>(
        onWillAcceptWithDetails: (details) =>
            details.data.scheduledHour != null,

        onAcceptWithDetails: (details) {
          unawaited(
            context.read<TasksCubit>().clearTaskHour(
              details.data,
            ),
          );
        },

        builder: (context, candidateData, rejectedData) {
          final highlight = candidateData.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),

            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius: BorderRadius.circular(20),

              border: Border.all(
                color: highlight
                    ? AppColors.primaryColor
                    : Colors.grey.shade200,
                width: highlight ? 2 : 1,
              ),

              boxShadow: [
                BoxShadow(
                  blurRadius: 18,
                  color: Colors.black.withValues(alpha: .05),
                  offset: const Offset(0, 6),
                ),
              ],
            ),

            child: Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(20),

                  onTap: () {
                    setState(() {
                      expanded = !expanded;
                    });
                  },

                  child: Padding(
                    padding: EdgeInsets.all(18.w),

                    child: Row(
                      children: [
                        Container(
                          height: 42,
                          width: 42,

                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: .1),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.inbox_rounded,
                            color: AppColors.primaryColor,
                          ),
                        ),

                        SizedBox(width: 14.w),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                AppTexts.unscheduledTasks,
                                style: AppTextStyle.style14Bold,
                              ),

                              SizedBox(height: 4.h),

                              Text(
                                widget.tasks.isEmpty
                                    ? AppTexts.noTasksToday
                                    : AppTexts.dragTasksToHours,

                                style: AppTextStyle.style9W400.copyWith(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),

                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(alpha: .1),

                            borderRadius: BorderRadius.circular(50),
                          ),

                          child: Text(
                            '${widget.tasks.length}',

                            style: AppTextStyle.style12Bold.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),

                        SizedBox(width: 10.w),

                        AnimatedRotation(
                          duration: const Duration(milliseconds: 250),

                          turns: expanded ? .5 : 0,

                          child: const Icon(
                            Icons.keyboard_arrow_down,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                AnimatedCrossFade(
                  firstChild: const SizedBox(),

                  secondChild: Padding(
                    padding: EdgeInsets.only(
                      left: 14.w,
                      right: 14.w,
                      bottom: 14.h,
                    ),

                    child: widget.tasks.isEmpty
                        ? Column(
                            children: [
                              SizedBox(height: 20.h),

                              Icon(
                                Icons.task_alt,
                                size: 52,
                                color: Colors.grey.shade400,
                              ),

                              SizedBox(height: 10.h),

                              Text(
                                AppTexts.noTasksToday,

                                style: AppTextStyle.style12W400,
                              ),

                              SizedBox(height: 20.h),
                            ],
                          )
                        : ReorderableListView.builder(
                            shrinkWrap: true,

                            physics: const NeverScrollableScrollPhysics(),

                            buildDefaultDragHandles: false,

                            itemCount: widget.tasks.length,

                            onReorder: (oldIndex, newIndex) {
                              unawaited(
                                context.read<TasksCubit>().reorderScheduleTasks(
                                  scheduledHour: null,
                                  oldIndex: oldIndex,
                                  newIndex: newIndex,
                                  tasksList: List<TaskEntity>.from(
                                    widget.tasks,
                                  ),
                                ),
                              );
                            },

                            itemBuilder: (context, index) {
                              return Padding(
                                key: ValueKey(
                                  widget.tasks[index].id,
                                ),

                                padding: EdgeInsets.only(
                                  bottom: 10.h,
                                ),

                                child: ScheduleTaskCard(
                                  task: widget.tasks[index],

                                  index: index,

                                  onDragStarted: widget.onDragStarted,

                                  onDragEnded: widget.onDragEnded,
                                ),
                              );
                            },
                          ),
                  ),

                  crossFadeState: expanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,

                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
