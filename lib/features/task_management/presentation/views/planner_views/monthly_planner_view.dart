import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/widgets/task_item_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class MonthlyPlannerView extends StatefulWidget {
  const MonthlyPlannerView({super.key});

  @override
  State<MonthlyPlannerView> createState() => _MonthlyPlannerViewState();
}

class _MonthlyPlannerViewState extends State<MonthlyPlannerView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<TaskEntity> _getTasksForDay(DateTime day, List<TaskEntity> allTasks) {
    return allTasks.where((task) {
      if (task.dueDate == null) return false;
      return _isSameDay(task.dueDate, day);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        var allTasks = <TaskEntity>[];
        if (state is TasksLoaded) {
          allTasks = state.allTasks;
        }

        final selectedDayTasks = _getTasksForDay(
          _selectedDay ?? _focusedDay,
          allTasks,
        );

        return Column(
          children: [
            Container(
              margin: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryColor.withAlpha(20),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TableCalendar<TaskEntity>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                eventLoader: (day) => _getTasksForDay(day, allTasks),
                calendarStyle: CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: const BoxDecoration(
                    color: AppColors.thirdColor,
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle: AppTextStyle.style16Bold.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text(
                    AppTexts.selectedDayTasks,
                    style: AppTextStyle.style14Bold.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${selectedDayTasks.length} ${AppTexts.tasks}',
                    style: AppTextStyle.style12W300.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            8.verticalSpace,
            Expanded(
              child: selectedDayTasks.isEmpty
                  ? Center(
                      child: Text(
                        AppTexts.noTasksOnThisDay,
                        style: AppTextStyle.style12W300.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      itemCount: selectedDayTasks.length,
                      itemBuilder: (context, index) {
                        return TaskItemWidget(
                          key: ValueKey(selectedDayTasks[index].id),
                          task: selectedDayTasks[index],
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
