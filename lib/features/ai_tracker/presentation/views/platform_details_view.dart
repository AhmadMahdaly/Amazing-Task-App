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
