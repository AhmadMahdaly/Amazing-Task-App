import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/islamic_section/friday_sunan/domain/entities/sunnah_entity.dart';

class SunnahCard extends StatelessWidget {
  const SunnahCard({
    required this.fontSize,
    required this.sunnah,
    super.key,
  });
  final SunnahEntity sunnah;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.buttonColor.withAlpha(20),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryColor.withAlpha(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32.r,
                height: 32.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor,
                ),
                child: Center(
                  child: Text(
                    '${sunnah.id}',
                    style: AppTextStyle.style14W500.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              12.horizontalSpace,

              Expanded(
                child: Text(
                  sunnah.title,
                  style: AppTextStyle.style18W900.copyWith(
                    fontFamily: AppFonts.amiri,
                    color: AppColors.primaryColor,
                    fontSize: (fontSize + 2).sp,
                  ),
                ),
              ),
            ],
          ),
          12.verticalSpace,

          Text(
            sunnah.description,
            textAlign: TextAlign.justify,
            style: AppTextStyle.style16W700.copyWith(
              fontFamily: AppFonts.amiri,
              height: 1.9,
              fontSize: fontSize.sp,
              color: AppColors.primaryColor,
            ),
          ),
          12.verticalSpace,

          if (sunnah.source != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.menu_book,
                  size: 18.r,
                  color: AppColors.primaryColor,
                ),
                8.horizontalSpace,
                Expanded(
                  child: Text(
                    sunnah.source!,
                    textAlign: TextAlign.justify,
                    style: AppTextStyle.style12W900.copyWith(
                      fontFamily: AppFonts.amiri,
                      height: 1.9,
                      fontSize: (fontSize - 2).sp,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
