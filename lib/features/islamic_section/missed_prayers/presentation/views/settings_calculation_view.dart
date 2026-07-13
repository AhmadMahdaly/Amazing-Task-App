import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/resources/islamic_text.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/islamic_section/missed_prayers/domain/entities/missed_prayers_entity.dart';
import 'package:s/features/islamic_section/missed_prayers/presentation/cubit/missed_prayers_cubit.dart';

class SettingsCalculationView extends StatefulWidget {
  const SettingsCalculationView({required this.currentData, super.key});
  final MissedPrayersEntity currentData;

  @override
  State<SettingsCalculationView> createState() =>
      _SettingsCalculationViewState();
}

class _SettingsCalculationViewState extends State<SettingsCalculationView> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _birthDate;
  late DateTime _commitmentDate;
  late TextEditingController _doubtController;

  @override
  void initState() {
    super.initState();

    _birthDate = widget.currentData.birthDate;
    _commitmentDate = widget.currentData.commitmentDate;
    _doubtController = TextEditingController(
      text: widget.currentData.doubtMonths.toString(),
    );
  }

  @override
  void dispose() {
    _doubtController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate ? _birthDate : _commitmentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
        } else {
          _commitmentDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            IslamicTexts.editSettings,
            style: AppTextStyle.style16Bold.copyWith(
              fontFamily: kPrimaryArFont,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  10.verticalSpace,

                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      IslamicTexts.editSettingsDescription,
                      style: AppTextStyle.style14W500.copyWith(
                        color: AppColors.secondaryColor,
                        fontFamily: kPrimaryArFont,
                      ),
                    ),
                  ),
                  24.verticalSpace,

                  _buildDateSelectorTile(
                    label: IslamicTexts.birthDate,
                    selectedDate: _birthDate,
                    onTap: () => _selectDate(context, true),
                  ),
                  16.verticalSpace,

                  _buildDateSelectorTile(
                    label: IslamicTexts.commitmentDate,
                    selectedDate: _commitmentDate,
                    onTap: () => _selectDate(context, false),
                  ),
                  16.verticalSpace,

                  TextFormField(
                    controller: _doubtController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyle.style14W500.copyWith(
                      fontFamily: kPrimaryArFont,
                    ),
                    decoration: InputDecoration(
                      labelText: IslamicTexts.doubtPeriodMonths,
                      labelStyle: AppTextStyle.style14W500.copyWith(
                        color: AppColors.secondaryColor,
                        fontFamily: kPrimaryArFont,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(
                          color: AppColors.thirdColor,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: const BorderSide(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return IslamicTexts.requiredField;
                      }

                      final doubtValue = int.tryParse(value);
                      if (doubtValue == null) {
                        return IslamicTexts.invalidNumber;
                      }

                      if (doubtValue < 0) {
                        return IslamicTexts.negativeValueNotAllowed;
                      }

                      if (_birthDate != null && _commitmentDate != null) {
                        const daysIn15HijriYears = 5315;
                        final mandateDate = _birthDate.add(
                          const Duration(days: daysIn15HijriYears),
                        );
                        final totalDaysSinceMandate = _commitmentDate
                            .difference(mandateDate)
                            .inDays;

                        if (totalDaysSinceMandate <= 0) {
                          return IslamicTexts
                              .commitmentDateBeforeAccountabilityAge;
                        }

                        final maxDoubtMonths = totalDaysSinceMandate ~/ 30;

                        if (doubtValue > maxDoubtMonths) {
                          return '${IslamicTexts.doubtPeriodExceedsAbandonmentPeriod} $maxDoubtMonths ${IslamicTexts.month})';
                        }
                      }

                      return null;
                    },
                  ),
                  40.verticalSpace,

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        context
                            .read<MissedPrayersCubit>()
                            .updateCalculationData(
                              newBirthDate: _birthDate,
                              newCommitmentDate: _commitmentDate,
                              newDoubtMonths: int.parse(_doubtController.text),
                            );

                        context.pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              IslamicTexts.settingsUpdatedSuccessfully,
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      IslamicTexts.save,
                      style: AppTextStyle.style16Bold.copyWith(
                        color: AppColors.white,
                        fontFamily: kPrimaryArFont,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelectorTile({
    required String label,
    required DateTime selectedDate,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.thirdColor),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
              style: AppTextStyle.style14W500.copyWith(
                fontFamily: kPrimaryArFont,
              ),
            ),
            Icon(
              Icons.edit_calendar_rounded,
              size: 20.r,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
