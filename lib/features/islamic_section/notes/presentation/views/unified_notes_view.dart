// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_highlight.dart';
import 'package:s/features/islamic_section/notes/presentation/cubit/notes_cubit.dart';
import 'package:s/features/islamic_section/notes/presentation/utils/notes_section_type.dart';
import 'package:s/features/islamic_section/quran/domain/entities/saved_ayah_note_entity.dart';

class UnifiedNotesView extends StatelessWidget {
  const UnifiedNotesView({required this.sectionType, super.key});
  final NotesSectionType sectionType;

  String _getAppBarTitle() {
    switch (sectionType) {
      case NotesSectionType.quran:
        return 'ملاحظاتي والآيات المحفوظة';
      case NotesSectionType.asmaa:
      case NotesSectionType.arbaoon:
        return 'ملاحظاتي وتحديداتي';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75.h,
          title: Text(
            _getAppBarTitle(),
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
        body: BlocConsumer<NotesCubit, NotesState>(
          listener: (context, state) {
            if (state is NotesActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is NotesError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              );
            }
          },
          buildWhen: (previous, current) =>
              current is NotesLoaded || current is NotesLoading,
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotesLoaded) {
              final notes = state.notes;

              if (notes.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد ملاحظات محفوظة حالياً.',
                    style: AppTextStyle.style16W800.copyWith(
                      color: AppColors.secondaryColor,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = sectionType == NotesSectionType.quran
                      ? notes.reversed.toList()[index]
                      : notes[index];

                  if (sectionType == NotesSectionType.quran) {
                    return _QuranNoteCard(
                      note: note as SavedAyahNote,
                      sectionType: sectionType,
                    );
                  } else {
                    return _HighlightNoteCard(
                      highlight: note as AsmaaHighlight,
                      isArbaoon: sectionType == NotesSectionType.arbaoon,
                      sectionType: sectionType,
                    );
                  }
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _QuranNoteCard extends StatelessWidget {
  const _QuranNoteCard({required this.sectionType, required this.note});
  final SavedAyahNote note;
  final NotesSectionType sectionType;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 16.r),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.r,
                    vertical: 8.r,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'سورة ${note.surahName} - آية ${note.ayahNumber}',
                    style: AppTextStyle.style14W500.copyWith(
                      color: Colors.white,
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _confirmDelete(context, note, sectionType),
                ),
              ],
            ),
            12.verticalSpace,
            Text(
              note.ayahText,
              style: AppTextStyle.style20W900.copyWith(
                fontFamily: AppFonts.quran,
                color: AppColors.primaryColor,
                height: 1.8,
              ),
              textAlign: TextAlign.justify,
            ),
            if (note.note.trim().isNotEmpty) ...[
              16.verticalSpace,
              const Divider(),
              8.verticalSpace,
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.edit_note, color: AppColors.secondaryColor),
                  8.horizontalSpace,
                  Expanded(
                    child: Text(
                      note.note,
                      style: AppTextStyle.style16W800.copyWith(
                        fontFamily: AppFonts.amiri,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    SavedAyahNote note,
    NotesSectionType sectionType,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'حذف الملاحظة',
            style: AppTextStyle.style20W900.copyWith(
              fontFamily: AppFonts.amiri,
              color: AppColors.primaryColor,
            ),
          ),
          content: Text(
            'هل أنت متأكد من أنك تريد حذف هذه الملاحظة؟',
            style: AppTextStyle.style16W600.copyWith(
              fontFamily: AppFonts.amiri,
              color: AppColors.primaryColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<NotesCubit>().deleteNote(note, sectionType);
              },
              child: Text(
                'حذف',
                style: AppTextStyle.style16W900.copyWith(
                  fontFamily: AppFonts.amiri,
                  color: AppColors.errorColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: AppTextStyle.style16W900.copyWith(
                  fontFamily: AppFonts.amiri,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightNoteCard extends StatelessWidget {
  const _HighlightNoteCard({
    required this.sectionType,
    required this.highlight,
    required this.isArbaoon,
  });
  final AsmaaHighlight highlight;
  final bool isArbaoon;
  final NotesSectionType sectionType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.thirdColor, width: 1),
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
              fontFamily: isArbaoon ? AppFonts.hadith : AppFonts.amiri,
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
                    onPressed: () => _showEditHighlightBottomSheet(
                      context,
                      highlight,
                      sectionType,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.errorColor,
                      size: 18.r,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () =>
                        _confirmDelete(context, highlight, sectionType),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AsmaaHighlight highlight,
    NotesSectionType sectionType,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'حذف التحديد',
            style: AppTextStyle.style20W900.copyWith(
              fontFamily: AppFonts.amiri,
              color: AppColors.primaryColor,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف هذا التحديد؟',
            style: AppTextStyle.style18W500.copyWith(
              fontFamily: AppFonts.amiri,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<NotesCubit>().deleteNote(highlight, sectionType);
              },
              child: Text(
                'حذف',
                style: AppTextStyle.style16W900.copyWith(
                  fontFamily: AppFonts.amiri,
                  color: AppColors.errorColor,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'إلغاء',
                style: AppTextStyle.style16W900.copyWith(
                  fontFamily: AppFonts.amiri,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditHighlightBottomSheet(
    BuildContext parentContext,
    AsmaaHighlight highlight,
    NotesSectionType sectionType,
  ) {
    final highlightColors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.redAccent,
      Colors.purple,
    ];
    var selectedColor = Color(highlight.colorValue);
    final noteController = TextEditingController(text: highlight.note);

    showModalBottomSheet<void>(
      context: parentContext,
      isScrollControlled: true,
      builder: (sheetContext) {
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
                    children: highlightColors.map((color) {
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
                    textAlign: TextAlign.center,
                    hintStyle: AppTextStyle.style16W600.copyWith(
                      fontFamily: AppFonts.amiri,
                      color: AppColors.secondaryColor,
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
                      final updatedHighlight = AsmaaHighlight(
                        id: highlight.id,
                        lessonId: highlight.lessonId,
                        startOffset: highlight.startOffset,
                        endOffset: highlight.endOffset,
                        selectedText: highlight.selectedText,
                        colorValue: selectedColor.toARGB32(),
                        note: noteController.text,
                      );

                      parentContext.read<NotesCubit>().updateHighlight(
                        updatedHighlight,
                        sectionType,
                      );
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
}
