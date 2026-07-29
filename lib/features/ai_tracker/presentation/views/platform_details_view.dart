import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/ai_tracker/domain/entities/ai_tracker_entities.dart';
import 'package:s/features/ai_tracker/presentation/cubit/ai_tracker_cubit.dart';
import 'package:s/features/ai_tracker/presentation/views/widgets/quota_control_card.dart';

class PlatformDetailsView extends StatelessWidget {
  const PlatformDetailsView({required this.platform, super.key});
  final AiPlatformEntity platform;

  Future<void> _showEditPlatformDialog(
    BuildContext context,
    AiTrackerCubit cubit,
    AiPlatformEntity currentPlatform,
    List<String> existingPlatforms,
    List<EmailAccountEntity> allEmails,
  ) async {
    var selectedOrEnteredValue = currentPlatform.name;

    final selectedEmailIds = allEmails
        .where((e) => e.quotas.any((q) => q.platformId == currentPlatform.id))
        .map((e) => e.id)
        .toList();

    await showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(
                'تعديل المنصة والإيميلات',
                style: AppTextStyle.style20W600.copyWith(
                  fontFamily: AppFonts.ar,
                  color: AppColors.primaryColor,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Autocomplete<String>(
                      initialValue: TextEditingValue(
                        text: currentPlatform.name,
                      ),
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return existingPlatforms.where((option) {
                          return option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ) &&
                              option != currentPlatform.name;
                        });
                      },
                      onSelected: (selection) {
                        selectedOrEnteredValue = selection;
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            controller.addListener(() {
                              selectedOrEnteredValue = controller.text;
                            });
                            return CustomPrimaryTextfield(
                              controller: controller,
                              focusNode: focusNode,
                              text: 'اسم المنصة الجديد أو الحالي',
                            );
                          },
                    ),
                    16.verticalSpace,
                    Text(
                      'الإيميلات المرتبطة:',
                      style: AppTextStyle.style16W600.copyWith(
                        fontFamily: AppFonts.ar,
                      ),
                    ),
                    8.verticalSpace,
                    SizedBox(
                      height: 300.h,
                      child: allEmails.isEmpty
                          ? Text(
                              'لا توجد إيميلات مسجلة',
                              style: AppTextStyle.style14W500.copyWith(
                                color: Colors.grey,
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: allEmails.length,
                              itemBuilder: (context, index) {
                                final email = allEmails[index];
                                final isSelected = selectedEmailIds.contains(
                                  email.id,
                                );
                                return CheckboxListTile(
                                  title: Text(
                                    email.emailAddress,
                                    style: AppTextStyle.style14W500,
                                  ),
                                  value: isSelected,
                                  activeColor: AppColors.primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedEmailIds.add(email.id);
                                      } else {
                                        selectedEmailIds.remove(email.id);
                                      }
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    CustomPrimaryButton(
                      width: 100.w,
                      onPressed: () {
                        if (selectedOrEnteredValue.trim().isNotEmpty) {
                          cubit.editPlatform(
                            currentPlatform.id,
                            selectedOrEnteredValue.trim(),
                            selectedEmailIds,
                          );
                          Navigator.pop(context);
                        }
                      },
                      text: 'حفظ',
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'إلغاء',
                        style: AppTextStyle.style14W500.copyWith(
                          fontFamily: AppFonts.ar,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDeletePlatform(
    BuildContext context,
    AiTrackerCubit cubit,
    String platformId,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'حذف المنصة',
            style: AppTextStyle.style20W900.copyWith(
              fontFamily: AppFonts.ar,
              color: AppColors.thirdColor,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذه المنصة من جميع الإيميلات؟',
            style: AppTextStyle.style16W600.copyWith(fontFamily: AppFonts.ar),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: AppTextStyle.style14W500.copyWith(
                  fontFamily: AppFonts.ar,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                cubit.deletePlatform(platformId);
                Navigator.pop(context); // إغلاق المربع الحواري
                context.pop(); // الرجوع للصفحة السابقة
              },
              child: Text(
                'حذف',
                style: AppTextStyle.style14W500.copyWith(
                  fontFamily: AppFonts.ar,
                  color: AppColors.errorColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiTrackerCubit, AiTrackerState>(
      builder: (context, state) {
        if (state is AiTrackerLoaded) {
          // جلب المنصة الحالية من الـ State لكي يتم تحديث الاسم فوراً في حال تم تعديله
          final currentPlatform = state.availablePlatforms.firstWhere(
            (p) => p.id == platform.id,
            orElse: () => platform,
          );

          final platformEmails = state.emails
              .where(
                (email) =>
                    email.quotas.any((q) => q.platformId == currentPlatform.id),
              )
              .toList();

          return Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'إيميلات منصة ${currentPlatform.name}',
                  style: AppTextStyle.style20W900.copyWith(
                    fontFamily: AppFonts.ar,
                  ),
                ),
                backgroundColor: AppColors.primaryColor,
                elevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        final allPlatformsList = state.availablePlatforms
                            .map((p) => p.name)
                            .toList();
                        await _showEditPlatformDialog(
                          context,
                          context.read<AiTrackerCubit>(),
                          currentPlatform,
                          allPlatformsList,
                          state.emails,
                        );
                      } else if (value == 'delete') {
                        await _confirmDeletePlatform(
                          context,
                          context.read<AiTrackerCubit>(),
                          currentPlatform.id,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, color: Colors.blue),
                            8.horizontalSpace,
                            Text(
                              'تعديل / دمج',
                              style: AppTextStyle.style14W500.copyWith(
                                fontFamily: AppFonts.ar,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            8.horizontalSpace,
                            Text(
                              'حذف',
                              style: AppTextStyle.style14W500.copyWith(
                                fontFamily: AppFonts.ar,
                                color: AppColors.errorColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              body: platformEmails.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد إيميلات مسجلة في هذه المنصة',
                        style: AppTextStyle.style14W500.copyWith(
                          fontFamily: AppFonts.ar,
                          color: AppColors.thirdColor,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: platformEmails.length,
                      itemBuilder: (context, index) {
                        final email = platformEmails[index];
                        final quota = email.quotas.firstWhere(
                          (q) => q.platformId == currentPlatform.id,
                        );

                        return QuotaControlCard(
                          title: email.emailAddress,
                          emailId: email.id,
                          quota: quota,
                        );
                      },
                    ),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: LoadingWidget()),
        );
      },
    );
  }
}
