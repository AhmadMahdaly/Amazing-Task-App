import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/task_date_utils.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';
import 'package:s/features/task_management/presentation/views/widgets/task_item_widget.dart';

class CompletedTasksSection extends StatelessWidget {
  const CompletedTasksSection({
    required this.tasks,
    this.compact = false,
    super.key,
  });

  final List<TaskEntity> tasks;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return SizedBox(
        height: 200.h,
        child: Center(
          child: Text(
            AppTexts.noCompletedTasks,
            style: AppTextStyle.style9W300.copyWith(color: AppColors.white),
          ),
        ),
      );
    }

    final sorted = List<TaskEntity>.from(tasks)
      ..sort((a, b) {
        final aDate = a.completedAt ?? taskCreatedAt(a) ?? DateTime(1970);
        final bDate = b.completedAt ?? taskCreatedAt(b) ?? DateTime(1970);
        return bDate.compareTo(aDate);
      });

    final grouped = <String, List<TaskEntity>>{};
    for (final task in sorted) {
      final date = task.completedAt ?? taskCreatedAt(task);
      final header = date != null
          ? formatDateHeader(date)
          : AppTexts.completedDateUnknown;
      grouped.putIfAbsent(header, () => []).add(task);
    }

    if (compact) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          iconColor: AppColors.white,
          collapsedIconColor: AppColors.white,
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w),
          childrenPadding: EdgeInsets.only(bottom: 8.h),
          title: Text(
            '${AppTexts.completed}  ${tasks.length}',
            style: AppTextStyle.style12W600.copyWith(
              color: AppColors.white,
            ),
          ),
          // subtitle: sorted.first.completedAt != null
          //     ? Text(
          //         formatCompletedDate(sorted.first.completedAt),
          //         style: AppTextStyle.style9W300.copyWith(
          //           fontSize: 11.sp,
          //           color: AppColors.secondaryColor.withAlpha(160),
          //         ),
          //       )
          //     : null,
          children: [
            for (final entry in grouped.entries) ...[
              _DateHeader(label: entry.key),
              ...entry.value.map(
                (t) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: TaskItemWidget(
                    key: ValueKey(t.id),
                    task: t,
                    showCompletedDate: true,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      children: [
        for (final entry in grouped.entries) ...[
          _DateHeader(label: entry.key),
          ...entry.value.map(
            (t) => TaskItemWidget(
              key: ValueKey(t.id),
              task: t,
              showCompletedDate: true,
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 6.h),
      child: Row(
        children: [
          16.horizontalSpace,
          Icon(
            Icons.event_available,
            size: 16.r,
            color: AppColors.white.withAlpha(200),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }
}
