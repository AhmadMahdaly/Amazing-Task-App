import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/utils/app_icons_helper.dart';
import 'package:s/features/task_list/domain/entities/task_list_entity.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';

class AddListBottomSheet extends StatefulWidget {
  const AddListBottomSheet({super.key, this.listToEdit});

  final TaskListEntity? listToEdit;

  @override
  State<AddListBottomSheet> createState() => _AddListBottomSheetState();
}

class _AddListBottomSheetState extends State<AddListBottomSheet> {
  late final TextEditingController _listController;
  bool _isSaving = false;
  late int _selectedIconCode;

  bool get _isEdit => widget.listToEdit != null;

  @override
  void initState() {
    super.initState();
    _listController = TextEditingController(
      text: widget.listToEdit?.title ?? '',
    );

    _selectedIconCode = widget.listToEdit?.iconCode ?? Icons.list.codePoint;
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _showIconPicker() async {
    FocusScope.of(context).unfocus();

    await showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppTexts.chooseListIcon,
                  style: AppTextStyle.style12Bold.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                16.verticalSpace,
                Wrap(
                  spacing: 16.w,
                  runSpacing: 16.h,
                  alignment: WrapAlignment.center,
                  children: AppIconsHelper.availableIcons.map((iconData) {
                    final isSelected = iconData.codePoint == _selectedIconCode;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedIconCode = iconData.codePoint);
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(32.r),
                      child: Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primaryColor
                              : AppColors.secondaryColor.withAlpha(33),
                        ),
                        child: Icon(
                          iconData,
                          color: isSelected
                              ? Colors.white
                              : AppColors.primaryColor.withAlpha(150),
                          size: 28.r,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                16.verticalSpace,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _save() async {
    final title = _listController.text.trim();
    if (title.isEmpty || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final listsCubit = context.read<ListsCubit>();
      final success = _isEdit
          ? await listsCubit.updateList(
              TaskListEntity(
                id: widget.listToEdit!.id,
                title: title,
                position: widget.listToEdit!.position,
                iconCode: _selectedIconCode,
              ),
            )
          : await listsCubit.addList(
              TaskListEntity(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                title: title,
                iconCode: _selectedIconCode,
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
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEdit ? AppTexts.editList : AppTexts.newList,
            style: AppTextStyle.style16Bold.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          16.verticalSpace,

          Row(
            children: [
              InkWell(
                onTap: _showIconPicker,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    AppIconsHelper.getIconFromCode(_selectedIconCode),
                    color: AppColors.primaryColor,
                    size: 24.r,
                  ),
                ),
              ),
              8.horizontalSpace,
              Expanded(
                child: CustomPrimaryTextfield(
                  controller: _listController,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _save(),
                  text: AppTexts.enterListName,
                ),
              ),
            ],
          ),

          24.verticalSpace,

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
                child: Text(
                  AppTexts.cancel,
                  style: AppTextStyle.style12W300.copyWith(
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
              8.horizontalSpace,
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  minimumSize: Size(90.w, 40.h),
                  elevation: 0,
                ),
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const LoadingWidget(
                          color: AppColors.white,
                        ),
                      )
                    : Text(
                        _isEdit ? AppTexts.save : AppTexts.createList,
                        style: AppTextStyle.style12W300.copyWith(
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
