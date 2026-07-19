// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/islamic_section/quran/domain/entities/saved_ayah_note_entity.dart';

class SavedAyahsAndNotesView extends StatefulWidget {
  const SavedAyahsAndNotesView({super.key});

  @override
  State<SavedAyahsAndNotesView> createState() => _SavedAyahsAndNotesViewState();
}

class _SavedAyahsAndNotesViewState extends State<SavedAyahsAndNotesView> {
  List<SavedAyahNote> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() {
    final savedNotesStr = CacheHelper.getData('saved_ayahs_notes') as String?;
    if (savedNotesStr != null) {
      setState(() {
        _notes = SavedAyahNote.decode(savedNotesStr);
      });
    }
  }

  void _deleteNote(String id) {
    setState(() {
      _notes.removeWhere((note) => note.id == id);
    });
    CacheHelper.saveData(
      key: 'saved_ayahs_notes',
      value: SavedAyahNote.encode(_notes),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حذف الملاحظة')),
    );
  }

  void _confirmDelete(String id) {
    showDialog<void>(
      context: context,
      builder: (context) => Directionality(
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
                Navigator.pop(context);
                _deleteNote(id);
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
              onPressed: () => Navigator.pop(context),
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75.h,
          title: Text(
            'ملاحظاتي والآيات المحفوظة',
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
        body: _notes.isEmpty
            ? Center(
                child: Text(
                  'لا توجد ملاحظات أو آيات محفوظة حالياً.',
                  style: AppTextStyle.style16W800.copyWith(
                    color: AppColors.secondaryColor,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  final note = _notes.reversed.toList()[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.only(bottom: 16.r),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
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
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _confirmDelete(note.id),
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
                          16.verticalSpace,
                          const Divider(),
                          8.verticalSpace,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.edit_note,
                                color: AppColors.secondaryColor,
                              ),
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
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
