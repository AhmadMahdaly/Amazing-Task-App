import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/functions/play_sound.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/directional_text.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class ScheduleTaskCard extends StatelessWidget {
  const ScheduleTaskCard({
    required this.task,
    required this.index,
    this.enableReorder = true,
    this.enableScheduleDrag = true,
    this.compact = false,
    this.onDragStarted,
    this.onDragEnded,
    super.key,
  });

  final TaskEntity task;
  final int index;
  final bool enableReorder;
  final bool enableScheduleDrag;
  final bool compact;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            offset: const Offset(0, 4),
            color: Colors.black.withValues(alpha: .05),
          ),
        ],
      ),

      child: Row(
        children: [
          /// اللون الجانبي
          Container(
            width: 6,
            height: compact ? 60 : 78,

            decoration: BoxDecoration(
              color: task.isImportant ? Colors.orange : AppColors.primaryColor,

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                bottomLeft: Radius.circular(18),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  GestureDetector(
                    onTap: () async {
                      await context.read<TasksCubit>().toggleTaskCompletion(
                        task,
                      );

                      await playSound();
                    },

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),

                      width: 28,
                      height: 28,

                      decoration: BoxDecoration(
                        shape: BoxShape.circle,

                        color: task.isCompleted
                            ? AppColors.primaryColor
                            : Colors.transparent,

                        border: Border.all(
                          color: task.isCompleted
                              ? AppColors.primaryColor
                              : Colors.grey,
                          width: 2,
                        ),
                      ),

                      child: task.isCompleted
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        DirectionalText(
                          task.title,

                          maxLines: compact ? 1 : 2,

                          overflow: TextOverflow.ellipsis,

                          style: AppTextStyle.style12Bold.copyWith(
                            fontSize: compact ? 12.sp : 14.sp,

                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,

                            color: task.isCompleted
                                ? Colors.grey
                                : AppColors.forthColor,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            if (task.isImportant)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: .15),

                                  borderRadius: BorderRadius.circular(50),
                                ),

                                child: Text(
                                  'Important',

                                  style: AppTextStyle.style11W600.copyWith(
                                    color: Colors.orange,
                                  ),
                                ),
                              ),

                            const Spacer(),

                            if (enableScheduleDrag)
                              _ScheduleDragHandle(
                                task: task,
                                compact: compact,
                                onDragStarted: onDragStarted,
                                onDragEnded: onDragEnded,
                              ),

                            if (enableReorder)
                              ReorderableDragStartListener(
                                index: index,

                                child: Container(
                                  padding: const EdgeInsets.all(6),

                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,

                                    shape: BoxShape.circle,
                                  ),

                                  child: const Icon(
                                    Icons.drag_indicator,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleDragHandle extends StatelessWidget {
  const _ScheduleDragHandle({
    required this.task,
    required this.compact,
    this.onDragStarted,
    this.onDragEnded,
  });

  final TaskEntity task;
  final bool compact;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  @override
  Widget build(BuildContext context) {
    // تم التغيير هنا من Draggable إلى LongPressDraggable
    return LongPressDraggable<TaskEntity>(
      data: task,
      // يمكنك إضافة delay للتحكم في وقت الضغطة المطولة قبل بدء السحب (اختياري)
      delay: const Duration(milliseconds: 250),
      rootOverlay: true,
      onDragStarted: onDragStarted,
      onDragEnd: (_) => onDragEnded?.call(),
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8.r),
        color: AppColors.white,
        child: Container(
          width: 220.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.primaryColor, width: 2),
          ),
          child: DirectionalText(
            task.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.style12W300.copyWith(
              fontSize: compact ? 10.sp : 11.sp,
              color: AppColors.forthColor,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: Icon(
          Icons.open_with,
          size: compact ? 18.r : 20.r,
          color: AppColors.primaryColor,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        child: Icon(
          Icons.open_with,
          size: compact ? 18.r : 20.r,
          color: AppColors.primaryColor.withAlpha(180),
        ),
      ),
    );
  }
}
