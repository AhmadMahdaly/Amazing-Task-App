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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      AppTexts.repeatEvery,
                      style: AppTextStyle.style12W300,
                    ),
                    SizedBox(width: 10.w),
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
                    SizedBox(width: 10.w),
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
                        onChanged: (val) {
                          setStateDialog(() => unit = val!);
                        },
                      ),
                    ),
                  ],
                ),
                if (unit == 'weeks') ...[
                  SizedBox(height: 20.h),
                  Text(
                    AppTexts.inTheseDays,
                    style: AppTextStyle.style12W300,
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    alignment: WrapAlignment.center,
                    children: [
                      _DayToggle(
                        dayValue: DateTime.sunday,
                        label: AppTexts.sunday,
                        selectedDays: selectedDays,
                        onChanged: setStateDialog,
                      ),
                      _DayToggle(
                        dayValue: DateTime.monday,
                        label: AppTexts.monday,
                        selectedDays: selectedDays,
                        onChanged: setStateDialog,
                      ),
                      _DayToggle(
                        dayValue: DateTime.tuesday,
                        label: AppTexts.tuesday,
                        selectedDays: selectedDays,
                        onChanged: setStateDialog,
                      ),
                      _DayToggle(
                        dayValue: DateTime.wednesday,
                        label: AppTexts.wednesday,
                        selectedDays: selectedDays,
                        onChanged: setStateDialog,
                      ),
                      _DayToggle(
                        dayValue: DateTime.thursday,
                        label: AppTexts.thursday,
                        selectedDays: selectedDays,
                        onChanged: setStateDialog,
                      ),
                      _DayToggle(
                        dayValue: DateTime.friday,
                        label: AppTexts.friday,
                        selectedDays: selectedDays,
                        onChanged: setStateDialog,
                      ),
                      _DayToggle(
                        dayValue: DateTime.saturday,
                        label: AppTexts.saturday,
                        selectedDays: selectedDays,
                        onChanged: setStateDialog,
                      ),
                    ],
                  ),
                ],
              ],
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
                  );
                  Navigator.pop(dialogContext, customMode);
                },
                child: Text(
                  AppTexts.save,
                  style: AppTextStyle.style12W300.copyWith(
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
