import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_dropdown_button.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/features/task_management/domain/utils/repeat_format_utils.dart';

Future<String?> showCustomRepeatDialog(
  BuildContext context, {
  String? initialMode,
}) {
  final parsed = parseCustomRepeatMode(initialMode);
  var count = parsed?.count ?? 1;
  var unit = parsed?.unit ?? 'weeks';
  final selectedDays = <int>[
    ...(parsed?.weekdays ?? [DateTime.now().weekday]),
  ];
  var selectedMonthDay = parsed?.monthDay ?? DateTime.now().day;
  var selectedYearMonth = parsed?.yearMonth ?? DateTime.now().month;
  var selectedYearDay = parsed?.yearDay ?? DateTime.now().day;

  return showDialog<String>(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              AppTexts.customRepeat,
              style: AppTextStyle.style18W300.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        AppTexts.repeatEvery,
                        style: AppTextStyle.style12W300,
                      ),
                      10.horizontalSpace,
                      SizedBox(
                        width: 50.w,
                        child: CustomPrimaryTextfield(
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.style12W300,
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
                      10.horizontalSpace,
                      Expanded(
                        child: CustomDropdownButtonFormField<String>(
                          value: unit,
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
                          onChanged: (val) => setStateDialog(() => unit = val!),
                        ),
                      ),
                    ],
                  ),

                  if (unit == 'weeks') ...[
                    20.verticalSpace,
                    Text(
                      AppTexts.inTheseDays,
                      style: AppTextStyle.style12W300,
                      textAlign: TextAlign.start,
                    ),
                    12.verticalSpace,
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 8.h,
                      alignment: WrapAlignment.center,
                      children: [
                        _DayToggle(
                          dayValue: DateTime.sunday,
                          label: AppTexts.sunday.substring(0, 3),
                          selectedDays: selectedDays,
                          onChanged: setStateDialog,
                        ),
                        _DayToggle(
                          dayValue: DateTime.monday,
                          label: AppTexts.monday.substring(0, 3),
                          selectedDays: selectedDays,
                          onChanged: setStateDialog,
                        ),
                        _DayToggle(
                          dayValue: DateTime.tuesday,
                          label: AppTexts.tuesday.substring(0, 3),
                          selectedDays: selectedDays,
                          onChanged: setStateDialog,
                        ),
                        _DayToggle(
                          dayValue: DateTime.wednesday,
                          label: AppTexts.wednesday.substring(0, 3),
                          selectedDays: selectedDays,
                          onChanged: setStateDialog,
                        ),
                        _DayToggle(
                          dayValue: DateTime.thursday,
                          label: AppTexts.thursday.substring(0, 3),
                          selectedDays: selectedDays,
                          onChanged: setStateDialog,
                        ),
                        _DayToggle(
                          dayValue: DateTime.friday,
                          label: AppTexts.friday.substring(0, 3),
                          selectedDays: selectedDays,
                          onChanged: setStateDialog,
                        ),
                        _DayToggle(
                          dayValue: DateTime.saturday,
                          label: AppTexts.saturday.substring(0, 3),
                          selectedDays: selectedDays,
                          onChanged: setStateDialog,
                        ),
                      ],
                    ),
                  ],

                  if (unit == 'months') ...[
                    20.verticalSpace,
                    Text(
                      AppTexts.dayOfMonth,
                      style: AppTextStyle.style12W300,
                      textAlign: TextAlign.start,
                    ),
                    8.verticalSpace,
                    Row(
                      children: [
                        Expanded(
                          child: CustomPrimaryTextfield(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            controller:
                                TextEditingController(
                                    text: selectedMonthDay.toString(),
                                  )
                                  ..selection = TextSelection.collapsed(
                                    offset: selectedMonthDay.toString().length,
                                  ),
                            onChanged: (val) {
                              final d = int.tryParse(val);
                              if (d != null && d >= 1 && d <= 31) {
                                selectedMonthDay = d;
                              }
                            },
                          ),
                        ),
                        10.horizontalSpace,
                        IconButton(
                          icon: const Icon(
                            Icons.calendar_month,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(
                                now.year,
                                now.month,
                                selectedMonthDay,
                              ),
                              firstDate: DateTime(now.year, now.month, 1),
                              lastDate: DateTime(
                                now.year,
                                now.month + 1,
                                0,
                              ),
                            );
                            if (picked != null) {
                              setStateDialog(
                                () => selectedMonthDay = picked.day,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],

                  if (unit == 'years') ...[
                    20.verticalSpace,
                    Text(
                      AppTexts.yearlyRepeatDate,
                      style: AppTextStyle.style12W300,
                      textAlign: TextAlign.start,
                    ),
                    8.verticalSpace,
                    InkWell(
                      onTap: () async {
                        final now = DateTime.now();
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime(
                            now.year,
                            selectedYearMonth,
                            selectedYearDay,
                          ),
                          firstDate: DateTime(now.year, 1, 1),
                          lastDate: DateTime(now.year, 12, 31),
                        );
                        if (picked != null) {
                          setStateDialog(() {
                            selectedYearMonth = picked.month;
                            selectedYearDay = picked.day;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.secondaryColor.withAlpha(77),
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$selectedYearDay / $selectedYearMonth',
                              style: AppTextStyle.style12W300,
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  AppTexts.cancel,
                  style: AppTextStyle.style12W300.copyWith(
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                ),
                onPressed: () {
                  final customMode = buildCustomRepeatMode(
                    count: count,
                    unit: unit,
                    weekdays: unit == 'weeks' ? selectedDays : const [],
                    monthDay: selectedMonthDay.clamp(1, 31),
                    yearMonth: selectedYearMonth,
                    yearDay: selectedYearDay,
                  );
                  Navigator.pop(dialogContext, customMode);
                },
                child: Text(
                  AppTexts.save,
                  style: AppTextStyle.style12W300.copyWith(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _DayToggle extends StatelessWidget {
  const _DayToggle({
    required this.dayValue,
    required this.label,
    required this.selectedDays,
    required this.onChanged,
  });

  final int dayValue;
  final String label;
  final List<int> selectedDays;
  final StateSetter onChanged;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedDays.contains(dayValue);
    return InkWell(
      onTap: () {
        onChanged(() {
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
          textAlign: TextAlign.center,
          style: AppTextStyle.style9W300.copyWith(
            color: isSelected ? Colors.white : AppColors.forthColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
