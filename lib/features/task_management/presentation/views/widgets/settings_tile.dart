import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: ListTile(
        // contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.primaryColor),
        title: Text(title, style: AppTextStyle.style12W300),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: AppTextStyle.style12W300.copyWith(
                  color: AppColors.secondaryColor,
                ),
              )
            : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
