import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

class EmptyAnalyticsState extends StatelessWidget {
  const EmptyAnalyticsState({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        toolbarHeight: 50.h,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.analytics_rounded,
            color: AppColors.primaryColor,
            size: 50.r,
          ),
          8.verticalSpace,
          Text(
            AppTexts.notEnoughDataForAnalysis,
            style: AppTextStyle.style12Bold,
            textAlign: TextAlign.center,
          ),
          20.verticalSpace,
        ],
      ),
    );
  }
}
