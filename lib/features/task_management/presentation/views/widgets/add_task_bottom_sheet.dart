import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/theme/app_colors.dart';
import 'package:s/core/theme/app_text_style.dart';
import 'package:s/features/task_management/domain/entities/task_entity.dart';
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

  // المتغيرات الجديدة لحفظ الاختيارات
  DateTime? _selectedDueDate;
  String? _selectedRepeatMode;

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  // حساب تاريخ بداية الأسبوع القادم (بافتراض أن الأسبوع يبدأ الأحد)
  DateTime _getNextWeekDate() {
    final now = DateTime.now();
    // Dart يعتبر الأحد = 7، الإثنين = 1
    var daysToNextSunday = DateTime.sunday - now.weekday;
    if (daysToNextSunday <= 0) {
      daysToNextSunday += 7; // إذا كنا في يوم الأحد، الأسبوع القادم بعد 7 أيام
    }
    return now.add(Duration(days: daysToNextSunday));
  }

  // --- نافذة اختيار تاريخ الاستحقاق ---
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
                  'تاريخ الاستحقاق',
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
                title: Text('اليوم', style: AppTextStyle.style9W300),
                onTap: () {
                  setState(() => _selectedDueDate = now);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.event, color: AppColors.primaryColor),
                title: Text('الغد', style: AppTextStyle.style9W300),
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
                title: Text('الأسبوع القادم', style: AppTextStyle.style9W300),
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
                  'اختيار تاريخ (Pick a date)',
                  style: AppTextStyle.style9W300,
                ),
                onTap: () async {
                  Navigator.pop(context); // إغلاق القائمة أولاً
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
              // خيار لإزالة التاريخ إذا كان محددًا
              if (_selectedDueDate != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'إزالة تاريخ الاستحقاق',
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

  // --- نافذة اختيار التكرار ---
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
                  'تكرار',
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
              _buildRepeatOptionTile('يومي (Daily)', 'daily'),
              _buildRepeatOptionTile('أيام الأسبوع (Weekdays)', 'weekdays'),
              _buildRepeatOptionTile('أسبوعي (Weekly)', 'weekly'),
              _buildRepeatOptionTile('شهري (Monthly)', 'monthly'),
              _buildRepeatOptionTile('سنوي (Yearly)', 'yearly'),
              // داخل دالة _showRepeatOptions
              ListTile(
                leading: const Icon(
                  Icons.dashboard_customize,
                  color: AppColors.secondaryColor,
                ),
                title: Text('مخصص (Custom)', style: AppTextStyle.style9W300),
                onTap: _showCustomRepeatDialog,
              ),
              if (_selectedRepeatMode != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'إزالة التكرار',
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
              hintText: 'إضافة مهمة',
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
              // زر تاريخ الاستحقاق
              _buildActionIcon(
                icon: Icons.calendar_today,
                isActive: _selectedDueDate != null,
                onTap: _showDueDateOptions,
              ),
              SizedBox(width: 16.w),

              // زر التذكير (متروك لتطويره لاحقاً)
              _buildActionIcon(
                icon: Icons.notifications_none,
                isActive: false,
                onTap: () {},
              ),
              SizedBox(width: 16.w),

              // زر التكرار
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

                  final newTask = TaskEntity(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _taskController.text.trim(),
                    listId: widget.currentListId,
                    // حفظ تاريخ اليوم في myDayDate إذا كنا في شاشة "يومي"
                    myDayDate: widget.isMyDayView
                        ? DateTime.now().toIso8601String().split('T')[0]
                        : null,
                    // إضافة البيانات الجديدة
                    dueDate: _selectedDueDate,
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

  // دالة مخصصة للأيقونات تتغير لونها بناءً على الـ isActive
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

  // --- دالة إظهار نافذة التكرار المخصص ---
  Future<void> _showCustomRepeatDialog() async {
    var count = 1;
    var unit = 'weeks'; // 'days', 'weeks', 'months', 'years'
    final selectedDays = <int>[
      DateTime.now().weekday,
    ]; // افتراضياً نحدد يوم المهمة

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
                'تكرار مخصص',
                style: AppTextStyle.style9W300.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- الصف الأول: اختيار الرقم والوحدة ---
                  Row(
                    children: [
                      Text(
                        'تكرار كل',
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
                          items: const [
                            DropdownMenuItem(
                              value: 'days',
                              child: Text('أيام'),
                            ),
                            DropdownMenuItem(
                              value: 'weeks',
                              child: Text('أسابيع'),
                            ),
                            DropdownMenuItem(
                              value: 'months',
                              child: Text('شهور'),
                            ),
                            DropdownMenuItem(
                              value: 'years',
                              child: Text('سنين'),
                            ),
                          ],
                          onChanged: (val) {
                            setStateDialog(() => unit = val!);
                          },
                        ),
                      ),
                    ],
                  ),

                  // --- الصف الثاني: اختيار الأيام (يظهر فقط إذا كانت الوحدة أسابيع) ---
                  if (unit == 'weeks') ...[
                    SizedBox(height: 20.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'في هذه الأيام:',
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
                          'ح',
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.monday,
                          'ن',
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.tuesday,
                          'ث',
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.wednesday,
                          'ر',
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.thursday,
                          'خ',
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.friday,
                          'ج',
                          selectedDays,
                          setStateDialog,
                        ),
                        _buildDayToggle(
                          DateTime.saturday,
                          'س',
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
                    'إلغاء',
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
                    // حفظ الصيغة المنظمة
                    final daysStr = selectedDays.join(',');
                    final customMode = 'custom:$count:$unit:$daysStr';

                    // تحديث الواجهة الرئيسية
                    setState(() => _selectedRepeatMode = customMode);
                    Navigator.pop(context); // إغلاق الديالوج
                    Navigator.pop(
                      context,
                    ); // إغلاق نافذة خيارات التكرار الأساسية
                  },
                  child: Text(
                    'حفظ',
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

  // دالة مساعدة لرسم دوائر الأيام
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
