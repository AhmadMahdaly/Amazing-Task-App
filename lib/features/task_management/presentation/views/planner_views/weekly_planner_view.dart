import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/widgets/task_item_widget.dart';

class WeeklyPlannerView extends StatefulWidget {
  const WeeklyPlannerView({super.key});

  @override
  State<WeeklyPlannerView> createState() => _WeeklyPlannerViewState();
}

class _WeeklyPlannerViewState extends State<WeeklyPlannerView> {
  late DateTime _currentWeekStart;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    final daysToSubtract = now.weekday == 7 ? 0 : now.weekday;
    _currentWeekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: daysToSubtract));
  }

  void _changeWeek(int offset) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: offset * 7));
    });
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          color: AppColors.forthColor.withAlpha(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.primaryColor,
                ),
                onPressed: () => _changeWeek(-1),
              ),
              Text(
                '${formatDateHeader(_currentWeekStart)} - ${formatDateHeader(_currentWeekStart.add(const Duration(days: 6)))}',
                style: AppTextStyle.style14W500.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primaryColor,
                ),
                onPressed: () => _changeWeek(1),
              ),
            ],
          ),
        ),

        Expanded(
          child: BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              var allTasks = <TaskEntity>[];
              if (state is TasksLoaded) {
                allTasks = state.allTasks.where((t) => !t.isCompleted).toList();
              }

              return ListView.builder(
                padding: EdgeInsets.only(bottom: 80.h),
                itemCount: 8,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final unscheduledTasks = allTasks
                        .where((t) => t.dueDate == null)
                        .toList();
                    return _buildUnscheduledSection(unscheduledTasks);
                  }

                  final dayDate = _currentWeekStart.add(
                    Duration(days: index - 1),
                  );
                  final dayTasks = allTasks
                      .where((t) => _isSameDay(t.dueDate, dayDate))
                      .toList();

                  return _buildDayTarget(dayDate, dayTasks);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUnscheduledSection(List<TaskEntity> tasks) {
    return ExpansionTile(
      initiallyExpanded: false,
      title: Text(
        '${AppTexts.unscheduledTasks} (${tasks.length})',
        style: AppTextStyle.style14Bold.copyWith(
          color: AppColors.secondaryColor,
        ),
      ),
      leading: const Icon(Icons.inbox, color: AppColors.secondaryColor),
      children: tasks.map(_buildDraggableTask).toList(),
    );
  }

  Widget _buildDayTarget(DateTime dayDate, List<TaskEntity> tasks) {
    final isToday = _isSameDay(DateTime.now(), dayDate);

    return DragTarget<TaskEntity>(
      onAcceptWithDetails: (details) async {
        final task = details.data;

        if (!_isSameDay(task.dueDate, dayDate)) {
          await context.read<TasksCubit>().updateTask(
            task.copyWith(dueDate: dayDate),
          );
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: candidateData.isNotEmpty
                ? AppColors.primaryColor.withAlpha(
                    30,
                  )
                : AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isToday
                  ? AppColors.primaryColor
                  : AppColors.secondaryColor.withAlpha(50),
              width: isToday ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primaryColor.withAlpha(20)
                      : Colors.transparent,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10.r),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      formatFullDate(dayDate),
                      style: AppTextStyle.style14Bold.copyWith(
                        color: isToday
                            ? AppColors.primaryColor
                            : AppColors.forthColor,
                      ),
                    ),
                    const Spacer(),
                    if (tasks.isNotEmpty)
                      CircleAvatar(
                        radius: 12.r,
                        backgroundColor: AppColors.secondaryColor.withAlpha(50),
                        child: Text(
                          '${tasks.length}',
                          style: AppTextStyle.style9W300.copyWith(
                            color: AppColors.forthColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),

              if (tasks.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Center(
                    child: Text(
                      AppTexts.noTasksOnThisDay,
                      style: AppTextStyle.style12W300.copyWith(
                        color: AppColors.secondaryColor.withAlpha(100),
                      ),
                    ),
                  ),
                )
              else
                ...tasks.map(_buildDraggableTask),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableTask(TaskEntity task) {
    return LongPressDraggable<TaskEntity>(
      data: task,
      delay: const Duration(
        milliseconds: 150,
      ),
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 32.w,
            child: TaskItemWidget(task: task),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: TaskItemWidget(task: task),
      ),
      child: TaskItemWidget(task: task),
    );
  }
}
