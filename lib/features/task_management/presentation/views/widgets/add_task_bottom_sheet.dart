import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
import 'package:s/features/task_management/domain/utils/my_day_utils.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

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
                  style: AppTextStyle.style9W300.copyWith(
                    fontSize: 16.sp,
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
                title: Text(AppTexts.today, style: AppTextStyle.style9W300),
                onTap: () {
                  setState(() => _selectedDueDate = now);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event, color: AppColors.primaryColor),
                title: Text(AppTexts.tomorrow, style: AppTextStyle.style9W300),
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
                title: Text(AppTexts.nextWeek, style: AppTextStyle.style9W300),
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
                  style: AppTextStyle.style9W300,
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
                    style: AppTextStyle.style9W300.copyWith(color: Colors.red),
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
                  style: AppTextStyle.style9W300.copyWith(
                    fontSize: 16.sp,
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
                leading: const Icon(
                  Icons.dashboard_customize,
                  color: AppColors.secondaryColor,
                ),
                title: Text(AppTexts.custom, style: AppTextStyle.style9W300),
                onTap: _showCustomRepeatDialog,
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
        style: AppTextStyle.style9W300.copyWith(
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
              hintStyle: AppTextStyle.style9W300.copyWith(
                fontSize: 16.sp,
                color: AppColors.secondaryColor,
              ),
            ),
            style: AppTextStyle.style9W300.copyWith(fontSize: 16.sp),
          ),

          SizedBox(height: 16.h),
          Row(
            children: [
              _buildActionIcon(
                icon: Icons.calendar_today,
                isActive: _selectedDueDate != null,
                onTap: _showDueDateOptions,
              ),
              SizedBox(width: 16.w),

              _buildActionIcon(
                icon: Icons.notifications_none,
                isActive: false,
                onTap: () {},
              ),
              SizedBox(width: 16.w),

              _buildActionIcon(
                icon: Icons.repeat,
                isActive: _selectedRepeatMode != null,
                onTap: _showRepeatOptions,
              ),
              const Spacer(),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: Size(70.w, 35.h),
                ),
                onPressed: () async {
                  if (_taskController.text.trim().isEmpty) return;

                  final now = DateTime.now();
                  final hasRepeat = _selectedRepeatMode != null;
                  final dueDate = _selectedDueDate ??
                      ((widget.isMyDayView || hasRepeat)
                          ? DateTime(now.year, now.month, now.day)
                          : null);

                  final newTask = TaskEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _taskController.text.trim(),
                    listId: widget.currentListId,
                    myDayDate: widget.isMyDayView
                        ? formatMyDayDate(now)
                        : null,
                    dueDate: dueDate,
                    repeatMode: _selectedRepeatMode,
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
          size: 24.r,
        ),
      ),
    );
  }

  Future<void> _showCustomRepeatDialog() async {
    var count = 1;
    var unit = 'weeks';
    final selectedDays = <int>[
      DateTime.now().weekday,
    ];

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: AppColors.scaffoldBackgroundLightColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              title: Text(
                AppTexts.customRepeat,
                style: AppTextStyle.style9W300.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        AppTexts.repeatEvery,
                        style: AppTextStyle.style9W300.copyWith(
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        width: 50.w,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.style9W300.copyWith(
                            fontSize: 14.sp,
                          ),
                          controller:
                              TextEditingController(text: count.toString())
                                ..selection = TextSelection.collapsed(
                                  offset: count.toString().length,
                                ),
                          onChanged: (val) {
                            count = int.tryParse(val) ?? 1;
                          },
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: unit,
                          dropdownColor: AppColors.scaffoldBackgroundLightColor,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                          ),
                          style: AppTextStyle.style9W300.copyWith(
                            fontSize: 14.sp,
                            color: AppColors.forthColor,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'days',
                              child: Text(AppTexts.days),
                            ),
                            DropdownMenuItem(
                              value: 'weeks',
                              child: Text(AppTexts.weeks),
                            ),
                            DropdownMenuItem(
                              value: 'months',
                              child: Text(AppTexts.months),
                            ),
                            DropdownMenuItem(
                              value: 'years',
                              child: Text(AppTexts.years),
                            ),
                          ],
                          onChanged: (val) {
                            setStateDialog(() => unit = val!);
                          },
                        ),
                      ),
                    ],
                  ),

                  if (unit == 'weeks') ...[
                    SizedBox(height: 20.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppTexts.inTheseDays,
                        style: AppTextStyle.style9W300.copyWith(
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildDayToggle(
                          DateTime.sunday,
                          AppTexts.sunday,
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.monday,
                          AppTexts.monday,
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.tuesday,
                          AppTexts.tuesday,
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.wednesday,
                          AppTexts.wednesday,
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.thursday,
                          AppTexts.thursday,
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.friday,
                          AppTexts.friday,
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.saturday,
                          AppTexts.saturday,
                          selectedDays,
                          setStateDialog,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppTexts.cancel,
                    style: AppTextStyle.style9W300.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                  ),
                  onPressed: () {
                    final daysStr = selectedDays.join(',');
                    final customMode = 'custom:$count:$unit:$daysStr';

                    setState(() => _selectedRepeatMode = customMode);
                    Navigator.pop(context);
                    Navigator.pop(
                      context,
                    );
                  },
                  child: Text(
                    AppTexts.save,
                    style: AppTextStyle.style9W300.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDayToggle(
    int dayValue,
    String label,
    List<int> selectedDays,
    StateSetter setStateDialog,
  ) {
    final isSelected = selectedDays.contains(dayValue);
    return InkWell(
      onTap: () {
        setStateDialog(() {
          if (isSelected && selectedDays.length > 1) {
            selectedDays.remove(dayValue);
          } else if (!isSelected) {
            selectedDays.add(dayValue);
          }
        });
      },
      child: CircleAvatar(
        radius: 16.r,
        backgroundColor: isSelected
            ? AppColors.primaryColor
            : AppColors.secondaryColor.withAlpha(51),
        child: Text(
          label,
          style: AppTextStyle.style9W300.copyWith(
            fontSize: 14.sp,
            color: isSelected ? Colors.white : AppColors.forthColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
