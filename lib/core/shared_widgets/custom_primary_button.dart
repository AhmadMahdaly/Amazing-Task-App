import 'package:flutter/material.dart';

import '../constants.dart';
import '../responsive/responsive_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_style.dart';

class CustomPrimaryButton extends StatelessWidget {
  const CustomPrimaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.width,
  });
  final void Function()? onPressed;
  final String text;
  final double? width;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(AppColors.primaryColor),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: WidgetStateProperty.all(Size(width ?? 300.w, 52.h)),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
          ),
        ),
        child: Text(
          text,
          style: AppTextStyle.style16W700.copyWith(
            color: AppColors.scaffoldBackgroundLightColor,
          ),
        ),
      ),
    );
  }
}
