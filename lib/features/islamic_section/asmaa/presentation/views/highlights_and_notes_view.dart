// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_highlight.dart';

class HighlightsAndNotesView extends StatefulWidget {
  const HighlightsAndNotesView({super.key});

  @override
  State<HighlightsAndNotesView> createState() => _HighlightsAndNotesViewState();
}

class _HighlightsAndNotesViewState extends State<HighlightsAndNotesView> {
  List<AsmaaHighlight> allHighlights = [];

  final List<Color> _highlightColors = [
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.redAccent,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    _loadAllHighlights();
  }

  void _loadAllHighlights() {
    final temp = <AsmaaHighlight>[];

    for (var i = 1; i <= 99; i++) {
      final savedData = CacheHelper.getData('asmaa_highlights_$i') as String?;
      if (savedData != null) {
        temp.addAll(AsmaaHighlight.decode(savedData));
      }
    }
    setState(() {
      allHighlights = temp;
    });
  }

  void _saveHighlightsForLesson(int lessonId) {
    final lessonHighlights = allHighlights
        .where((h) => h.lessonId == lessonId)
        .toList();

    if (lessonHighlights.isEmpty) {
      CacheHelper.removeData('asmaa_highlights_$lessonId');
    } else {
      CacheHelper.saveData(
        key: 'asmaa_highlights_$lessonId',
        value: AsmaaHighlight.encode(lessonHighlights),
      );
    }
  }

  void _deleteHighlight(AsmaaHighlight highlight) {
    setState(() {
      allHighlights.removeWhere((h) => h.id == highlight.id);
    });

    _saveHighlightsForLesson(highlight.lessonId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف التحديد بنجاح')),
    );
  }

  void _showEditHighlightBottomSheet(AsmaaHighlight highlight) {
    var selectedColor = Color(highlight.colorValue);
    final noteController = TextEditingController(
      text: highlight.note,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.w,
                right: 16.w,
                top: 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تعديل الملاحظة أو اللون',

                    style: AppTextStyle.style18W900.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  16.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _highlightColors.map((color) {
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = color),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  selectedColor.toARGB32() == color.toARGB32()
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  16.verticalSpace,
                  CustomPrimaryTextfield(
                    controller: noteController,
                    text: 'اكتب ملاحظتك هنا (اختياري)',
                    style: AppTextStyle.style16W600.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                    maxLines: 3,
                  ),
                  16.verticalSpace,
                  FilledButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        AppColors.primaryColor,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        final index = allHighlights.indexWhere(
                          (h) => h.id == highlight.id,
                        );
                        if (index != -1) {
                          allHighlights[index] = AsmaaHighlight(
                            id: highlight.id,
                            lessonId: highlight.lessonId,
                            startOffset: highlight.startOffset,
                            endOffset: highlight.endOffset,
                            selectedText: highlight.selectedText,
                            colorValue: selectedColor.toARGB32(),
                            note: noteController.text,
                          );
                        }
                      });

                      _saveHighlightsForLesson(highlight.lessonId);
                      Navigator.pop(context);
                    },
                    child: Text(
                      'حفظ التعديلات',
                      style: AppTextStyle.style18W900.copyWith(
                        fontFamily: AppFonts.amiri,
                      ),
                    ),
                  ),
                  20.verticalSpace,
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ملاحظاتي وتحديداتي',
            style: AppTextStyle.style20W900.copyWith(
              fontFamily: AppFonts.amiri,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
        body: allHighlights.isEmpty
            ? const Center(child: Text('لا توجد ملاحظات أو تحديدات محفوظة'))
            : ListView.builder(
                itemCount: allHighlights.length,
                padding: EdgeInsets.all(16.r),
                itemBuilder: (context, index) {
                  final highlight = allHighlights[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColors.thirdColor,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '"${highlight.selectedText}"',
                          style: AppTextStyle.style18W900.copyWith(
                            fontFamily: AppFonts.amiri,
                            color: AppColors.primaryColor,

                            height: 1.6,
                          ),
                        ),

                        if (highlight.note.isNotEmpty) ...[
                          24.verticalSpace,
                          Row(
                            children: [
                              Icon(
                                Icons.edit_note,
                                color: AppColors.primaryColor,
                                size: 18.r,
                              ),
                              8.horizontalSpace,
                              Expanded(
                                child: Text(
                                  highlight.note,
                                  style: AppTextStyle.style18W600.copyWith(
                                    fontFamily: AppFonts.amiri,
                                    color: AppColors.primaryColor,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // 8.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'درس رقم: ${highlight.lessonId}',
                              style: AppTextStyle.style12W500.copyWith(
                                color: Color(highlight.colorValue),
                                fontFamily: AppFonts.amiri,
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.successColor,
                                    size: 18.r,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () =>
                                      _showEditHighlightBottomSheet(highlight),
                                ),

                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: AppColors.errorColor,
                                    size: 18.r,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) => Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: AlertDialog(
                                          title: Text(
                                            'حذف التحديد',
                                            style: AppTextStyle.style20W900
                                                .copyWith(
                                                  fontFamily: AppFonts.amiri,
                                                  color: AppColors.primaryColor,
                                                ),
                                          ),
                                          content: Text(
                                            'هل أنت متأكد من حذف هذا التحديد؟',
                                            style: AppTextStyle.style18W500
                                                .copyWith(
                                                  fontFamily: AppFonts.amiri,
                                                ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _deleteHighlight(highlight);
                                              },
                                              child: Text(
                                                'حذف',
                                                style: AppTextStyle.style16W900
                                                    .copyWith(
                                                      fontFamily:
                                                          AppFonts.amiri,

                                                      color:
                                                          AppColors.errorColor,
                                                    ),
                                              ),
                                            ),

                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text(
                                                'إلغاء',
                                                style: AppTextStyle.style16W900
                                                    .copyWith(
                                                      fontFamily:
                                                          AppFonts.amiri,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
