import 'package:flutter/cupertino.dart';

import '../constants.dart';
import '../responsive/responsive_config.dart';


const double size9 = 9;
const double size12 = 12;
const double size14 = 14;
const double size16 = 16;
const double size18 = 18;
const double size20 = 20;

abstract class AppTextStyle {
  // --- Font Size 9 ---
  static final TextStyle style9W300 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size9.sp, tablet: 11.sp),
    fontWeight: FontWeight.w300,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style9W400 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size9.sp, tablet: 11.sp),
    fontWeight: FontWeight.w400,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style9W500 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size9.sp, tablet: 11.sp),
    fontWeight: FontWeight.w500,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style9W600 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size9.sp, tablet: 11.sp),
    fontWeight: FontWeight.w600,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style9W700 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size9.sp, tablet: 11.sp),
    fontWeight: FontWeight.w700,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style9W800 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size9.sp, tablet: 11.sp),
    fontWeight: FontWeight.w800,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style9W900 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size9.sp, tablet: 11.sp),
    fontWeight: FontWeight.w900,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style9Bold = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size9.sp, tablet: 11.sp),
    fontWeight: FontWeight.bold,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );

  // --- Font Size 12 ---
  static final TextStyle style12W300 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size12.sp, tablet: 14.sp),
    fontWeight: FontWeight.w300,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style12W400 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size12.sp, tablet: 14.sp),
    fontWeight: FontWeight.w400,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style12W500 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size12.sp, tablet: 14.sp),
    fontWeight: FontWeight.w500,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style12W600 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size12.sp, tablet: 14.sp),
    fontWeight: FontWeight.w600,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style12W700 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size12.sp, tablet: 14.sp),
    fontWeight: FontWeight.w700,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style12W800 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size12.sp, tablet: 14.sp),
    fontWeight: FontWeight.w800,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style12W900 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size12.sp, tablet: 14.sp),
    fontWeight: FontWeight.w900,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style12Bold = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size12.sp, tablet: 14.sp),
    fontWeight: FontWeight.bold,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );

  // --- Font Size 14 ---
  static final TextStyle style14W300 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size14.sp, tablet: 16.sp),
    fontWeight: FontWeight.w300,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style14W400 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size14.sp, tablet: 16.sp),
    fontWeight: FontWeight.w400,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style14W500 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size14.sp, tablet: 16.sp),
    fontWeight: FontWeight.w500,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style14W600 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size14.sp, tablet: 16.sp),
    fontWeight: FontWeight.w600,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style14W700 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size14.sp, tablet: 16.sp),
    fontWeight: FontWeight.w700,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style14W800 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size14.sp, tablet: 16.sp),
    fontWeight: FontWeight.w800,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style14W900 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size14.sp, tablet: 16.sp),
    fontWeight: FontWeight.w900,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style14Bold = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size14.sp, tablet: 16.sp),
    fontWeight: FontWeight.bold,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );

  // --- Font Size 16 ---
  static final TextStyle style16W300 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size16.sp, tablet: 18.sp),
    fontWeight: FontWeight.w300,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style16W400 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size16.sp, tablet: 18.sp),
    fontWeight: FontWeight.w400,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style16W500 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size16.sp, tablet: 18.sp),
    fontWeight: FontWeight.w500,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style16W600 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size16.sp, tablet: 18.sp),
    fontWeight: FontWeight.w600,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style16W700 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size16.sp, tablet: 18.sp),
    fontWeight: FontWeight.w700,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style16W800 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size16.sp, tablet: 18.sp),
    fontWeight: FontWeight.w800,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style16W900 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size16.sp, tablet: 18.sp),
    fontWeight: FontWeight.w900,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style16Bold = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size16.sp, tablet: 18.sp),
    fontWeight: FontWeight.bold,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );

  // --- Font Size 18 ---
  static final TextStyle style18W300 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size18.sp, tablet: 20.sp),
    fontWeight: FontWeight.w300,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style18W400 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size18.sp, tablet: 20.sp),
    fontWeight: FontWeight.w400,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style18W500 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size18.sp, tablet: 20.sp),
    fontWeight: FontWeight.w500,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style18W600 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size18.sp, tablet: 20.sp),
    fontWeight: FontWeight.w600,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style18W700 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size18.sp, tablet: 20.sp),
    fontWeight: FontWeight.w700,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style18W800 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size18.sp, tablet: 20.sp),
    fontWeight: FontWeight.w800,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style18W900 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size18.sp, tablet: 20.sp),
    fontWeight: FontWeight.w900,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style18Bold = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size18.sp, tablet: 20.sp),
    fontWeight: FontWeight.bold,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );

  // --- Font Size 20 ---
  static final TextStyle style20W300 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size20.sp, tablet: 22.sp),
    fontWeight: FontWeight.w300,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style20W400 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size20.sp, tablet: 22.sp),
    fontWeight: FontWeight.w400,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style20W500 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size20.sp, tablet: 22.sp),
    fontWeight: FontWeight.w500,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style20W600 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size20.sp, tablet: 22.sp),
    fontWeight: FontWeight.w600,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style20W700 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size20.sp, tablet: 22.sp),
    fontWeight: FontWeight.w700,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style20W800 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size20.sp, tablet: 22.sp),
    fontWeight: FontWeight.w800,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style20W900 = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size20.sp, tablet: 22.sp),
    fontWeight: FontWeight.w900,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
  static final TextStyle style20Bold = TextStyle(
    fontSize: SizeConfig.responsiveValue(phone: size20.sp, tablet: 22.sp),
    fontWeight: FontWeight.bold,
    fontFamily: latinLang ? kPrimaryEnFont : kPrimaryArFont,
  );
}
