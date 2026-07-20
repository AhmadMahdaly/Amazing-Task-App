import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:s/core/utils/text_direction_utils.dart';

import '../constants.dart';
import '../resources/app_colors.dart';
import '../resources/app_text_style.dart';
import '../responsive/responsive_config.dart';

class CustomPrimaryTextfield extends StatelessWidget {
  const CustomPrimaryTextfield({
    this.hintStyle,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.controller,
    this.focusNode,
    super.key,
    this.isPassword,
    this.suffix,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.prefix,
    this.textAlign,
    this.text,
    this.style,
    this.readOnly,
    this.onTap,
    this.onChanged,
    this.autofocus = false,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.maxLines = 1,
  });
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool? isPassword;
  final Widget? suffix;
  final Widget? prefix;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final TextAlign? textAlign;
  final String? text;
  final TextStyle? style;
  final TextStyle? hintStyle;

  final bool? readOnly;
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final bool autofocus;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final int? maxLines;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onEditingComplete;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: TextFormField(
        onEditingComplete: onEditingComplete,
        onFieldSubmitted: onFieldSubmitted,
        textAlign:
            textAlign ??
            textAlignFor(
              controller?.text.isEmpty ?? true
                  ? text ?? ''
                  : controller?.text ?? '',
            ),
        textDirection: textDirectionFor(
          controller?.text.isEmpty ?? true
              ? text ?? ''
              : controller?.text ?? '',
        ),
        maxLines: maxLines,
        enabled: enabled,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        autofocus: autofocus,
        onChanged: onChanged,
        onTap: onTap,
        readOnly: readOnly ?? false,
        style:
            style ??
            AppTextStyle.style14W500.copyWith(color: AppColors.thirdColor),

        validator: validator,
        focusNode: focusNode,
        controller: controller,
        cursorWidth: 0.5,
        cursorColor: AppColors.primaryColor,
        obscureText: isPassword ?? false,
        decoration: InputDecoration(
          hint: Text(
            textAlign: textAlign,
            text ?? '',
            style:
                style ??
                hintStyle ??
                AppTextStyle.style14W500.copyWith(
                  color: AppColors.secondaryColor,
                ),
          ),
          border: customOutlineInputBorder(),
          focusedBorder: customOutlineInputBorder(),
          enabledBorder: customOutlineInputBorder(),
          disabledBorder: customOutlineInputBorder(),
          suffixIcon: suffix,
          prefixIcon: prefix,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 12.w,
            vertical: 10.h,
          ),
          filled: true,
          fillColor: AppColors.white,
        ),

        textInputAction: textInputAction,
        autofillHints: autofillHints,
      ),
    );
  }
}

OutlineInputBorder customOutlineInputBorder() {
  return OutlineInputBorder(
    gapPadding: 0,
    borderRadius: BorderRadius.circular(radius),
    borderSide: const BorderSide(
      width: 0.50,
      strokeAlign: BorderSide.strokeAlignOutside,
      color: AppColors.secondaryColor,
    ),
  );
}
