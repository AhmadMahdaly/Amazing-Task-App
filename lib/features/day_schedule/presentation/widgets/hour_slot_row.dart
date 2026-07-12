import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/utils/task_format_utils.dart';
import 'package:s/features/day_schedule/presentation/widgets/schedule_task_card.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/widgets/add_task_bottom_sheet.dart';

class HourSlotRow extends StatelessWidget {
  const HourSlotRow({
    required this.hour,
    required this.tasks,
    required this.isCurrentHour,
    required this.rowKey,
    super.key,
    this.onDragStarted,
    this.onDragEnded,
  });

  final int hour;
  final List<TaskEntity> tasks;
  final bool isCurrentHour;
  final GlobalKey rowKey;

  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  Widget build(BuildContext context) {
    return DragTarget<TaskEntity>(
      key: rowKey,

      onWillAcceptWithDetails: (_) => true,

      onAcceptWithDetails: (details) async {
        await context.read<TasksCubit>().assignTaskToHour(
          details.data,
          hour,
        );
      },

      builder: (context, candidateData, rejectedData) {
        final highlight = candidateData.isNotEmpty;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),

          color: highlight
              ? AppColors.primaryColor.withValues(alpha: .05)
              : Colors.transparent,

          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 6,
          ),

          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                /// الوقت
                SizedBox(
                  width: 65,

                  child: Text(
                    TaskFormatUtils.formatHour(hour),

                    style: TextStyle(
                      fontSize: 15,

                      fontWeight: isCurrentHour
                          ? FontWeight.bold
                          : FontWeight.w500,

                      color: isCurrentHour
                          ? AppColors.primaryColor
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
                // if (isCurrentHour)
                //   Padding(
                //     padding: const EdgeInsets.only(top: 6),
                //     child: Row(
                //       children: [
                //         Container(
                //           width: 8,
                //           height: 8,
                //           decoration: const BoxDecoration(
                //             color: Colors.red,
                //             shape: BoxShape.circle,
                //           ),
                //         ),
                //         const SizedBox(width: 6),
                //         const Expanded(
                //           child: Divider(
                //             thickness: 2,
                //             color: Colors.red,
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),

                /// الـ Timeline
                SizedBox(
                  width: 34,

                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),

                        width: isCurrentHour ? 16 : 12,

                        height: isCurrentHour ? 16 : 12,

                        decoration: BoxDecoration(
                          color: isCurrentHour
                              ? AppColors.primaryColor
                              : Colors.grey.shade400,

                          shape: BoxShape.circle,
                        ),
                      ),

                      Expanded(
                        child: Container(
                          width: 2,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ),

                /// المحتوى
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),

                    padding: const EdgeInsets.all(14),

                    margin: const EdgeInsets.only(bottom: 12),

                    decoration: BoxDecoration(
                      color: highlight
                          ? AppColors.primaryColor.withValues(alpha: .06)
                          : Colors.white,

                      borderRadius: BorderRadius.circular(18),

                      border: Border.all(
                        color: highlight
                            ? AppColors.primaryColor
                            : Colors.grey.shade200,
                      ),

                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withValues(alpha: .04),
                        ),
                      ],
                    ),

                    child: tasks.isEmpty
                        ?
                          /// ساعة فارغة
                          InkWell(
                            borderRadius: BorderRadius.circular(18),

                            onTap: () async {
                              final selectedDate = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                hour,
                              );
                              await showModalBottomSheet<void>(
                                context: context,

                                isScrollControlled: true,

                                backgroundColor: Colors.transparent,

                                builder: (_) => AddTaskBottomSheet(
                                  isMyDayView: true,

                                  initialDueDate: selectedDate,
                                ),
                              );
                            },

                            child: Row(
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.grey.shade500,
                                ),

                                const SizedBox(width: 10),

                                Text(
                                  'Add task',

                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        :
                          /// المهام
                          Column(
                            children: List.generate(
                              tasks.length,
                              (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 8,
                                  ),

                                  child: ScheduleTaskCard(
                                    task: tasks[index],

                                    index: index,

                                    onDragStarted: onDragStarted,

                                    onDragEnded: onDragEnded,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
