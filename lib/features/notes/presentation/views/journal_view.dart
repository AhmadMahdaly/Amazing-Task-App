import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/di.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';

import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/note_entity.dart';
import '../cubit/notes_cubit.dart';

class JournalView extends StatefulWidget {
  const JournalView({required this.note, super.key});
  final NoteEntity note;

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  late NoteEntity _currentNote;
  late bool _isAscending;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;

    _isAscending = CacheHelper.getData('journal_sort_asc') as bool? ?? true;
  }

  void _toggleSort() {
    setState(() {
      _isAscending = !_isAscending;
    });
    CacheHelper.saveData(key: 'journal_sort_asc', value: _isAscending);
  }

  void _editJournalTitle(BuildContext context) {
    final titleController = TextEditingController(text: _currentNote.title);

    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تعديل اسم الدفتر', style: AppTextStyle.style18W900),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'الاسم الجديد...'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                final newTitle = titleController.text.trim();
                if (newTitle.isNotEmpty) {
                  context.read<NotesCubit>().updateRegularNote(
                    _currentNote,
                    newTitle,
                    _currentNote.content,
                    _currentNote.fontSize,
                  );
                }
                ctx.pop();
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteJournal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(
            'حذف الدفتر',
            style: AppTextStyle.style18W900.copyWith(color: Colors.red),
          ),
          content: const Text(
            'هل أنت متأكد من حذف هذا الدفتر بجميع اليوميات التي بداخله؟\nلا يمكن التراجع عن هذا الإجراء.',
          ),
          actions: [
            TextButton(
              onPressed: () => ctx.pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                context.read<NotesCubit>().deleteNote(_currentNote.id);
                ctx.pop();
                context.pop();
              },
              child: const Text('حذف', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEntryBottomSheet(
    BuildContext context, {
    required NotesCubit notesCubit,
    JournalEntry? existingEntry,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return _JournalEntryEditor(
          note: _currentNote,
          existingEntry: existingEntry,
          notesCubit: context.read<NotesCubit>(),
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
          title: BlocBuilder<NotesCubit, NotesState>(
            builder: (context, state) {
              if (state is NotesLoaded) {
                final updatedNote = state.notes.firstWhere(
                  (n) => n.id == _currentNote.id,
                  orElse: () => _currentNote,
                );
                return Text(
                  updatedNote.title,
                  style: AppTextStyle.style20W900.copyWith(),
                );
              }
              return Text(
                _currentNote.title,
                style: AppTextStyle.style20W900.copyWith(),
              );
            },
          ),
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: Icon(
                _isAscending ? Icons.arrow_downward : Icons.arrow_upward,
              ),
              tooltip: _isAscending ? 'الأقدم أولاً' : 'الأحدث أولاً',
              onPressed: _toggleSort,
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editJournalTitle(context);
                } else if (value == 'delete') {
                  _deleteJournal(context);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('تعديل اسم الدفتر'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('حذف الدفتر', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state is NotesLoaded) {
              _currentNote = state.notes.firstWhere(
                (n) => n.id == _currentNote.id,
                orElse: () => _currentNote,
              );
            }

            final entries = List<JournalEntry>.from(
              _currentNote.journalEntries,
            );
            entries.sort((a, b) {
              return _isAscending
                  ? a.date.compareTo(b.date)
                  : b.date.compareTo(a.date);
            });

            if (entries.isEmpty) {
              return Center(
                child: Text(
                  'لم تكتب أي مذكرات في هذا الجورنال بعد...',
                  style: AppTextStyle.style16W500.copyWith(
                    color: Colors.grey,
                    fontFamily: AppFonts.ar,
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final dateStr = DateFormat(
                  'EEEE, dd MMMM yyyy',
                ).format(entry.date);

                return GestureDetector(
                  onTap: () => _showEntryBottomSheet(
                    context,
                    existingEntry: entry,
                    notesCubit: context.read<NotesCubit>(),
                  ),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.r),
                      border: Border.all(
                        color: AppColors.secondaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        16.verticalSpace,
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.r),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                dateStr,
                                style: AppTextStyle.style12W400.copyWith(
                                  color: AppColors.secondaryColor,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),

                        if (entry.title.isNotEmpty) ...[
                          8.verticalSpace,
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.r),
                            child: Text(
                              entry.title,
                              style: AppTextStyle.style16W900.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ],

                        Divider(
                          height: 16.h,
                          color: AppColors.secondaryColor.withAlpha(15),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.r),
                          child: Text(
                            entry.text,
                            style: AppTextStyle.style12W500.copyWith(
                              fontSize: _currentNote.fontSize,
                              height: 1.6,
                            ),
                          ),
                        ),
                        16.verticalSpace,
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: BlocProvider.value(
          value: getIt<NotesCubit>(),
          child: FloatingActionButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(320.r),
            ),
            backgroundColor: AppColors.primaryColor,
            onPressed: () => _showEntryBottomSheet(
              context,
              notesCubit: context.read<NotesCubit>(),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _JournalEntryEditor extends StatefulWidget {
  const _JournalEntryEditor({
    required this.notesCubit,
    required this.note,
    this.existingEntry,
  });
  final NoteEntity note;
  final JournalEntry? existingEntry;
  final NotesCubit notesCubit;

  @override
  State<_JournalEntryEditor> createState() => _JournalEntryEditorState();
}

class _JournalEntryEditorState extends State<_JournalEntryEditor> {
  late TextEditingController _titleController;
  late TextEditingController _textController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingEntry?.title ?? '',
    );
    _textController = TextEditingController(
      text: widget.existingEntry?.text ?? '',
    );
    _selectedDate = widget.existingEntry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    final text = _textController.text.trim();

    if (text.isEmpty) return;

    final entry = JournalEntry(
      id:
          widget.existingEntry?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      date: _selectedDate,
      text: text,
    );

    widget.notesCubit.saveJournalEntry(
      widget.note,
      entry,
      isNew: widget.existingEntry == null,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.w,
          right: 16.w,
          top: 24.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.existingEntry == null
                      ? 'إضافة يوم جديد'
                      : 'تعديل اليوم',
                  style: AppTextStyle.style18W900.copyWith(),
                ),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        DateFormat('dd / MM / yyyy').format(_selectedDate),
                        style: AppTextStyle.style14W900.copyWith(),
                      ),
                    ),
                    if (widget.existingEntry?.id != null)
                      IconButton(
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () async {
                          await widget.notesCubit.deleteJournalEntry(
                            widget.note,
                            widget.existingEntry!.id,
                          );
                          Navigator.pop(context);
                        },
                      ),
                  ],
                ),
              ],
            ),
            16.verticalSpace,

            CustomPrimaryTextfield(
              controller: _titleController,
              text: 'عنوان اليوم (اختياري)...',
              onChanged: (p0) => setState(() {}),
              hintStyle: AppTextStyle.style14W600.copyWith(
                color: AppColors.secondaryColor,
              ),
            ),
            12.verticalSpace,

            CustomPrimaryTextfield(
              controller: _textController,
              maxLines: 8,
              minLines: 4,
              onChanged: (p0) => setState(() {}),
              text: 'اكتب مذكرات هذا اليوم هنا...',

              hintStyle: AppTextStyle.style16W500.copyWith(
                color: AppColors.secondaryColor,
              ),
            ),
            16.verticalSpace,
            CustomPrimaryButton(
              onPressed: _save,
              text: 'حفظ',
            ),
            24.verticalSpace,
          ],
        ),
      ),
    );
  }
}
