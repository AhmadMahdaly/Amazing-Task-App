// ignore_for_file: parameter_assignments, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:s/core/functions/navigation_preferences.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';

class CustomizeNavBarSheet extends StatefulWidget {
  const CustomizeNavBarSheet({super.key});

  @override
  State<CustomizeNavBarSheet> createState() => _CustomizeNavBarSheetState();
}

class _CustomizeNavBarSheetState extends State<CustomizeNavBarSheet> {
  late List<String> selected;
  late List<String> otherKeys;
  late Set<String> selectedOtherKeys;
  final Map<String, String> allTitles = {
    'myDay': AppTexts.myDay,
    'important': AppTexts.important,
    'planned': AppTexts.planned,
    'tasks': AppTexts.tasks,
    'aiTracker': 'AI Tracker',
    'challenges': 'Challenges',
    'islamic': AppTexts.islamicSection,
  };

  @override
  void initState() {
    super.initState();

    final currentList = NavigationPreferences.navItemsNotifier.value;

    selectedOtherKeys = currentList.where((k) => k != 'myDay').toSet();

    otherKeys = [];
    otherKeys.addAll(currentList.where((k) => k != 'myDay'));

    final unselectedKeys = allTitles.keys.where(
      (k) => !selectedOtherKeys.contains(k),
    );
    otherKeys.addAll(unselectedKeys);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
      decoration: BoxDecoration(
        color: AppColors.forthColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          Text(
            AppTexts.selectBottomBarItems,
            style: AppTextStyle.style14Bold.copyWith(color: AppColors.white),
          ),
          16.verticalSpace,
          Material(
            color: AppColors.transparent,
            child: ListTile(
              title: Text(
                AppTexts.myDay,
                style: AppTextStyle.style12W300.copyWith(
                  color: AppColors.white,
                ),
              ),
              leading: Icon(
                Icons.lock,
                color: AppColors.white.withAlpha(150),
                size: 18.r,
              ),
              trailing: const Icon(
                Icons.check_box,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          Divider(color: AppColors.white.withAlpha(50)),

          Expanded(
            child: ReorderableListView.builder(
              itemCount: otherKeys.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = otherKeys.removeAt(oldIndex);
                  otherKeys.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final key = otherKeys[index];
                final isSelected = selectedOtherKeys.contains(key);

                return ColoredBox(
                  key: ValueKey(key),

                  color: isSelected
                      ? AppColors.primaryColor.withAlpha(20)
                      : Colors.transparent,
                  child: Material(
                    color: AppColors.transparent,
                    child: CheckboxListTile(
                      title: Text(
                        allTitles[key]!,
                        style: AppTextStyle.style12W300.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      value: isSelected,
                      activeColor: AppColors.primaryColor,
                      checkColor: AppColors.white,

                      secondary: Icon(
                        Icons.drag_handle_rounded,
                        color: AppColors.white.withAlpha(150),
                      ),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            if (selectedOtherKeys.length < 3) {
                              selectedOtherKeys.add(key);
                            }
                          } else {
                            if (selectedOtherKeys.length > 1) {
                              selectedOtherKeys.remove(key);
                            }
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: CustomPrimaryButton(
              text: AppTexts.save,
              onPressed: () async {
                final finalSaved = ['myDay'];
                for (final key in otherKeys) {
                  if (selectedOtherKeys.contains(key)) {
                    finalSaved.add(key);
                  }
                }

                await NavigationPreferences.saveSelectedItems(finalSaved);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
