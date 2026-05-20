import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/di.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/services/notification_permission_helper.dart';
import 'package:s/core/services/task_notification_service.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';
import 'package:s/features/task_management/domain/utils/repeat_format_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';
import 'package:s/features/task_management/presentation/views/widgets/custom_repeat_dialog.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({
    required this.isMyDayView,
    this.currentListId,
    super.key,
  });

  final String? currentListId;
  final bool isMyDayView;

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final TextEditingController _taskController = TextEditingController();

  DateTime? _selectedDueDate;
  String? _selectedRepeatMode;
  bool _pinToNotification = false;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  String _getRepeatCategory() {
    final mode = _selectedRepeatMode;
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

  Future<void> _handleRepeatSelection(String type) async {
    Navigator.pop(context);

    if (type == 'daily') {
      setState(() => _selectedRepeatMode = 'custom:1:days');
      return;
    }

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
      initialMode = _selectedRepeatMode ?? 'custom:1:weeks:${now.weekday}';
    }

    final result = await showCustomRepeatDialog(
      context,
      initialMode: initialMode,
    );

    if (result != null && mounted) {
      setState(() => _selectedRepeatMode = result);
    }
  }

  Future<void> _showRepeatOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        final category = _getRepeatCategory();

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

              _buildRepeatOptionTile(AppTexts.daily, 'daily', category),
              _buildRepeatOptionTile(AppTexts.weekdays, 'weekdays', category),
              _buildRepeatOptionTile(AppTexts.weekly, 'weekly', category),
              _buildRepeatOptionTile(AppTexts.monthly, 'monthly', category),
              _buildRepeatOptionTile(AppTexts.yearly, 'yearly', category),

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
                subtitle: category == 'custom' && _selectedRepeatMode != null
                    ? Text(
                        formatRepeatMode(_selectedRepeatMode),
                        style: AppTextStyle.style9W300.copyWith(
                          fontSize: 11.sp,
                          color: AppColors.secondaryColor,
                        ),
                      )
                    : null,
                onTap: () => _handleRepeatSelection('custom'),
              ),

              if (_selectedRepeatMode != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    AppTexts.removeRepeat,
                    style: AppTextStyle.style12W300.copyWith(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() => _selectedRepeatMode = null);
                    Navigator.pop(context);
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
  ) {
    final isSelected = currentCategory == type;
    String? subtitleText;

    if (isSelected &&
        type != 'daily' &&
        type != 'weekdays' &&
        _selectedRepeatMode != null) {
      subtitleText = formatRepeatMode(_selectedRepeatMode);
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
      onTap: () => _handleRepeatSelection(type),
    );
  }

  DateTime _alignDateWithRepeat(DateTime date, String? repeatMode) {
    if (repeatMode == null) return date;

    if (repeatMode == 'weekdays') {
      if (date.weekday == DateTime.saturday)
        return date.add(const Duration(days: 2));
      if (date.weekday == DateTime.sunday)
        return date.add(const Duration(days: 1));
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
          if (date.day < targetDay)
            return DateTime(date.year, date.month, targetDay);
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

    var daysToNextSunday = DateTime.sunday - now.weekday;
    if (daysToNextSunday <= 0) {
      daysToNextSunday += 7;
    }
    return now.add(Duration(days: daysToNextSunday));
  }

  Future<void> _showNotificationOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  AppTexts.notification,
                  style: AppTextStyle.style14W300.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: AppColors.secondaryColor.withAlpha(77),
              ),
              SwitchListTile(
                secondary: const Icon(
                  Icons.push_pin,
                  color: AppColors.primaryColor,
                ),
                title: Text(
                  AppTexts.pinToNotification,
                  style: AppTextStyle.style12W300,
                ),
                subtitle: Text(
                  AppTexts.pinnedTasksChannelDesc,
                  style: AppTextStyle.style9W300.copyWith(
                    fontSize: 11.sp,
                    color: AppColors.secondaryColor,
                  ),
                ),
                value: _pinToNotification,
                activeThumbColor: AppColors.primaryColor,
                onChanged: (value) async {
                  if (value) {
                    final result = await getIt<TaskNotificationService>()
                        .ensurePermission();
                    if (!context.mounted) return;
                    if (result != NotificationPermissionResult.granted) {
                      await NotificationPermissionHelper.showPermissionDialog(
                        context,
                        result,
                      );
                      return;
                    }
                  }
                  setState(() => _pinToNotification = value);
                  if (context.mounted) Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDueDateOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        final now = DateTime.now();
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
              Divider(
                height: 1,
                color: AppColors.secondaryColor.withAlpha(77),
              ),
              ListTile(
                leading: const Icon(Icons.today, color: AppColors.primaryColor),
                title: Text(AppTexts.today, style: AppTextStyle.style12W300),
                onTap: () {
                  setState(() => _selectedDueDate = now);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event, color: AppColors.primaryColor),
                title: Text(AppTexts.tomorrow, style: AppTextStyle.style12W300),
                onTap: () {
                  setState(
                    () => _selectedDueDate = now.add(const Duration(days: 1)),
                  );
                  Navigator.pop(context);
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
                onTap: () {
                  setState(() => _selectedDueDate = _getNextWeekDate());
                  Navigator.pop(context);
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
                    initialDate: now,
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 365 * 5)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.primaryColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedDueDate = pickedDate);
                  }
                },
              ),

              if (_selectedDueDate != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    AppTexts.removeDueDate,
                    style: AppTextStyle.style12W300.copyWith(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() => _selectedDueDate = null);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset : 20.h,
        top: 20.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomPrimaryTextfield(
            controller: _taskController,
            autofocus: true,
            text: AppTexts.addTask,
          ),

          SizedBox(height: 16.h),
          Row(
            children: [
              _buildActionIcon(
                icon: _selectedDueDate != null
                    ? CupertinoIcons.calendar_circle_fill
                    : CupertinoIcons.calendar_circle,
                isActive: _selectedDueDate != null,
                onTap: _showDueDateOptions,
              ),
              SizedBox(width: 16.w),

              _buildActionIcon(
                icon: _pinToNotification
                    ? CupertinoIcons.bell_fill
                    : CupertinoIcons.bell,
                isActive: _pinToNotification,
                onTap: _showNotificationOptions,
              ),
              SizedBox(width: 16.w),

              _buildActionIcon(
                icon: _selectedRepeatMode != null
                    ? CupertinoIcons.repeat_1
                    : CupertinoIcons.repeat,
                isActive: _selectedRepeatMode != null,
                onTap: _showRepeatOptions,
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: Size(60.w, 40.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(320.r),
                  ),
                ),
                onPressed: () async {
                  if (_taskController.text.trim().isEmpty) return;

                  if (_pinToNotification) {
                    final result = await getIt<TaskNotificationService>()
                        .ensurePermission();
                    if (!context.mounted) return;
                    if (result != NotificationPermissionResult.granted) {
                      await NotificationPermissionHelper.showPermissionDialog(
                        context,
                        result,
                      );
                      return;
                    }
                  }

                  final now = DateTime.now();
                  final hasRepeat = _selectedRepeatMode != null;

                  final initialDate =
                      _selectedDueDate ??
                      ((widget.isMyDayView || hasRepeat)
                          ? DateTime(now.year, now.month, now.day)
                          : null);

                  final dueDate = initialDate != null
                      ? _alignDateWithRepeat(initialDate, _selectedRepeatMode)
                      : null;

                  String? finalMyDayDate;
                  if (widget.isMyDayView) {
                    final today = DateTime(now.year, now.month, now.day);
                    if (dueDate != null && dueDate.isAfter(today)) {
                      finalMyDayDate = null;
                    } else {
                      finalMyDayDate = deriveMyDayDateWhenAddingFromMyDayView(
                        reference: now,
                        dueDate: dueDate,
                        repeatMode: _selectedRepeatMode,
                      );
                    }
                  }

                  final newTask = TaskEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _taskController.text.trim(),
                    listId: widget.currentListId,
                    myDayDate: finalMyDayDate,
                    dueDate: dueDate,
                    repeatMode: _selectedRepeatMode,
                    isPinnedToNotification: _pinToNotification,
                    position: 0,
                  );

                  await context.read<TasksCubit>().addTask(newTask);

                  Navigator.pop(context);
                },
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Icon(
          icon,
          color: isActive ? AppColors.primaryColor : AppColors.secondaryColor,
          size: 20.r,
        ),
      ),
    );
  }
}
