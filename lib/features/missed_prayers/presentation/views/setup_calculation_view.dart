import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/missed_prayers/presentation/cubit/missed_prayers_cubit.dart';

class SetupCalculationView extends StatefulWidget {
  const SetupCalculationView({super.key});

  @override
  State<SetupCalculationView> createState() => _SetupCalculationViewState();
}

class _SetupCalculationViewState extends State<SetupCalculationView> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _birthDate;
  DateTime? _commitmentDate;
  final _doubtController = TextEditingController();

  @override
  void dispose() {
    _doubtController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.setupTitle, style: AppTextStyle.style16Bold),
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
              children: [
                10.verticalSpace,

                _buildInfoCard(),

                24.verticalSpace,

                _buildDateSelectorTile(
                  label: AppTexts.birthDate,
                  selectedDate: _birthDate,
                  onTap: () => _selectDate(context, true),
                ),
                16.verticalSpace,

                _buildDateSelectorTile(
                  label: AppTexts.commitmentDate,
                  selectedDate: _commitmentDate,
                  onTap: () => _selectDate(context, false),
                ),
                16.verticalSpace,

                TextFormField(
                  controller: _doubtController,
                  keyboardType: TextInputType.number,
                  style: AppTextStyle.style14W500,
                  decoration: InputDecoration(
                    labelText: AppTexts.doubtPeriodMonths,
                    labelStyle: AppTextStyle.style14W500.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: const BorderSide(color: AppColors.thirdColor),
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
                      return AppTexts.requiredField;
                    }
                    if (int.tryParse(value) == null) {
                      return AppTexts.invalidNumber;
                    }
                    return null;
                  },
                ),
                40.verticalSpace,

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_birthDate == null || _commitmentDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppTexts.pleaseSelectDates)),
                        );
                        return;
                      }

                      context
                          .read<MissedPrayersCubit>()
                          .calculateAndSaveInitialData(
                            birthDate: _birthDate!,
                            commitmentDate: _commitmentDate!,
                            doubtMonths: int.parse(_doubtController.text),
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
                    AppTexts.calculateAndStart,
                    style: AppTextStyle.style16Bold.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withAlpha(15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryColor.withAlpha(77)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.primaryColor,
                size: 24.sp,
              ),
              8.horizontalSpace,
              Text(
                AppTexts.setupMissedPrayersTitle,
                style: AppTextStyle.style16Bold.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Text(
            AppTexts.setupMissedPrayersSubject,
            style: AppTextStyle.style14W500.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectorTile({
    required String label,
    required DateTime? selectedDate,
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
              selectedDate == null
                  ? label
                  : '${selectedDate.year}-${selectedDate.month}-${selectedDate.day}',
              style: selectedDate == null
                  ? AppTextStyle.style14W500.copyWith(
                      color: AppColors.secondaryColor,
                    )
                  : AppTextStyle.style14W500,
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 20.r,
              color: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}
