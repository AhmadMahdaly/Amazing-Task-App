import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/day_schedule/presentation/widgets/schedule_task_card.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/day_schedule_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class HourSlotRow extends StatelessWidget {
  const HourSlotRow({
    required this.hour,
    required this.tasks,
    required this.isCurrentHour,
    required this.rowKey,
    this.onDragStarted,
    this.onDragEnded,
    super.key,
  });

  final int hour;
  final List<TaskEntity> tasks;
  final bool isCurrentHour;
  final GlobalKey rowKey;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: rowKey,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 3.h),
      child: DragTarget<TaskEntity>(
        onWillAcceptWithDetails: (_) => true,
        onAcceptWithDetails: (details) {
          unawaited(
            context.read<TasksCubit>().assignTaskToHour(details.data, hour),
          );
        },
        builder: (context, candidateData, rejectedData) {
          final isHighlighted = candidateData.isNotEmpty;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            constraints: BoxConstraints(minHeight: 56.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? AppColors.thirdColor.withAlpha(40)
                  : (isCurrentHour
                        ? AppColors.primaryColor.withAlpha(22)
                        : AppColors.white),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: isHighlighted
                    ? AppColors.thirdColor
                    : (isCurrentHour
                          ? AppColors.primaryColor
                          : AppColors.secondaryColor.withAlpha(35)),
                width: isHighlighted || isCurrentHour ? 2 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 72.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatHourLabel(hour),
                        style: AppTextStyle.style12Bold.copyWith(
                          fontSize: 10.sp,
                          color: isCurrentHour
                              ? AppColors.primaryColor
                              : AppColors.forthColor,
                        ),
                      ),
                      if (isCurrentHour)
                        Container(
                          margin: EdgeInsets.only(top: 4.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            AppTexts.currentHour,
                            style: AppTextStyle.style9W300.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 40.h,
                  color: AppColors.secondaryColor.withAlpha(40),
                ),
                10.horizontalSpace,
                Expanded(
                  child: tasks.isEmpty
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Text(
                              isHighlighted
                                  ? AppTexts.dropHere
                                  : AppTexts.dragTasksToHours,
                              style: AppTextStyle.style9W300.copyWith(
                                color: AppColors.secondaryColor.withAlpha(
                                  isHighlighted ? 200 : 120,
                                ),
                              ),
                            ),
                          ),
                        )
                      : ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: tasks.length,
                          onReorder: (oldIndex, newIndex) {
                            unawaited(
                              context.read<TasksCubit>().reorderScheduleTasks(
                                scheduledHour: hour,
                                oldIndex: oldIndex,
                                newIndex: newIndex,
                                tasksList: List<TaskEntity>.from(tasks),
                              ),
                            );
                          },
                          itemBuilder: (context, index) {
                            return ScheduleTaskCard(
                              key: ValueKey(tasks[index].id),
                              task: tasks[index],
                              index: index,
                              compact: true,
                              onDragStarted: onDragStarted,
                              onDragEnded: onDragEnded,
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
