// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/di.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/note_entity.dart';
import '../cubit/notes_cubit.dart';

class LineFormatController extends TextEditingController {
  LineFormatController({super.text});

  static const String boldMarker = '\u200B';

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    required bool withComposing,
    TextStyle? style,
  }) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.startsWith(boldMarker)) {
        spans.add(
          TextSpan(
            text: line,
            style: style?.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else {
        spans.add(TextSpan(text: line, style: style));
      }
      if (i < lines.length - 1) {
        spans.add(TextSpan(text: '\n', style: style));
      }
    }
    return TextSpan(style: style, children: spans);
  }
}

bool _isArabic(String text) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
}

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
      builder: (ctx) => AlertDialog(
        title: Text('Edit journal name', style: AppTextStyle.style18W900),
        content: ValueListenableBuilder<TextEditingValue>(
          valueListenable: titleController,
          builder: (context, value, child) {
            final isRtl = _isArabic(value.text);
            return Directionality(
              textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
              child: TextField(
                controller: titleController,
                textAlign: isRtl ? TextAlign.right : TextAlign.left,
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                decoration: const InputDecoration(hintText: 'New name...'),
                autofocus: true,
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppTexts.cancel),
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
                  _currentNote.isBold,
                );
              }
              ctx.pop();
            },
            child: Text(AppTexts.save),
          ),
        ],
      ),
    );
  }

  void _deleteJournal(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete Journal',
          style: AppTextStyle.style18W900.copyWith(color: Colors.red),
        ),
        content: const Text(
          textAlign: TextAlign.center,
          'Are you sure you want to delete this notebook and all the entries inside it?\nThis action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<NotesCubit>().deleteNote(_currentNote.id);
              ctx.pop();
              context.pop();
            },
            child: Text(
              AppTexts.delete,
              style: AppTextStyle.style12W500.copyWith(
                color: AppColors.errorColor,
              ),
            ),
          ),
        ],
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
      useSafeArea: true,
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

  Widget _buildRichText(String text, double fontSize, bool isRtl) {
    final spans = <TextSpan>[];
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isBold = line.startsWith(LineFormatController.boldMarker);

      final displayText = isBold
          ? line.replaceFirst(LineFormatController.boldMarker, '')
          : line;

      spans.add(
        TextSpan(
          text: displayText,
          style: AppTextStyle.style12W500.copyWith(
            // fontSize: fontSize,
            height: 1.6,
            color: AppColors.primaryColor,
            // fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return RichText(
      textAlign: isRtl ? TextAlign.right : TextAlign.left,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      text: TextSpan(children: spans),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state is NotesLoaded) {
              final updatedNote = state.notes.firstWhere(
                (n) => n.id == _currentNote.id,
                orElse: () => _currentNote,
              );
              return SizedBox(
                width: double.infinity,
                child: Text(
                  updatedNote.title,
                  textAlign: _isArabic(updatedNote.title)
                      ? TextAlign.right
                      : TextAlign.left,
                  textDirection: _isArabic(updatedNote.title)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: AppTextStyle.style20W900.copyWith(),
                ),
              );
            }
            return SizedBox(
              width: double.infinity,
              child: Text(
                _currentNote.title,
                textAlign: _isArabic(_currentNote.title)
                    ? TextAlign.right
                    : TextAlign.left,
                textDirection: _isArabic(_currentNote.title)
                    ? TextDirection.rtl
                    : TextDirection.ltr,
                style: AppTextStyle.style20W900.copyWith(),
              ),
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
            tooltip: _isAscending ? 'Oldest first' : 'Newest first',
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
                    Text('Edit journal name'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Delete journal',
                      style: TextStyle(color: Colors.red),
                    ),
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

          final entries =
              List<JournalEntry>.from(
                _currentNote.journalEntries,
              )..sort((a, b) {
                return _isAscending
                    ? a.date.compareTo(b.date)
                    : b.date.compareTo(a.date);
              });

          if (entries.isEmpty) {
            return Center(
              child: Text(
                'No journals yet...',
                style: AppTextStyle.style16W500.copyWith(
                  color: AppColors.secondaryColor,
                ),
              ),
            );
          }

          return ListView.builder(
            // padding: EdgeInsets.all(16.r),
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
                  margin: EdgeInsets.only(bottom: 10.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: AppColors.secondaryColor.withAlpha(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      16.verticalSpace,
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
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
                          child: SizedBox(
                            width: double.infinity,
                            child: Text(
                              entry.title,
                              textAlign: _isArabic(entry.title)
                                  ? TextAlign.right
                                  : TextAlign.left,
                              textDirection: _isArabic(entry.title)
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              style: AppTextStyle.style16W900.copyWith(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                      // Divider(
                      //   height: 16.h,
                      //   color: AppColors.secondaryColor.withAlpha(15),
                      // ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.r),
                        child: SizedBox(
                          width: double.infinity,
                          child: _buildRichText(
                            entry.text,
                            _currentNote.fontSize,
                            _isArabic(entry.text),
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
          child: const Icon(Icons.add, color: AppColors.white),
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

  late LineFormatController _textController;
  late DateTime _selectedDate;

  bool _isBold = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingEntry?.title ?? '',
    );
    _textController = LineFormatController(
      text: widget.existingEntry?.text ?? '',
    );
    _selectedDate = widget.existingEntry?.date ?? DateTime.now();

    _textController.addListener(_checkCurrentLineBoldStatus);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _textController
      ..removeListener(_checkCurrentLineBoldStatus)
      ..dispose();
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

  void _checkCurrentLineBoldStatus() {
    final text = _textController.text;
    final selection = _textController.selection;
    if (!selection.isValid) return;

    var cursor = selection.start;
    if (cursor < 0) cursor = 0;
    if (cursor > text.length) cursor = text.length;

    var lineStart = cursor;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final isCurrentlyBold =
        lineStart < text.length &&
        text.startsWith(LineFormatController.boldMarker, lineStart);

    if (_isBold != isCurrentlyBold) {
      setState(() {
        _isBold = isCurrentlyBold;
      });
    }
  }

  void _toggleBoldForCurrentLine() {
    final text = _textController.text;
    final selection = _textController.selection;
    if (!selection.isValid) return;

    var cursor = selection.start;
    if (cursor < 0) cursor = 0;
    if (cursor > text.length) cursor = text.length;

    var lineStart = cursor;
    while (lineStart > 0 && text[lineStart - 1] != '\n') {
      lineStart--;
    }

    final isCurrentlyBold =
        lineStart < text.length &&
        text.startsWith(LineFormatController.boldMarker, lineStart);

    String newText;
    var newCursorPos = cursor;

    if (isCurrentlyBold) {
      newText = text.replaceRange(
        lineStart,
        lineStart + LineFormatController.boldMarker.length,
        '',
      );
      newCursorPos = (cursor - LineFormatController.boldMarker.length).clamp(
        0,
        newText.length,
      );
    } else {
      newText = text.replaceRange(
        lineStart,
        lineStart,
        LineFormatController.boldMarker,
      );
      newCursorPos = cursor + LineFormatController.boldMarker.length;
    }

    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );
  }

  void _insertBullet() {
    final text = _textController.text;
    final selection = _textController.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    final prefix = start > 0 && text[start - 1] != '\n' ? '\n' : '';
    final insertText = '$prefix• ';

    final newText = text.replaceRange(start, end, insertText);
    _textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + insertText.length),
    );
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
      isBold: _isBold,
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
    final isTitleRtl = _isArabic(_titleController.text);
    final isTextRtl = _isArabic(_textController.text);

    return Padding(
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
              IconButton(onPressed: _save, icon: const Icon(Icons.save)),
              Text(
                widget.existingEntry == null ? 'Add new day' : 'Edit day',
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

          Directionality(
            textDirection: isTitleRtl ? TextDirection.rtl : TextDirection.ltr,
            child: TextField(
              controller: _titleController,

              onChanged: (p0) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Day title (Optional)...',
                hintStyle: AppTextStyle.style14W600.copyWith(
                  color: AppColors.secondaryColor,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Directionality(
              textDirection: isTextRtl ? TextDirection.rtl : TextDirection.ltr,
              child: TextField(
                controller: _textController,
                maxLines: 8,
                minLines: 4,
                onChanged: (p0) => setState(() {}),
                textAlign: isTextRtl ? TextAlign.right : TextAlign.left,
                decoration: InputDecoration(
                  hintText: 'Write your journal here...',
                  hintStyle: AppTextStyle.style16W500.copyWith(
                    color: AppColors.secondaryColor,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                style: const TextStyle(
                  height: 1.5,
                ),
              ),
            ),
          ),

          12.verticalSpace,

          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.format_list_bulleted,
                  color: AppColors.primaryColor,
                ),
                tooltip: 'Add Bullet',
                onPressed: _insertBullet,
              ),
              IconButton(
                icon: Icon(
                  Icons.format_bold,
                  color: _isBold ? AppColors.primaryColor : Colors.grey,
                ),
                tooltip: 'Bold Line',
                onPressed: _toggleBoldForCurrentLine,
              ),
            ],
          ),

          // 24.verticalSpace,
        ],
      ),
    );
  }
}
