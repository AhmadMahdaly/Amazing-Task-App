import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/ai_tracker/domain/entities/ai_tracker_entities.dart';
import 'package:s/features/ai_tracker/presentation/cubit/ai_tracker_cubit.dart';
import 'package:s/features/ai_tracker/presentation/views/widgets/quota_control_card.dart';

class PlatformDetailsView extends StatelessWidget {
  const PlatformDetailsView({required this.platform, super.key});
  final AiPlatformEntity platform;
  // void _showEditPlatformDialog(
  //   BuildContext context,
  //   AiPlatformEntity platform,
  //   List<String> existingPlatforms,
  //   List<EmailAccountEntity> allEmails,
  // ) {
  //   var selectedOrEnteredValue = platform.name;

  //   final selectedEmailIds = allEmails
  //       .where((e) => e.quotas.any((q) => q.platformId == platform.id))
  //       .map((e) => e.id)
  //       .toList();

  //   showDialog<void>(
  //     context: context,
  //     builder: (_) => StatefulBuilder(
  //       builder: (context, setState) {
  //         return Directionality(
  //           textDirection: TextDirection.rtl,
  //           child: AlertDialog(
  //             title: Text(
  //               'تعديل المنصة والإيميلات',
  //               style: AppTextStyle.style20W600.copyWith(
  //                 fontFamily: AppFonts.ar,
  //                 color: AppColors.primaryColor,
  //               ),
  //             ),
  //             content: SizedBox(
  //               width: double.maxFinite,
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Autocomplete<String>(
  //                     initialValue: TextEditingValue(text: platform.name),
  //                     optionsBuilder: (textEditingValue) {
  //                       if (textEditingValue.text.isEmpty) {
  //                         return const Iterable<String>.empty();
  //                       }
  //                       return existingPlatforms.where((option) {
  //                         return option.toLowerCase().contains(
  //                               textEditingValue.text.toLowerCase(),
  //                             ) &&
  //                             option != platform.name;
  //                       });
  //                     },
  //                     onSelected: (selection) {
  //                       selectedOrEnteredValue = selection;
  //                     },
  //                     fieldViewBuilder:
  //                         (context, controller, focusNode, onFieldSubmitted) {
  //                           controller.addListener(() {
  //                             selectedOrEnteredValue = controller.text;
  //                           });
  //                           return TextFormField(
  //                             controller: controller,
  //                             focusNode: focusNode,
  //                             decoration: InputDecoration(
  //                               labelText: 'اسم المنصة الجديد أو الحالي',
  //                               border: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(12.r),
  //                               ),
  //                             ),
  //                           );
  //                         },
  //                   ),
  //                   16.verticalSpace,
  //                   Text(
  //                     'الإيميلات المرتبطة:',
  //                     style: AppTextStyle.style16W600.copyWith(
  //                       fontFamily: AppFonts.ar,
  //                     ),
  //                   ),
  //                   8.verticalSpace,

  //                   SizedBox(
  //                     height: 300.h,
  //                     child: allEmails.isEmpty
  //                         ? Text(
  //                             'لا توجد إيميلات مسجلة',
  //                             style: AppTextStyle.style14W500.copyWith(
  //                               color: Colors.grey,
  //                             ),
  //                           )
  //                         : ListView.builder(
  //                             shrinkWrap: true,
  //                             itemCount: allEmails.length,
  //                             itemBuilder: (context, index) {
  //                               final email = allEmails[index];
  //                               final isSelected = selectedEmailIds.contains(
  //                                 email.id,
  //                               );
  //                               return CheckboxListTile(
  //                                 title: Text(
  //                                   email.emailAddress,
  //                                   style: AppTextStyle.style14W500,
  //                                 ),
  //                                 value: isSelected,
  //                                 activeColor: AppColors.primaryColor,
  //                                 onChanged: (value) {
  //                                   setState(() {
  //                                     if (value == true) {
  //                                       selectedEmailIds.add(email.id);
  //                                     } else {
  //                                       selectedEmailIds.remove(email.id);
  //                                     }
  //                                   });
  //                                 },
  //                               );
  //                             },
  //                           ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               Row(
  //                 children: [
  //                   CustomPrimaryButton(
  //                     width: 100.w,
  //                     onPressed: () {
  //                       if (selectedOrEnteredValue.trim().isNotEmpty) {
  //                         context.read<AiTrackerCubit>().editPlatform(
  //                           platform.id,
  //                           selectedOrEnteredValue.trim(),
  //                           selectedEmailIds,
  //                         );
  //                         Navigator.pop(context);
  //                       }
  //                     },
  //                     text: 'حفظ',
  //                   ),
  //                   TextButton(
  //                     onPressed: () => Navigator.pop(context),
  //                     child: Text(
  //                       'إلغاء',
  //                       style: AppTextStyle.style14W500.copyWith(
  //                         fontFamily: AppFonts.ar,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // void _confirmDeletePlatform(BuildContext context, String platformId) {
  //   showDialog<void>(
  //     context: context,
  //     builder: (_) => Directionality(
  //       textDirection: TextDirection.rtl,
  //       child: AlertDialog(
  //         title: Text(
  //           'حذف المنصة',
  //           style: AppTextStyle.style20W900.copyWith(
  //             fontFamily: AppFonts.ar,
  //             color: AppColors.thirdColor,
  //           ),
  //         ),
  //         content: Text(
  //           'هل أنت متأكد من حذف هذه المنصة من جميع الإيميلات؟',
  //           style: AppTextStyle.style16W600.copyWith(fontFamily: AppFonts.ar),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text(
  //               'إلغاء',
  //               style: AppTextStyle.style14W500.copyWith(
  //                 fontFamily: AppFonts.ar,
  //               ),
  //             ),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               context.read<AiTrackerCubit>().deletePlatform(platformId);
  //               Navigator.pop(context);
  //             },
  //             child: Text(
  //               'حذف',
  //               style: AppTextStyle.style14W500.copyWith(
  //                 fontFamily: AppFonts.ar,
  //                 color: AppColors.errorColor,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'إيميلات منصة ${platform.name}',
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
          // actions: [   // trailing: Row(
          //   mainAxisSize: MainAxisSize.min,
          //   children: [
          //     PopupMenuButton<String>(
          //       onSelected: (value) {
          //         if (value == 'edit') {
          //           _showEditPlatformDialog(
          //             context,
          //             platform,
          //             allPlatformsList,
          //             state.emails,
          //           );
          //         } else if (value == 'delete') {
          //           _confirmDeletePlatform(context, platform.id);
          //         }
          //       },
          //       itemBuilder: (context) => [
          //         PopupMenuItem(
          //           value: 'edit',
          //           child: Row(
          //             children: [
          //               const Icon(Icons.edit, color: Colors.blue),
          //               8.horizontalSpace,
          //               Text(
          //                 'تعديل / دمج',
          //                 style: AppTextStyle.style14W500.copyWith(
          //                   fontFamily: AppFonts.ar,
          //                   color: Colors.blue,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //         PopupMenuItem(
          //           value: 'delete',
          //           child: Row(
          //             children: [
          //               const Icon(Icons.delete, color: Colors.red),
          //               8.horizontalSpace,
          //               Text(
          //                 'حذف',
          //                 style: AppTextStyle.style14W500.copyWith(
          //                   fontFamily: AppFonts.ar,
          //                   color: AppColors.errorColor,
          //                 ),
          //               ),
          //             ],
          //           ),
          //         ),
          //       ],
          //     ),
          //     const Icon(Icons.expand_more),
          //   ],
          // ),
          // ],
        ),
        body: BlocBuilder<AiTrackerCubit, AiTrackerState>(
          builder: (context, state) {
            if (state is AiTrackerLoaded) {
              final platformEmails = state.emails
                  .where(
                    (email) =>
                        email.quotas.any((q) => q.platformId == platform.id),
                  )
                  .toList();

              if (platformEmails.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد إيميلات مسجلة في هذه المنصة',
                    style: AppTextStyle.style14W500.copyWith(
                      fontFamily: AppFonts.ar,
                      color: AppColors.thirdColor,
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: platformEmails.length,
                itemBuilder: (context, index) {
                  final email = platformEmails[index];
                  final quota = email.quotas.firstWhere(
                    (q) => q.platformId == platform.id,
                  );

                  return QuotaControlCard(
                    title: email.emailAddress,
                    emailId: email.id,
                    quota: quota,
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
