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
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
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
          children: const [
            EmailsTabView(),
            PlatformsTabView(),
          ],
        ),
        floatingActionButton: _tabController.index == 0
            ? FloatingActionButton.extended(
                onPressed: () async {
                  // 1. ننتظر حتى ينتهي المستخدم من صفحة الإضافة وتُغلق
                  await context.pushNamed(AppRoutes.addEmailView);

                  // 2. 🟢 فور العودة، نجبر الكيوبت الأساسي على تحديث البيانات من الكاش
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
              )
            : FloatingActionButton.extended(
                onPressed: () async {
                  // 1. ننتظر حتى يُغلق المستخدم صفحة إضافة المنصة
                  await context.pushNamed(AppRoutes.addPlatformView);

                  // 2. 🟢 فور العودة، نجبر الكيوبت على قراءة المنصة الجديدة من الكاش
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
                icon: const Icon(Icons.add_box),
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
      ),
    );
  }
}

class EmailsTabView extends StatelessWidget {
  const EmailsTabView({super.key});
  void _showEditEmailDialog(BuildContext context, EmailAccountEntity email) {
    final controller = TextEditingController(text: email.emailAddress);
    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'تعديل الإيميل',
            style: AppTextStyle.style20W600.copyWith(
              fontFamily: AppFonts.ar,
              color: AppColors.primaryColor,
            ),
          ),
          content: CustomPrimaryTextfield(
            controller: controller,
            text: 'البريد الإلكتروني الجديد',
          ),
          actions: [
            Row(
              children: [
                CustomPrimaryButton(
                  width: 100.w,
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      context.read<AiTrackerCubit>().editEmailAddress(
                        email.id,
                        controller.text.trim(),
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
                  // padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    // color: isAvailable
                    //     ? Colors.white
                    //     : Colors.orange.shade50.withAlpha(100),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.successColor.withAlpha(60),
                    ),
                  ),
                  child: ExpansionTile(
                    // leading: const Icon(Icons.email, color: Colors.blue),
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
                              _showEditEmailDialog(context, email);
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
                                    'تعديل',
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
  const PlatformsTabView({super.key});

  void _showEditPlatformDialog(
    BuildContext context,
    AiPlatformEntity platform,
  ) {
    final nameController = TextEditingController(text: platform.name);

    showDialog<void>(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'تعديل المنصة',
            style: AppTextStyle.style20W600.copyWith(
              fontFamily: AppFonts.ar,
              color: AppColors.primaryColor,
            ),
          ),
          content: CustomPrimaryTextfield(
            controller: nameController,
            text: 'اسم المنصة',
          ),
          actions: [
            Row(
              children: [
                CustomPrimaryButton(
                  width: 100.w,
                  onPressed: () {
                    if (nameController.text.trim().isNotEmpty) {
                      context.read<AiTrackerCubit>().editPlatform(
                        platform.id,
                        nameController.text.trim(),
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
      ),
    );
  }

  void _confirmDeletePlatform(BuildContext context, String platformId) {
    showDialog<void>(
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
                context.read<AiTrackerCubit>().deletePlatform(platformId);
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

          return ListView.separated(
            separatorBuilder: (context, index) => 12.verticalSpace,
            padding: EdgeInsets.all(16.r),
            // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            //   crossAxisCount: 2,
            //   crossAxisSpacing: 16,
            //   mainAxisSpacing: 16,
            // ),
            itemCount: state.availablePlatforms.length,
            itemBuilder: (context, index) {
              final platform = state.availablePlatforms[index];
              return InkWell(
                onTap: () {
                  context.pushNamed(
                    AppRoutes.platformDetailsView,
                    extra: platform,
                  );
                },
                child: Container(
                  // margin: EdgeInsets.symmetric(),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    // color: isAvailable
                    //     ? Colors.white
                    //     : Colors.orange.shade50.withAlpha(100),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: AppColors.successColor.withAlpha(60),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      12.horizontalSpace,
                      Icon(Icons.smart_toy, size: 40.r),
                      8.horizontalSpace,
                      Text(
                        platform.name,
                        style: AppTextStyle.style18W900.copyWith(
                          fontFamily: AppFonts.ar,
                        ),
                      ),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          size: 20.r,
                          color: Colors.grey,
                        ),
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditPlatformDialog(context, platform);
                          } else if (value == 'delete') {
                            _confirmDeletePlatform(context, platform.id);
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
                                  'تعديل',
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

                  //
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
