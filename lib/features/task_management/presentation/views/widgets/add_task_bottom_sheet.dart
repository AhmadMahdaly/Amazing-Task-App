import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/di.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/services/notification_permission_helper.dart';
import 'package:s/core/services/task_notification_service.dart';
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
                title: Text(AppTexts.nextWeek, style: AppTextStyle.style12W300),
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

  Future<void> _showRepeatOptions() async {
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
                  AppTexts.repeat,
                  style: AppTextStyle.style14W300.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: AppColors.secondaryColor.withAlpha(77),
              ),
              _buildRepeatOptionTile(AppTexts.daily, 'daily'),
              _buildRepeatOptionTile(AppTexts.weekdays, 'weekdays'),
              _buildRepeatOptionTile(AppTexts.weekly, 'weekly'),
              _buildRepeatOptionTile(AppTexts.monthly, 'monthly'),
              _buildRepeatOptionTile(AppTexts.yearly, 'yearly'),

              ListTile(
                leading: Icon(
                  Icons.dashboard_customize,
                  color: isCustomRepeatMode(_selectedRepeatMode)
                      ? AppColors.primaryColor
                      : AppColors.secondaryColor,
                ),
                title: Text(
                  AppTexts.custom,
                  style: AppTextStyle.style12W300.copyWith(
                    color: isCustomRepeatMode(_selectedRepeatMode)
                        ? AppColors.primaryColor
                        : null,
                    fontWeight: isCustomRepeatMode(_selectedRepeatMode)
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                subtitle: isCustomRepeatMode(_selectedRepeatMode)
                    ? Text(
                        formatRepeatMode(_selectedRepeatMode),
                        style: AppTextStyle.style9W300.copyWith(
                          fontSize: 11.sp,
                          color: AppColors.secondaryColor,
                        ),
                      )
                    : null,
                onTap: () async {
                  Navigator.pop(context);
                  await _showCustomRepeatDialog();
                },
              ),
              if (_selectedRepeatMode != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    AppTexts.removeRepeat,
                    style: AppTextStyle.style9W300.copyWith(color: Colors.red),
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

  ListTile _buildRepeatOptionTile(String title, String value) {
    return ListTile(
      leading: Icon(
        Icons.repeat,
        color: _selectedRepeatMode == value
            ? AppColors.primaryColor
            : AppColors.secondaryColor,
      ),
      title: Text(
        title,
        style: AppTextStyle.style12W300.copyWith(
          color: _selectedRepeatMode == value ? AppColors.primaryColor : null,
          fontWeight: _selectedRepeatMode == value
              ? FontWeight.bold
              : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => _selectedRepeatMode = value);
        Navigator.pop(context);
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
        color: AppColors.scaffoldBackgroundLightColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _taskController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppTexts.addTask,
              border: InputBorder.none,
              hintStyle: AppTextStyle.style14W500.copyWith(
                color: AppColors.secondaryColor.withAlpha(100),
              ),
            ),
            style: AppTextStyle.style14W500,
          ),

          SizedBox(height: 16.h),
          Row(
            children: [
              _buildActionIcon(
                icon: _selectedDueDate != null
                    ? Icons.event
                    : Icons.calendar_today,
                isActive: _selectedDueDate != null,
                onTap: _showDueDateOptions,
              ),
              SizedBox(width: 16.w),

              _buildActionIcon(
                icon: _pinToNotification
                    ? Icons.notifications_active
                    : Icons.notifications_none,
                isActive: _pinToNotification,
                onTap: _showNotificationOptions,
              ),
              SizedBox(width: 16.w),

              _buildActionIcon(
                icon: _selectedRepeatMode != null
                    ? Icons.repeat_on
                    : Icons.repeat,
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
                  final dueDate =
                      _selectedDueDate ??
                      ((widget.isMyDayView || hasRepeat)
                          ? DateTime(now.year, now.month, now.day)
                          : null);

                  final newTask = TaskEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _taskController.text.trim(),
                    listId: widget.currentListId,
                    myDayDate: widget.isMyDayView
                        ? deriveMyDayDateWhenAddingFromMyDayView(
                            reference: now,
                            dueDate: dueDate,
                            repeatMode: _selectedRepeatMode,
                          )
                        : null,
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

  Future<void> _showCustomRepeatDialog() async {
    final result = await showCustomRepeatDialog(
      context,
      initialMode: _selectedRepeatMode,
    );
    if (result != null && mounted) {
      setState(() => _selectedRepeatMode = result);
    }
  }
}
