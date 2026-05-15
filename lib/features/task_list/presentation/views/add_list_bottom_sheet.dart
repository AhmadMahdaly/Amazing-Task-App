import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/task_list/domain/entities/task_list_entity.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';

class AddListBottomSheet extends StatefulWidget {
  const AddListBottomSheet({super.key});

  @override
  State<AddListBottomSheet> createState() => _AddListBottomSheetState();
}

class _AddListBottomSheetState extends State<AddListBottomSheet> {
  final TextEditingController _listController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _createList() async {
    final title = _listController.text.trim();
    if (title.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final listsCubit = context.read<ListsCubit>();

      final success = await listsCubit.addList(
        TaskListEntity(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
        ),
      );

      if (!mounted) return;

      if (success) {
        Navigator.pop(context);
        return;
      }

      final stateAfterSave = listsCubit.state;
      if (stateAfterSave is ListsError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              stateAfterSave.message,
              style: AppTextStyle.style9W300.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: AppTextStyle.style9W300.copyWith(color: Colors.white),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _createList(),
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
                onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                onPressed: _isSaving ? null : _createList,
                child: _isSaving
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
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
