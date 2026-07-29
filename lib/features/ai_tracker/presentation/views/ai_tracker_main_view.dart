// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/features/ai_tracker/domain/entities/ai_tracker_entities.dart';
import 'package:s/features/ai_tracker/presentation/cubit/ai_tracker_cubit.dart';
import 'package:s/features/ai_tracker/presentation/views/widgets/quota_control_card.dart';

class AiTrackerMainView extends StatefulWidget {
  const AiTrackerMainView({super.key});

  @override
  State<AiTrackerMainView> createState() => _AiTrackerMainViewState();
}

class _AiTrackerMainViewState extends State<AiTrackerMainView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'إدارة حسابات الـ AI',
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
          bottom: TabBar(
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorColor: AppColors.successColor,
            unselectedLabelColor: AppColors.buttonColor,
            labelColor: AppColors.successColor,
            labelStyle: AppTextStyle.style14W600.copyWith(
              fontFamily: AppFonts.ar,
            ),
            controller: _tabController,
            tabs: const [
              Tab(text: 'الإيميلات', icon: Icon(Icons.email)),
              Tab(text: 'المنصات', icon: Icon(Icons.memory)),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            EmailsTabView(cubit: context.read<AiTrackerCubit>()),
            PlatformsTabView(cubit: context.read<AiTrackerCubit>()),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton.extended(
                onPressed: () async {
                  await context.pushNamed(AppRoutes.addEmailView);

                  if (context.mounted) {
                    context.read<AiTrackerCubit>().loadTrackerData();
                  }
                },
                label: Text(
                  'إضافة إيميل',
                  style: AppTextStyle.style14W500.copyWith(
                    fontFamily: AppFonts.ar,
                  ),
                ),
                icon: const Icon(Icons.add),
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              )
            : FloatingActionButton.extended(
                onPressed: () async {
                  await context.pushNamed(AppRoutes.addPlatformView);

                  if (context.mounted) {
                    context.read<AiTrackerCubit>().loadTrackerData();
                  }
                },
                label: Text(
                  'إضافة منصة',
                  style: AppTextStyle.style14W500.copyWith(
                    fontFamily: AppFonts.ar,
                  ),
                ),
                icon: const Icon(Icons.add),
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
              ),
      ),
    );
  }
}

class EmailsTabView extends StatelessWidget {
  const EmailsTabView({required this.cubit, super.key});
  final AiTrackerCubit cubit;
  void _showEditEmailDialog(
    BuildContext context,
    EmailAccountEntity email,
    List<String> existingEmails,
    List<AiPlatformEntity> availablePlatforms,
  ) {
    var selectedOrEnteredValue = email.emailAddress;

    final selectedPlatforms = email.quotas.map((q) => q.platformId).toList();

    showDialog<void>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(
                'تعديل الإيميل والمنصات',
                style: AppTextStyle.style20W600.copyWith(
                  fontFamily: AppFonts.ar,
                  color: AppColors.primaryColor,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: email.emailAddress),
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return existingEmails.where(
                          (option) =>
                              option.toLowerCase().contains(
                                textEditingValue.text.toLowerCase(),
                              ) &&
                              option != email.emailAddress,
                        );
                      },
                      onSelected: (selection) =>
                          selectedOrEnteredValue = selection,
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            controller.addListener(
                              () => selectedOrEnteredValue = controller.text,
                            );
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني الجديد أو الحالي',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            );
                          },
                    ),
                    16.verticalSpace,
                    Text(
                      'المنصات المرتبطة:',
                      style: AppTextStyle.style16W600.copyWith(
                        fontFamily: AppFonts.ar,
                      ),
                    ),
                    8.verticalSpace,
                    SizedBox(
                      height: 300.h,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availablePlatforms.length,
                        itemBuilder: (context, index) {
                          final platform = availablePlatforms[index];
                          final isSelected = selectedPlatforms.contains(
                            platform.id,
                          );
                          return CheckboxListTile(
                            title: Text(
                              platform.name,
                              style: AppTextStyle.style14W500,
                            ),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedPlatforms.add(platform.id);
                                } else {
                                  selectedPlatforms.remove(platform.id);
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
                          cubit.editEmail(
                            email.id,
                            selectedOrEnteredValue.trim(),
                            selectedPlatforms,
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

  void _confirmDeleteEmail(BuildContext context, String emailId) {
    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'حذف الإيميل',
            style: AppTextStyle.style20W900.copyWith(
              fontFamily: AppFonts.ar,
              color: AppColors.thirdColor,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذا الإيميل بجميع منصاته؟',
            style: AppTextStyle.style16W600.copyWith(
              fontFamily: AppFonts.ar,
            ),
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
                context.read<AiTrackerCubit>().deleteEmail(emailId);
                Navigator.pop(context);
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
          final platformEmails = state.emails;

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

          final allEmailsList = platformEmails
              .map((e) => e.emailAddress)
              .toList();

          return ListView.builder(
            itemCount: state.emails.length,
            itemBuilder: (context, index) {
              final email = state.emails[index];
              final children = email.quotas
                  .map((quota) {
                    final platform = state.availablePlatforms.firstWhere(
                      (p) => p.id == quota.platformId,
                    );

                    return QuotaControlCard(
                      title: platform.name,
                      emailId: email.id,
                      quota: quota,
                    );
                  })
                  .expand(
                    (widget) => [
                      widget,
                      const Divider(height: 1),
                    ],
                  )
                  .toList();

              if (children.isNotEmpty) {
                children.removeLast();
              }

              return Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: Container(
                  margin: EdgeInsets.only(
                    right: 24.w,
                    left: 24.w,
                    top: 16.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.successColor.withAlpha(60),
                    ),
                  ),
                  child: ExpansionTile(
                    collapsedShape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    title: Text(
                      email.emailAddress,
                      style: AppTextStyle.style14W900.copyWith(
                        fontFamily: AppFonts.ar,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditEmailDialog(
                                context,
                                email,
                                allEmailsList,
                                state.availablePlatforms,
                              );
                            } else if (value == 'delete') {
                              _confirmDeleteEmail(context, email.id);
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
                        const Icon(Icons.expand_more),
                      ],
                    ),
                    children: children,
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}

class PlatformsTabView extends StatelessWidget {
  const PlatformsTabView({required this.cubit, super.key});
  final AiTrackerCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AiTrackerCubit, AiTrackerState>(
      builder: (context, state) {
        if (state is AiTrackerLoaded) {
          if (state.availablePlatforms.isEmpty) {
            return Center(
              child: Text(
                'لا توجد منصات مسجلة',
                style: AppTextStyle.style14W500.copyWith(
                  fontFamily: AppFonts.ar,
                  color: AppColors.thirdColor,
                ),
              ),
            );
          }

          // final allPlatformsList = state.availablePlatforms
          //     .map((p) => p.name)
          //     .toList();

          return ListView.builder(
            itemCount: state.availablePlatforms.length,
            itemBuilder: (context, index) {
              final platform = state.availablePlatforms[index];

              final children = state.emails
                  .where(
                    (email) =>
                        email.quotas.any((q) => q.platformId == platform.id),
                  )
                  .map((email) {
                    final quota = email.quotas.firstWhere(
                      (q) => q.platformId == platform.id,
                    );

                    return InkWell(
                      onTap: () {
                        context.pushNamed(
                          AppRoutes.platformDetailsView,
                          extra: platform,
                        );
                      },
                      child: QuotaControlCard(
                        title: email.emailAddress,
                        emailId: email.id,
                        quota: quota,
                      ),
                    );
                  })
                  .expand(
                    (widget) => [
                      widget,
                      const Divider(height: 1),
                    ],
                  )
                  .toList();

              if (children.isNotEmpty) {
                children.removeLast();
              }

              return Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.platformDetailsView,
                      extra: platform,
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 24.w,
                      left: 24.w,
                      top: 16.h,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 20.w,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColors.successColor.withAlpha(60),
                      ),
                    ),
                    child:
                        //  ExpansionTile(
                        //   collapsedShape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(16.r),
                        //   ),
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(16.r),
                        //   ),
                        //   title:
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.smart_toy,
                                    size: 24.r,
                                    color: AppColors.primaryColor,
                                  ),
                                  8.horizontalSpace,
                                  Expanded(
                                    child: Text(
                                      platform.name,
                                      style: AppTextStyle.style14W900.copyWith(
                                        fontFamily: AppFonts.ar,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (children.isNotEmpty)
                              Text(
                                children.length.toString(),
                                style: AppTextStyle.style12Bold.copyWith(
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                          ],
                        ),
                    // trailing: Row(
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
                    // children: children.isEmpty
                    //     ? [
                    //         Padding(
                    //           padding: EdgeInsets.all(16.r),
                    //           child: Text(
                    //             'لا توجد إيميلات مرتبطة بهذه المنصة',
                    //             style: AppTextStyle.style14W500.copyWith(
                    //               fontFamily: AppFonts.ar,
                    //               color: AppColors.thirdColor,
                    //             ),
                    //           ),
                    //         ),
                    //       ]
                    //     : children,
                    // ),
                  ),
                ),
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
