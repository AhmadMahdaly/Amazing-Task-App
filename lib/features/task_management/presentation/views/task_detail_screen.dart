// ignore_for_file: curly_braces_in_flow_control_structures, deprecated_member_use, discarded_futures, parameter_assignments

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/services/notification_permission_helper.dart';
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
import 'package:s/features/task_management/presentation/views/widgets/section_card.dart';
import 'package:s/features/task_management/presentation/views/widgets/settings_tile.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({required this.taskId, super.key});

  final String taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _titleController = TextEditingController();
  final _stepController = TextEditingController();
  final _noteController = TextEditingController();
  late TasksCubit _tasksCubit;
  final _titleFocus = FocusNode();
  final _noteFocus = FocusNode();

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tasksCubit = context.read<TasksCubit>();
    _titleFocus.addListener(_onTitleFocusChange);
    _noteFocus.addListener(_onNoteFocusChange);
  }

  @override
  void dispose() {
    _saveCurrentTitle();
    _saveCurrentNote();
    _titleController.dispose();
    _stepController.dispose();
    _noteController.dispose();
    _titleFocus.dispose();
    _noteFocus.dispose();
    super.dispose();
  }

  void _onTitleFocusChange() {
    if (!_titleFocus.hasFocus) _saveCurrentTitle();
  }

  void _onNoteFocusChange() {
    if (!_noteFocus.hasFocus) _saveCurrentNote();
  }

  TaskEntity? _findTask(TasksState state) {
    if (state is! TasksLoaded) return null;
    for (final t in state.allTasks) {
      if (t.id == widget.taskId) return t;
    }
    return null;
  }

  Future<void> _persist(TaskEntity task) async {
    await _tasksCubit.updateTask(task);
  }

  void _saveCurrentTitle() {
    final task = _findTask(_tasksCubit.state);
    if (task == null) return;

    final title = _titleController.text.trim();
    if (title.isNotEmpty && title != task.title) {
      _persist(task.copyWith(title: title));
    }
  }

  void _saveCurrentNote() {
    final task = _findTask(_tasksCubit.state);
    if (task == null) return;

    final note = _noteController.text.trim();
    if (note != (task.note ?? '')) {
      _persist(task.copyWith(note: note));
    }
  }

  Future<void> _addStep(TaskEntity task) async {
    final title = _stepController.text.trim();
    if (title.isEmpty) return;

    final newStep = TaskStep(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
    );
    _stepController.clear();
    // FocusScope.of(context).unfocus();

    await _persist(syncTaskStepCounts(task, [...task.steps, newStep]));
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dispose();
    });
    if (title.isEmpty) return;

    final steps = List<TaskStep>.from(task.steps);
    steps[index] = steps[index].copyWith(title: title);
    await _persist(syncTaskStepCounts(task, steps));
  }

  Future<void> _showDueDateOptions(TaskEntity task) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  AppTexts.dueDate,
                  style: AppTextStyle.style14W300.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.secondaryColor.withAlpha(77)),
              ListTile(
                leading: const Icon(Icons.today, color: AppColors.primaryColor),
                title: Text(AppTexts.today, style: AppTextStyle.style12W300),
                onTap: () async {
                  Navigator.pop(context);

                  final alignedDate = _alignDateWithRepeat(
                    today,
                    task.repeatMode,
                  );
                  await _persist(task.copyWith(dueDate: alignedDate));
                },
              ),
              ListTile(
                leading: const Icon(Icons.event, color: AppColors.primaryColor),
                title: Text(AppTexts.tomorrow, style: AppTextStyle.style12W300),
                onTap: () async {
                  Navigator.pop(context);
                  final tomorrow = today.add(const Duration(days: 1));
                  final alignedDate = _alignDateWithRepeat(
                    tomorrow,
                    task.repeatMode,
                  );
                  await _persist(task.copyWith(dueDate: alignedDate));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.next_plan_outlined,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  AppTexts.nextSunday,
                  style: AppTextStyle.style12W300,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final nextSun = _getNextWeekDate();
                  final alignedDate = _alignDateWithRepeat(
                    nextSun,
                    task.repeatMode,
                  );
                  await _persist(task.copyWith(dueDate: alignedDate));
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_month,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  AppTexts.pickADate,
                  style: AppTextStyle.style12W300,
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: task.dueDate ?? today,
                    firstDate: today,
                    lastDate: today.add(const Duration(days: 365 * 5)),
                  );
                  if (pickedDate != null) {
                    final cleanPicked = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                    );
                    final alignedDate = _alignDateWithRepeat(
                      cleanPicked,
                      task.repeatMode,
                    );
                    await _persist(task.copyWith(dueDate: alignedDate));
                  }
                },
              ),
              if (task.dueDate != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    AppTexts.removeDueDate,
                    style: AppTextStyle.style12W300.copyWith(color: Colors.red),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _persist(task.copyWith(clearDueDate: true));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  DateTime _alignDateWithRepeat(DateTime date, String? repeatMode) {
    if (repeatMode == null) return date;

    if (repeatMode == 'weekdays') {
      if (date.weekday == DateTime.saturday) {
        return date.add(const Duration(days: 2));
      }
      if (date.weekday == DateTime.sunday) {
        return date.add(const Duration(days: 1));
      }
      return date;
    }

    if (repeatMode.startsWith('custom:')) {
      final parts = repeatMode.split(':');
      final unit = parts.length > 2 ? parts[2] : '';

      if (unit == 'weeks' && parts.length > 3) {
        final daysStr = parts[3];
        if (daysStr.isEmpty) return date;
        final days =
            daysStr.split(',').map((e) => int.tryParse(e) ?? 1).toList()
              ..sort();
        if (days.contains(date.weekday)) return date;

        int? nextDay;
        for (final d in days) {
          if (d > date.weekday) {
            nextDay = d;
            break;
          }
        }
        if (nextDay != null) {
          return date.add(Duration(days: nextDay - date.weekday));
        } else {
          return date.add(Duration(days: (7 - date.weekday) + days.first));
        }
      } else if (unit == 'months' && parts.length > 3) {
        final targetDay = int.tryParse(parts[3]);
        if (targetDay != null) {
          if (date.day == targetDay) return date;
          if (date.day < targetDay) {
            return DateTime(date.year, date.month, targetDay);
          }
          return DateTime(date.year, date.month + 1, targetDay);
        }
      } else if (unit == 'years' && parts.length > 3) {
        final md = parts[3].split('-');
        if (md.length == 2) {
          final targetMonth = int.tryParse(md[0]);
          final targetDay = int.tryParse(md[1]);
          if (targetMonth != null && targetDay != null) {
            final cleanDate = DateTime(date.year, date.month, date.day);
            final candidate = DateTime(date.year, targetMonth, targetDay);
            if (candidate.isBefore(cleanDate)) {
              return DateTime(date.year + 1, targetMonth, targetDay);
            }
            return candidate;
          }
        }
      }
    }
    return date;
  }

  DateTime _getNextWeekDate() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    var daysToNextSunday = DateTime.sunday - today.weekday;
    if (daysToNextSunday <= 0) {
      daysToNextSunday += 7;
    }
    return today.add(Duration(days: daysToNextSunday));
  }

  Future<void> _showRepeatOptions(TaskEntity task) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        final category = _getRepeatCategory(task.repeatMode);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  AppTexts.repeat,
                  style: AppTextStyle.style14W300.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(height: 1, color: AppColors.secondaryColor.withAlpha(77)),
              _buildRepeatOptionTile(AppTexts.daily, 'daily', category, task),
              _buildRepeatOptionTile(
                AppTexts.weekdays,
                'weekdays',
                category,
                task,
              ),
              _buildRepeatOptionTile(AppTexts.weekly, 'weekly', category, task),
              _buildRepeatOptionTile(
                AppTexts.monthly,
                'monthly',
                category,
                task,
              ),
              _buildRepeatOptionTile(AppTexts.yearly, 'yearly', category, task),
              ListTile(
                leading: Icon(
                  Icons.dashboard_customize,
                  color: category == 'custom'
                      ? AppColors.primaryColor
                      : AppColors.secondaryColor,
                ),
                title: Text(
                  AppTexts.custom,
                  style: AppTextStyle.style12W300.copyWith(
                    color: category == 'custom' ? AppColors.primaryColor : null,
                    fontWeight: category == 'custom'
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: category == 'custom' && task.repeatMode != null
                    ? Text(
                        formatRepeatMode(task.repeatMode),
                        style: AppTextStyle.style9W300.copyWith(
                          fontSize: 11.sp,
                          color: AppColors.secondaryColor,
                        ),
                      )
                    : null,
                onTap: () => _handleRepeatSelection('custom', task),
              ),
              if (task.repeatMode != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    AppTexts.removeRepeat,
                    style: AppTextStyle.style12W300.copyWith(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);

                    _persist(task.copyWith(clearRepeatMode: true));
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  ListTile _buildRepeatOptionTile(
    String title,
    String type,
    String currentCategory,
    TaskEntity task,
  ) {
    final isSelected = currentCategory == type;
    String? subtitleText;

    if (isSelected &&
        type != 'daily' &&
        type != 'weekdays' &&
        task.repeatMode != null) {
      subtitleText = formatRepeatMode(task.repeatMode);
    }

    return ListTile(
      leading: Icon(
        Icons.repeat,
        color: isSelected ? AppColors.primaryColor : AppColors.secondaryColor,
      ),
      title: Text(
        title,
        style: AppTextStyle.style12W300.copyWith(
          color: isSelected ? AppColors.primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: subtitleText != null
          ? Text(
              subtitleText,
              style: AppTextStyle.style9W300.copyWith(
                fontSize: 11.sp,
                color: AppColors.secondaryColor,
              ),
            )
          : null,
      onTap: () => _handleRepeatSelection(type, task),
    );
  }

  Future<void> _handleRepeatSelection(String type, TaskEntity task) async {
    Navigator.pop(context);

    String? newRepeatMode;

    if (type == 'daily') {
      newRepeatMode = 'custom:1:days';
    } else {
      final now = DateTime.now();
      var initialMode = 'custom:1:weeks:${now.weekday}';

      if (type == 'weekdays') {
        initialMode = 'custom:1:weeks:1,2,3,4,7';
      } else if (type == 'weekly') {
        initialMode = 'custom:1:weeks:${now.weekday}';
      } else if (type == 'monthly') {
        initialMode = 'custom:1:months:${now.day}';
      } else if (type == 'yearly') {
        initialMode = 'custom:1:years:${now.month}-${now.day}';
      } else if (type == 'custom') {
        initialMode = task.repeatMode ?? 'custom:1:weeks:${now.weekday}';
      }

      final result = await showCustomRepeatDialog(
        context,
        initialMode: initialMode,
      );

      if (result == null) return;
      newRepeatMode = result;
    }

    if (mounted && newRepeatMode != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final baseDate = task.dueDate ?? today;

      final alignedDate = _alignDateWithRepeat(baseDate, newRepeatMode);

      await _persist(
        task.copyWith(
          repeatMode: newRepeatMode,
          dueDate: alignedDate,
        ),
      );
    }
  }

  String _getRepeatCategory(String? mode) {
    if (mode == null) return '';
    if (!mode.startsWith('custom:')) return mode;

    final parts = mode.split(':');
    final count = int.tryParse(parts[1]) ?? 1;
    final unit = parts.length > 2 ? parts[2] : '';

    if (count == 1) {
      if (unit == 'days') return 'daily';
      if (unit == 'weeks' && parts.length > 3) {
        final days =
            parts[3].split(',').map((e) => int.tryParse(e) ?? 0).toList()
              ..sort();
        final dStr = days.join(',');
        if (dStr == '1,2,3,4,5' || dStr == '1,2,3,4,7') return 'weekdays';
        if (days.length == 1) return 'weekly';
      }
      if (unit == 'months') return 'monthly';
      if (unit == 'years') return 'yearly';
    }
    return 'custom';
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

      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
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

  Future<void> _showReminderOptions(TaskEntity task) async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: task.reminderDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 5)),
    );

    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(task.reminderDate ?? now),
    );

    if (selectedTime == null || !mounted) return;

    final reminderDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    await _persist(task.copyWith(reminderDate: reminderDateTime));
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

        if (!_isInitialized) {
          _titleController.text = task.title;
          _noteController.text = task.note ?? '';
          _isInitialized = true;
        } else {
          if (!_titleFocus.hasFocus && _titleController.text != task.title) {
            _titleController.text = task.title;
          }
          if (!_noteFocus.hasFocus &&
              _noteController.text != (task.note ?? '')) {
            _noteController.text = task.note ?? '';
          }
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

        return PopScope(
          onPopInvoked: (didPop) {
            _saveCurrentTitle();
            _saveCurrentNote();
          },
          child: Scaffold(
            backgroundColor: AppColors.white,
            appBar: AppBar(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.white,
              title: Text(
                AppTexts.taskDetails,
                style: AppTextStyle.style16W300,
              ),
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
                SectionCard(
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
                              focusNode: _titleFocus,
                              style: AppTextStyle.style18Bold.copyWith(
                                decoration: task.isCompleted
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                              onFieldSubmitted: (_) => _saveCurrentTitle(),
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
                SectionCard(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomPrimaryTextfield(
                              controller: _stepController,
                              text: AppTexts.stepHint,
                              onChanged: (_) => setState(() {}),
                              onFieldSubmitted: (_) => _addStep(task),
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
                          onReorder: (oldIndex, newIndex) =>
                              _reorderSteps(task, oldIndex, newIndex),
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
                                                  color:
                                                      AppColors.secondaryColor,
                                                ),
                                          ),
                                          content: Text(
                                            AppTexts.convertStepToTaskQuestion,
                                            style: AppTextStyle.style9W300
                                                .copyWith(
                                                  color:
                                                      AppColors.secondaryColor,
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
                                                      color: AppColors
                                                          .primaryColor,
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
                                  final newTaskId = await cubit
                                      .detachStepToTask(task, step);

                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          AppTexts.stepConvertedToTask,
                                          style: AppTextStyle.style12W300
                                              .copyWith(color: Colors.white),
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
                              child: Material(
                                color: AppColors.transparent,
                                child: ListTile(
                                  // contentPadding: EdgeInsets.zero,
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
                                  onTap: () => _editStep(task, index),
                                  trailing: ReorderableDragStartListener(
                                    index: index,
                                    child: const Icon(
                                      Icons.drag_handle,
                                      color: AppColors.secondaryColor,
                                    ),
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
                Text(AppTexts.taskSettings, style: AppTextStyle.style16Bold),
                8.verticalSpace,
                SectionCard(
                  child: Column(
                    children: [
                      SettingsTile(
                        icon: Icons.calendar_today,
                        title: AppTexts.next,
                        subtitle: task.dueDate != null
                            ? formatTaskDate(task.dueDate)
                            : AppTexts.noDueDate,
                        onTap: () => _showDueDateOptions(task),
                      ),
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.repeat,
                        title: AppTexts.repeat,
                        subtitle: _repeatLabel(task.repeatMode),
                        onTap: () => _showRepeatOptions(task),
                      ),
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.star,
                        title: AppTexts.important,
                        trailing: Switch(
                          value: task.isImportant,
                          activeThumbColor: AppColors.primaryColor,
                          onChanged: (v) async =>
                              _persist(task.copyWith(isImportant: v)),
                        ),
                      ),
                      const Divider(height: 1),
                      SettingsTile(
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
                      SettingsTile(
                        icon: Icons.alarm,
                        title: AppTexts.remindMe,
                        subtitle: task.reminderDate != null
                            ? formatTaskDate(task.reminderDate)
                            : AppTexts.noReminder,
                        onTap: () => _showReminderOptions(task),
                      ),
                      // subtitle: task.isPinnedToNotification
                      //     ? AppTexts.pinnedToNotification
                      //     : AppTexts.unpinFromNotification,
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.notifications_active,
                        title: AppTexts.pinToNotification,
                        trailing: Switch(
                          value: task.isPinnedToNotification,
                          activeThumbColor: AppColors.primaryColor,
                          onChanged: task.isCompleted
                              ? null
                              : (v) async {
                                  final blocked = await context
                                      .read<TasksCubit>()
                                      .setPinnedToNotification(task, pinned: v);
                                  if (!context.mounted || blocked == null)
                                    return;
                                  await NotificationPermissionHelper.showPermissionDialog(
                                    context,
                                    blocked,
                                  );
                                },
                        ),
                      ),
                      const Divider(height: 1),
                      SettingsTile(
                        icon: Icons.list,
                        title: AppTexts.selectList,
                        subtitle: listName,
                        onTap: () => _showListPicker(task),
                      ),
                    ],
                  ),
                ),
                24.verticalSpace,
                Text(AppTexts.notes, style: AppTextStyle.style16Bold),
                8.verticalSpace,
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomPrimaryTextfield(
                        controller: _noteController,
                        focusNode: _noteFocus,
                        text: AppTexts.addNote,
                        maxLines: 6,
                        onFieldSubmitted: (_) => _saveCurrentNote(),
                      ),
                    ],
                  ),
                ),
                24.verticalSpace,
              ],
            ),
          ),
        );
      },
    );
  }
}
