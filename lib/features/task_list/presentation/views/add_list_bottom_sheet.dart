import 'package:flutter/material.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

class AddListBottomSheet extends StatefulWidget {
  const AddListBottomSheet({super.key});

  @override
  State<AddListBottomSheet> createState() => _AddListBottomSheetState();
}

class _AddListBottomSheetState extends State<AddListBottomSheet> {
  final TextEditingController _listController = TextEditingController();

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: bottomInset > 0 ? bottomInset + 20.h : 20.h,
        top: 24.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        color: AppColors.scaffoldBackgroundLightColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppTexts.newList,
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
          SizedBox(height: 16.h),

          TextField(
            controller: _listController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: AppTexts.enterListName,
              hintStyle: AppTextStyle.style9W300.copyWith(
                fontSize: 14.sp,
                color: AppColors.secondaryColor,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.secondaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: const BorderSide(color: AppColors.primaryColor),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
            ),
            style: AppTextStyle.style9W300.copyWith(
              fontSize: 16.sp,
              color: AppColors.forthColor,
            ),
          ),

          SizedBox(height: 24.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  AppTexts.cancel,
                  style: AppTextStyle.style9W300.copyWith(
                    fontSize: 14.sp,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  minimumSize: Size(90.w, 40.h),
                  elevation: 0,
                ),
                onPressed: () {
                  final title = _listController.text.trim();
                  if (title.isEmpty) return;

                  Navigator.pop(context);
                },
                child: Text(
                  AppTexts.createList,
                  style: AppTextStyle.style9W300.copyWith(
                    fontSize: 14.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
