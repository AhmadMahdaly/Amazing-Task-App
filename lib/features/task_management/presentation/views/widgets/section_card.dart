// ignore_for_file: deprecated_member_use, discarded_futures, parameter_assignments

import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/responsive/responsive_config.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.forthColor.withAlpha(15),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
