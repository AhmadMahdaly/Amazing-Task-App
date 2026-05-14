import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/theme/app_colors.dart';
import 'package:s/core/theme/app_text_style.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_list/presentation/views/add_list_bottom_sheet.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class TasksDrawer extends StatelessWidget {
  const TasksDrawer({super.key, this.isPermanent = false});
  final bool isPermanent;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.forthColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(),
      shadowColor: Colors.transparent,
      clipBehavior: Clip.none,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BlocBuilder<TasksCubit, TasksState>(
              builder: (context, state) {
                var progress = 0.0;
                var completedToday = 0;
                var totalToday = 0;

                if (state is TasksLoaded) {
                  final now = DateTime.now();
                  final todayStr = now.toIso8601String().split('T')[0];

                  // فلترة دقيقة لمهام اليوم
                  final todayTasks = state.allTasks.where((t) {
                    // 1. هل أضيفت ليومي؟
                    final inMyDay = t.myDayDate == todayStr;
                    // 2. أو هل تاريخ استحقاقها هو اليوم؟
                    final dueToday =
                        t.dueDate != null &&
                        t.dueDate!.year == now.year &&
                        t.dueDate!.month == now.month &&
                        t.dueDate!.day == now.day;

                    return inMyDay || dueToday;
                  }).toList();

                  totalToday = todayTasks.length;
                  completedToday = todayTasks
                      .where((t) => t.isCompleted)
                      .length;

                  if (totalToday > 0) {
                    progress = completedToday / totalToday;
                  }
                }

                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 45.r,
                        height: 45.r,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 4.r,
                              backgroundColor: AppColors.secondaryColor
                                  .withOpacity(0.2),
                              color: Colors.white,
                            ),
                            Center(
                              child: Icon(
                                Icons.auto_graph,
                                color: Colors.white,
                                size: 20.r,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إنجاز اليوم',
                              style: AppTextStyle.style9W300.copyWith(
                                fontSize: 16.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              totalToday == 0
                                  ? 'لا توجد مهام اليوم'
                                  : '$completedToday من $totalToday مهام مكتملة',
                              style: AppTextStyle.style9W300.copyWith(
                                fontSize: 11.sp,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Divider(color: Colors.white.withAlpha(77)),

            _buildDrawerItem(
              icon: Icons.wb_sunny_outlined,
              title: 'My Day',
              context: context,
              onTap: () async {
                await context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.myDay,
                  title: 'My Day',
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.star_border,
              title: 'Important',
              context: context,
              onTap: () async {
                await context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.important,
                  title: 'Important',
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.calendar_today,
              title: 'Planned',
              context: context,
              onTap: () async {
                await context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.planned,
                  title: 'Planned',
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.task_alt,
              title: 'Completed',
              context: context,
              onTap: () async {
                await context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.completed,
                  title: 'Completed',
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.home_outlined,
              title: 'Tasks',
              context: context,
              onTap: () async {
                await context.read<TasksCubit>().loadTasks(
                  filter: TaskFilter.allTasks,
                  title: 'Tasks',
                );
              },
            ),

            Divider(color: AppColors.secondaryColor.withAlpha(77)),

            Expanded(
              child: BlocBuilder<ListsCubit, ListsState>(
                builder: (context, state) {
                  if (state is ListsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ListsLoaded) {
                    if (state.lists.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        child: Text(
                          'لا توجد قوائم مخصصة بعد',
                          style: AppTextStyle.style9W300.copyWith(
                            fontSize: 12.sp,
                            color: Colors.white.withAlpha(128),
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: state.lists.length,
                      itemBuilder: (context, index) {
                        final list = state.lists[index];

                        return _buildDrawerItem(
                          icon: Icons.list,
                          title: list.title,
                          context: context,
                          onTap: () async {
                            await context.read<TasksCubit>().loadTasks(
                              filter: TaskFilter.customList,
                              title: list.title,
                              customListId: list.id,
                            );
                          },
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            Divider(color: Colors.white.withAlpha(55)),

            _buildDrawerItem(
              icon: Icons.add,
              title: 'New list',
              iconColor: Colors.white,
              textColor: Colors.white,
              isBold: true,
              context: context,
              onTap: () async {
                Navigator.pop(context);
                await showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddListBottomSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BuildContext context,
    String? count,
    Color? iconColor,
    Color? textColor,
    bool isBold = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.white,
        size: 24.r,
      ),
      title: Text(
        title,
        style: AppTextStyle.style9W300.copyWith(
          fontSize: 14.sp,
          color: textColor ?? Colors.white,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: count != null
          ? Text(
              count,
              style: AppTextStyle.style9W300.copyWith(
                fontSize: 12.sp,
                color: Colors.white,
              ),
            )
          : null,
      onTap: () {
        // إذا لم تكن القائمة ثابتة (أي في الموبايل)، نقوم بإغلاقها أولاً
        if (!isPermanent) {
          Navigator.pop(context);
        }

        // ثم ننفذ الوظيفة الخاصة بالعنصر (مثل استدعاء الكيوبت)
        onTap();
      },
    );
  }
}
