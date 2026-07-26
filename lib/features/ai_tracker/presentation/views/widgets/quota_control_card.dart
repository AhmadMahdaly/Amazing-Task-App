import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/ai_tracker/domain/entities/ai_tracker_entities.dart';
import 'package:s/features/ai_tracker/presentation/cubit/ai_tracker_cubit.dart';

class QuotaControlCard extends StatelessWidget {
  const QuotaControlCard({
    required this.title,
    required this.emailId,
    required this.quota,
    super.key,
  });
  final String title;
  final String emailId;
  final PlatformQuotaEntity quota;

  Future<void> _pickCustomTime(BuildContext context) async {
    final initialDateTime = quota.resetTime.isBefore(DateTime.now())
        ? DateTime.now()
        : quota.resetTime;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
    );

    if (pickedDate == null || !context.mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (pickedTime == null || !context.mounted) return;

    final newResetTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    context.read<AiTrackerCubit>().updateResetTime(
      emailId,
      quota.platformId,
      newResetTime,
    );
  }

  String _getRemainingTime(DateTime resetTime) {
    final now = DateTime.now();
    if (now.isAfter(resetTime)) {
      return '✅ متاح للاستخدام';
    }

    final difference = resetTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    if (hours > 0) {
      return '⏳ متبقي: $hours ساعة و $minutes دقيقة';
    }
    return '⏳ متبقي: $minutes دقيقة';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(minutes: 1)),
      builder: (context, snapshot) {
        final isAvailable = DateTime.now().isAfter(quota.resetTime);

        return Container(
          // margin: EdgeInsets.symmetric(),
          padding: EdgeInsets.all(12.r),
          decoration: const BoxDecoration(
            // color: isAvailable
            //     ? Colors.white
            //     : Colors.orange.shade50.withAlpha(100),
            // borderRadius: BorderRadius.circular(16.r),
            // border: Border.all(
            //   color: isAvailable
            //       ? AppColors.successColor.withAlpha(60)
            //       : AppColors.errorColor.withAlpha(60),
            // ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: AppTextStyle.style20W900.copyWith(
                  fontFamily: AppFonts.ar,
                ),
              ),
              8.verticalSpace,
              Text(
                _getRemainingTime(quota.resetTime),
                style: AppTextStyle.style14W900.copyWith(
                  fontFamily: AppFonts.ar,

                  color: isAvailable
                      ? Colors.green.shade700
                      : Colors.orange.shade800,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _pickCustomTime(context),
                    icon: Icon(Icons.edit_calendar, size: 18.r),
                    label: Text(
                      isAvailable
                          ? 'تحديد موعد'
                          : DateFormat('hh:mm a').format(quota.resetTime),
                      style: AppTextStyle.style12W500.copyWith(
                        fontFamily: AppFonts.ar,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () =>
                            context.read<AiTrackerCubit>().adjustTime(
                              emailId,
                              quota.platformId,
                              const Duration(hours: -1),
                            ),
                        icon: const Icon(
                          Icons.remove_circle_outline,
                          color: Colors.red,
                        ),
                        tooltip: 'إنقاص ساعة',
                      ),

                      IconButton(
                        onPressed: () =>
                            context.read<AiTrackerCubit>().adjustTime(
                              emailId,
                              quota.platformId,
                              const Duration(hours: 1),
                            ),
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.blue,
                          size: 28,
                        ),
                        tooltip: 'إضافة ساعة',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
