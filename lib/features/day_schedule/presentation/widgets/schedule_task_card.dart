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
    return Material(
      color: task.isImportant
          ? AppColors.primaryColor.withAlpha(18)
          : AppColors.white,
      elevation: 1,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 8.w,
          vertical: compact ? 4.h : 6.h,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: task.isImportant
                ? AppColors.primaryColor.withAlpha(80)
                : AppColors.secondaryColor.withAlpha(30),
          ),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: () async {
                await context.read<TasksCubit>().toggleTaskCompletion(task);
                await playSound();
              },
              child: Icon(
                task.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: task.isCompleted
                    ? AppColors.primaryColor
                    : AppColors.secondaryColor,
                size: compact ? 18.r : 22.r,
              ),
            ),
            8.horizontalSpace,
            Expanded(child: _buildCardBody(compact: compact)),
            if (enableScheduleDrag)
              _ScheduleDragHandle(
                task: task,
                compact: compact,
                onDragStarted: onDragStarted,
                onDragEnded: onDragEnded,
              ),
            if (enableReorder) ...[
              4.horizontalSpace,
              ReorderableDragStartListener(
                index: index,
                child: Icon(
                  Icons.drag_handle,
                  size: compact ? 18.r : 22.r,
                  color: AppColors.secondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardBody({required bool compact}) {
    return Row(
      children: [
        Expanded(
          child: DirectionalText(
            task.title,
            maxLines: compact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.style12W300.copyWith(
              fontSize: compact ? 10.sp : 11.sp,
              color: AppColors.forthColor,
            ),
          ),
        ),
        if (task.isImportant)
          Icon(
            Icons.star,
            size: 14.r,
            color: AppColors.primaryColor,
          ),
      ],
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
    return Draggable<TaskEntity>(
      data: task,
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
