import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/backup_service.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/challenges/presentation/cubit/challenge_cubit/challenge_cubit.dart';
import 'package:s/features/my_app/my_app.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool isLoading = false;

  void _setLoading(bool value) {
    setState(() {
      isLoading = value;
    });
  }

  void _showToast(String msg, {bool isError = false}) {
    GlobalVariable.showMessage(msg, isError: isError);
  }

  Future<void> handleBackup() async {
    try {
      _setLoading(true);

      await BackupService.shareBackup();

      _showToast(AppTexts.backupSaveSuccess);
    } catch (e) {
      _showToast(AppTexts.backupSaveFailed, isError: true);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> handleRestore() async {
    try {
      _setLoading(true);

      await BackupService.restoreFromJson();
      if (!mounted) return;
      await _refreshAllCubits();
      _showToast(AppTexts.restoreBackupSuccess);
    } catch (e) {
      if (!mounted) return;
      _showToast(AppTexts.restoreBackupFailed, isError: true);
    } finally {
      if (mounted) {
        _setLoading(false);
      }
    }
  }

  Future<void> _refreshAllCubits() async {
    await context.read<TasksCubit>().loadTasks();
    await context.read<ListsCubit>().loadLists();
    await context.read<ChallengeCubit>().loadChallenges();
    await context.read<WallpaperCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTexts.backupAndRestore,
          style: AppTextStyle.style20W600.copyWith(),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: isLoading
          ? ColoredBox(
              color: Colors.black.withAlpha(77),
              child: const Center(child: LoadingWidget()),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    24.verticalSpace,

                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(20),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.red.withAlpha(77),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: Text(
                              AppTexts.restoreWarning,
                              style: AppTextStyle.style12W300,
                            ),
                          ),
                        ],
                      ),
                    ),

                    16.verticalSpace,

                    _Section(
                      icon: Icons.backup,
                      title: AppTexts.exportBackup,
                      description: AppTexts.shareBackupDescription,
                      color: Colors.green,
                    ),
                    16.verticalSpace,

                    CustomPrimaryButton(
                      width: double.infinity,
                      onPressed: () => isLoading ? null : handleBackup(),
                      text: AppTexts.shareBackup,
                    ),
                    8.verticalSpace,

                    8.verticalSpace,
                    const Divider(color: AppColors.secondaryColor),

                    8.verticalSpace,
                    _Section(
                      icon: Icons.restore,
                      title: AppTexts.restoreFromBackup,
                      description: AppTexts.importFileDescription,
                      color: Colors.orange,
                    ),
                    16.verticalSpace,
                    CustomPrimaryButton(
                      width: double.infinity,
                      onPressed: () => isLoading ? null : handleRestore(),
                      text: AppTexts.importFile,
                    ),

                    55.verticalSpace,
                  ],
                ),
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: color.withAlpha(50),
          child: Icon(icon, color: color),
        ),
        10.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.style16Bold,
              ),
              4.verticalSpace,
              Text(
                description,
                style: AppTextStyle.style12W300.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
