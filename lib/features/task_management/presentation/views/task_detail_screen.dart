// ignore_for_file: parameter_assignments

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/services/notification_permission_helper.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/core/shared_widgets/directional_text.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/entities/task_step.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';
import 'package:s/features/task_management/domain/utils/repeat_format_utils.dart';
import 'package:s/features/task_management/domain/utils/task_format_utils.dart';
import 'package:s/features/task_management/domain/utils/task_steps_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/widgets/custom_repeat_dialog.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final String taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _stepController = TextEditingController();
  bool _titleDirty = false;

  @override
  void dispose() {
    _titleController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  TaskEntity? _findTask(TasksState state) {
    if (state is! TasksLoaded) return null;
    for (final t in state.allTasks) {
      if (t.id == widget.taskId) return t;
    }
    return null;
  }

  Future<void> _persist(TaskEntity task) async {
    await context.read<TasksCubit>().updateTask(task);
  }

  Future<void> _saveTitle(TaskEntity task) async {
    final title = _titleController.text.trim();
    if (title.isEmpty || title == task.title) return;
    await _persist(task.copyWith(title: title));
    setState(() => _titleDirty = false);
  }

  Future<void> _addStep(TaskEntity task) async {
    final title = _stepController.text.trim();
    if (title.isEmpty) return;

    final newStep = TaskStep(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _stepController.clear();
    await _persist(
      syncTaskStepCounts(task, [...task.steps, newStep]),
    );
  }

  Future<void> _toggleStep(TaskEntity task, int index) async {
    final steps = List<TaskStep>.from(task.steps);
    steps[index] = steps[index].copyWith(
      isCompleted: !steps[index].isCompleted,
    );

    var updated = syncTaskStepCounts(task, steps);
    if (areAllStepsCompleted(steps) && !updated.isCompleted) {
      updated = updated.copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
      );
    }
    await _persist(updated);
  }

  Future<void> _deleteStep(TaskEntity task, int index) async {
    final steps = List<TaskStep>.from(task.steps)..removeAt(index);
    await _persist(syncTaskStepCounts(task, steps));
  }

  Future<void> _reorderSteps(
    TaskEntity task,
    int oldIndex,
    int newIndex,
  ) async {
    final steps = List<TaskStep>.from(task.steps);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = steps.removeAt(oldIndex);
    steps.insert(newIndex, item);
    await _persist(syncTaskStepCounts(task, steps));
  }

  Future<void> _editStep(TaskEntity task, int index) async {
    final step = task.steps[index];
    final controller = TextEditingController(text: step.title);

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(AppTexts.editStep, style: AppTextStyle.style9W300),
          content: CustomPrimaryTextfield(
            controller: controller,
            autofocus: true,
            text: AppTexts.stepHint,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(AppTexts.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(AppTexts.save),
            ),
          ],
        );
      },
    );

    if (saved != true) {
      controller.dispose();
      return;
    }

    final title = controller.text.trim();
    controller.dispose();
    if (title.isEmpty) return;

    final steps = List<TaskStep>.from(task.steps);
    steps[index] = steps[index].copyWith(title: title);
    await _persist(syncTaskStepCounts(task, steps));
  }

  Future<void> _showDueDateOptions(TaskEntity task) async {
    final now = DateTime.now();
    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.today, color: AppColors.primaryColor),
                title: Text(AppTexts.today, style: AppTextStyle.style9W300),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _persist(task.copyWith(dueDate: now));
                },
              ),
              ListTile(
                leading: const Icon(Icons.event, color: AppColors.primaryColor),
                title: Text(AppTexts.tomorrow, style: AppTextStyle.style9W300),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _persist(
                    task.copyWith(dueDate: now.add(const Duration(days: 1))),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: AppColors.primaryColor,
                ),
                title: Text(AppTexts.pickADate, style: AppTextStyle.style9W300),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: task.dueDate ?? now,
                    firstDate: now.subtract(const Duration(days: 365)),
                    lastDate: now.add(const Duration(days: 365 * 5)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: AppColors.primaryColor,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    await _persist(task.copyWith(dueDate: picked));
                  }
                },
              ),
              if (task.dueDate != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    AppTexts.removeDueDate,
                    style: AppTextStyle.style9W300.copyWith(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _persist(task.copyWith(clearDueDate: true));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRepeatPicker(TaskEntity task) async {
    var selected = task.repeatMode;

    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      AppTexts.repeat,
                      style: AppTextStyle.style9W300.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _repeatTile(
                    AppTexts.daily,
                    'daily',
                    selected,
                    (v) => setSheetState(() => selected = v),
                  ),
                  _repeatTile(
                    AppTexts.weekdays,
                    'weekdays',
                    selected,
                    (v) => setSheetState(() => selected = v),
                  ),
                  _repeatTile(
                    AppTexts.weekly,
                    'weekly',
                    selected,
                    (v) => setSheetState(() => selected = v),
                  ),
                  _repeatTile(
                    AppTexts.monthly,
                    'monthly',
                    selected,
                    (v) => setSheetState(() => selected = v),
                  ),
                  _repeatTile(
                    AppTexts.yearly,
                    'yearly',
                    selected,
                    (v) => setSheetState(() => selected = v),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.dashboard_customize,
                      color: isCustomRepeatMode(selected)
                          ? AppColors.primaryColor
                          : AppColors.secondaryColor,
                    ),
                    title: Text(
                      AppTexts.custom,
                      style: AppTextStyle.style12W300.copyWith(
                        color: isCustomRepeatMode(selected)
                            ? AppColors.primaryColor
                            : null,
                        fontWeight: isCustomRepeatMode(selected)
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    subtitle: isCustomRepeatMode(selected)
                        ? Text(
                            formatRepeatMode(selected),
                            style: AppTextStyle.style9W300.copyWith(
                              fontSize: 11.sp,
                              color: AppColors.secondaryColor,
                            ),
                          )
                        : null,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      final result = await showCustomRepeatDialog(
                        context,
                        initialMode: isCustomRepeatMode(task.repeatMode)
                            ? task.repeatMode
                            : selected,
                      );
                      if (result != null && mounted) {
                        await _persist(task.copyWith(repeatMode: result));
                      }
                    },
                  ),
                  if (selected != null)
                    ListTile(
                      leading: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      title: Text(
                        AppTexts.removeRepeat,
                        style: AppTextStyle.style9W300.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      onTap: () => setSheetState(() => selected = null),
                    ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                        ),
                        onPressed: () async {
                          Navigator.pop(sheetContext);
                          if (selected == null) {
                            await _persist(
                              task.copyWith(clearRepeatMode: true),
                            );
                          } else {
                            await _persist(task.copyWith(repeatMode: selected));
                          }
                        },
                        child: Text(
                          AppTexts.save,
                          style: AppTextStyle.style9W300.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _repeatTile(
    String label,
    String value,
    String? selected,
    ValueChanged<String> onSelect,
  ) {
    final isSelected = selected == value;
    return ListTile(
      leading: Icon(
        Icons.repeat,
        color: isSelected ? AppColors.primaryColor : AppColors.secondaryColor,
      ),
      title: Text(
        label,
        style: AppTextStyle.style9W300.copyWith(
          color: isSelected ? AppColors.primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : null,
        ),
      ),
      onTap: () => onSelect(value),
    );
  }

  Future<void> _showListPicker(TaskEntity task) async {
    final listsState = context.read<ListsCubit>().state;
    if (listsState is! ListsLoaded) return;

    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  AppTexts.selectList,
                  style: AppTextStyle.style9W300.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.inbox_outlined),
                title: Text(AppTexts.generalTasks),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _persist(task.copyWith(clearListId: true));
                },
              ),
              ...listsState.lists.map(
                (list) => ListTile(
                  leading: const Icon(Icons.list),
                  title: Text(list.title),
                  trailing: task.listId == list.id
                      ? const Icon(Icons.check, color: AppColors.primaryColor)
                      : null,
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _persist(task.copyWith(listId: list.id));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppTexts.deleteTask,
          style: AppTextStyle.style14Bold.copyWith(
            color: AppColors.secondaryColor,
          ),
        ),
        content: Text(
          AppTexts.confirmDeleteTask,
          style: AppTextStyle.style9W300.copyWith(
            color: AppColors.secondaryColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              AppTexts.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if ((confirmed ?? false) && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      final cubit = context.read<TasksCubit>();
      final snapshot = task;
      await cubit.deleteTask(task.id);
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            AppTexts.taskDeleted,
            style: AppTextStyle.style12W300.copyWith(color: Colors.white),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          dismissDirection: DismissDirection.horizontal,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: AppTexts.undo,
            textColor: Colors.white,
            onPressed: () => unawaited(cubit.restoreTask(snapshot)),
          ),
        ),
      );
      if (mounted) context.pop();
    }
  }

  String _repeatLabel(String? mode) {
    if (mode == null) return AppTexts.removeRepeat;
    return formatRepeatMode(mode);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        final task = _findTask(state);
        if (task == null) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              title: Text(
                AppTexts.taskDetails,
                style: AppTextStyle.style16Bold,
              ),
            ),
            body: Center(
              child: Text(
                AppTexts.thereIsAnError,
                style: AppTextStyle.style12W300.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.white,
                ),
              ),
            ),
          );
        }

        if (!_titleDirty && _titleController.text != task.title) {
          _titleController.text = task.title;
        }

        final inMyDay = isTaskInMyDay(task);
        final listsState = context.watch<ListsCubit>().state;
        var listName = AppTexts.generalTasks;
        if (task.listId != null &&
            task.listId!.isNotEmpty &&
            listsState is ListsLoaded) {
          final matches = listsState.lists
              .where((l) => l.id == task.listId)
              .toList();
          if (matches.isNotEmpty) listName = matches.first.title;
        }

        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            foregroundColor: AppColors.white,
            title: Text(AppTexts.taskDetails, style: AppTextStyle.style16W300),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(task),
              ),
            ],
          ),
          body: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          onTap: () async {
                            await context
                                .read<TasksCubit>()
                                .toggleTaskCompletion(task);
                          },
                          child: Icon(
                            task.isCompleted
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: task.isCompleted
                                ? AppColors.primaryColor
                                : AppColors.secondaryColor,
                            size: 28.r,
                          ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: CustomPrimaryTextfield(
                            controller: _titleController,
                            style: AppTextStyle.style18Bold.copyWith(
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),

                            onChanged: (_) =>
                                setState(() => _titleDirty = true),
                            onFieldSubmitted: (_) => _saveTitle(task),
                          ),
                        ),
                      ],
                    ),
                    if (task.isCompleted) ...[
                      8.verticalSpace,
                      Row(
                        children: [
                          Icon(
                            Icons.event_available,
                            size: 16.r,
                            color: AppColors.thirdColor,
                          ),
                          6.horizontalSpace,
                          Text(
                            formatCompletedDate(task.completedAt),
                            style: AppTextStyle.style12W300.copyWith(
                              color: AppColors.thirdColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (task.dueDate != null && !task.isCompleted) ...[
                      4.verticalSpace,
                      Text(
                        '${AppTexts.next}: ${formatTaskDate(task.dueDate)}',
                        style: AppTextStyle.style12W300.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              16.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppTexts.steps, style: AppTextStyle.style16Bold),
                  if (task.hasSteps)
                    Padding(
                      padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                      child: Text(
                        '${task.completedSteps}/${task.totalSteps} ${AppTexts.completed}',
                        style: AppTextStyle.style12W300.copyWith(
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                ],
              ),

              _SectionCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomPrimaryTextfield(
                            controller: _stepController,
                            text: AppTexts.stepHint,
                            onChanged: (_) => setState(() {}),
                            onFieldSubmitted: (_) =>
                                setState(() => _addStep(task)),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        IconButton.filled(
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                          ),
                          onPressed: () => _addStep(task),
                          icon: const Icon(Icons.add, color: Colors.white),
                        ),
                      ],
                    ),
                    8.verticalSpace,
                    if (task.steps.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text(
                          AppTexts.noStepsYet,
                          style: AppTextStyle.style12W300.copyWith(
                            color: AppColors.secondaryColor,
                          ),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: task.steps.length,
                        onReorder: (oldIndex, newIndex) => setState(
                          () => _reorderSteps(task, oldIndex, newIndex),
                        ),
                        itemBuilder: (context, index) {
                          final step = task.steps[index];
                          return Dismissible(
                            key: ValueKey('${step.id}_dismissible'),
                            direction: DismissDirection.horizontal,

                            background: Container(
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.only(left: 16.w),
                              color: Colors.redAccent,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),

                            secondaryBackground: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 16.w),
                              color: AppColors.primaryColor,
                              child: const Icon(
                                Icons.call_split,
                                color: Colors.white,
                              ),
                            ),

                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                return await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: Text(
                                          AppTexts.separateStep,
                                          style: AppTextStyle.style14Bold
                                              .copyWith(
                                                color: AppColors.secondaryColor,
                                              ),
                                        ),
                                        content: Text(
                                          AppTexts.convertStepToTaskQuestion,
                                          style: AppTextStyle.style9W300
                                              .copyWith(
                                                color: AppColors.secondaryColor,
                                              ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: Text(AppTexts.cancel),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
                                            child: Text(
                                              AppTexts.confirm,
                                              style: AppTextStyle.style12Bold
                                                  .copyWith(
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ) ??
                                    false;
                              }
                              return true;
                            },

                            onDismissed: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                final cubit = context.read<TasksCubit>();
                                final originalTaskSnapshot = task;

                                final newTaskId = await cubit.detachStepToTask(
                                  task,
                                  step,
                                );

                                if (!mounted) return;

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      AppTexts.stepConvertedToTask,
                                      style: AppTextStyle.style12W300.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: AppColors.primaryColor,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 4),
                                    action: SnackBarAction(
                                      label: AppTexts.undo,
                                      textColor: Colors.white,
                                      onPressed: () {
                                        unawaited(
                                          cubit.undoDetachStep(
                                            originalTaskSnapshot,
                                            newTaskId,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              } else {
                                await _deleteStep(task, index);
                              }
                            },
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: InkWell(
                                onTap: () => _toggleStep(task, index),
                                child: Icon(
                                  step.isCompleted
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              title: DirectionalText(
                                step.title,
                                style: AppTextStyle.style9W300.copyWith(
                                  decoration: step.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: step.isCompleted
                                      ? AppColors.secondaryColor
                                      : AppColors.forthColor,
                                ),
                              ),
                              onTap: () =>
                                  setState(() => _editStep(task, index)),
                              trailing: ReorderableDragStartListener(
                                index: index,
                                child: const Icon(
                                  Icons.drag_handle,
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              20.verticalSpace,
              Text(
                AppTexts.taskSettings,
                style: AppTextStyle.style16Bold,
              ),
              8.verticalSpace,
              _SectionCard(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.calendar_today,
                      title: AppTexts.next,
                      subtitle: task.dueDate != null
                          ? formatTaskDate(task.dueDate)
                          : AppTexts.noDueDate,
                      onTap: () => _showDueDateOptions(task),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.repeat,
                      title: AppTexts.repeat,
                      subtitle: _repeatLabel(task.repeatMode),
                      onTap: () => _showRepeatPicker(task),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.star,
                      title: AppTexts.important,
                      // subtitle: task.isImportant ? AppTexts.important : '—',
                      trailing: Switch(
                        value: task.isImportant,
                        activeThumbColor: AppColors.primaryColor,
                        onChanged: (v) async {
                          await _persist(task.copyWith(isImportant: v));
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.wb_sunny_outlined,
                      title: AppTexts.myDay,
                      subtitle: inMyDay
                          ? AppTexts.inMyDay
                          : AppTexts.notInMyDay,
                      trailing: Switch(
                        value: inMyDay,
                        activeThumbColor: AppColors.primaryColor,
                        onChanged: (v) async {
                          if (v) {
                            await context.read<TasksCubit>().addToMyDay(task);
                          } else {
                            await context.read<TasksCubit>().removeFromMyDay(
                              task,
                            );
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.notifications_active,
                      title: AppTexts.pinToNotification,
                      // subtitle: task.isPinnedToNotification
                      //     ? AppTexts.pinnedToNotification
                      //     : AppTexts.unpinFromNotification,
                      trailing: Switch(
                        value: task.isPinnedToNotification,
                        activeThumbColor: AppColors.primaryColor,
                        onChanged: task.isCompleted
                            ? null
                            : (v) async {
                                final blocked = await context
                                    .read<TasksCubit>()
                                    .setPinnedToNotification(
                                      task,
                                      pinned: v,
                                    );
                                if (!context.mounted || blocked == null) {
                                  return;
                                }
                                await NotificationPermissionHelper.showPermissionDialog(
                                  context,
                                  blocked,
                                );
                              },
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.list,
                      title: AppTexts.selectList,
                      subtitle: listName,
                      onTap: () => _showListPicker(task),
                    ),
                  ],
                ),
              ),
              24.verticalSpace,
              if (_titleDirty)
                CustomPrimaryButton(
                  width: double.infinity,

                  onPressed: () => _saveTitle(task),
                  text: AppTexts.save,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.forthColor.withAlpha(15),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title, style: AppTextStyle.style12W300),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTextStyle.style12W300.copyWith(
                color: AppColors.secondaryColor,
              ),
            )
          : null,
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
