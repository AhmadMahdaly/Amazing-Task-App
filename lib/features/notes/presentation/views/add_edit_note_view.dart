import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/entities/note_type.dart';
import '../cubit/notes_cubit.dart';

class AddEditNoteView extends StatefulWidget {
  const AddEditNoteView({this.note, super.key});
  final NoteEntity? note;

  @override
  State<AddEditNoteView> createState() => _AddEditNoteViewState();
}

class _AddEditNoteViewState extends State<AddEditNoteView> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  NoteType _selectedType = NoteType.regular;
  double _fontSize = 16;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    if (widget.note != null) {
      _selectedType = widget.note!.type;
      _fontSize = widget.note!.fontSize;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty) return;

    if (widget.note == null) {
      context.read<NotesCubit>().addNote(
        title: title,
        content: content,
        type: _selectedType,
        fontSize: _fontSize,
      );
    } else {
      context.read<NotesCubit>().updateRegularNote(
        widget.note!,
        title,
        content,
        _fontSize,
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.note == null;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isNew ? 'نوت جديدة' : 'تعديل النوت',
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
          actions: [
            IconButton(
              icon: const Icon(Icons.text_decrease),
              onPressed: () =>
                  setState(() => _fontSize = (_fontSize - 2).clamp(12.0, 30.0)),
            ),
            IconButton(
              icon: const Icon(Icons.text_increase),
              onPressed: () =>
                  setState(() => _fontSize = (_fontSize + 2).clamp(12.0, 30.0)),
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isNew) ...[
                Row(
                  children: [
                    Text(
                      'النوع:',
                      style: AppTextStyle.style16W600.copyWith(
                        fontFamily: AppFonts.ar,
                      ),
                    ),
                    8.horizontalSpace,
                    ChoiceChip(
                      label: const Text('نوت عادية'),
                      selected: _selectedType == NoteType.regular,
                      onSelected: (val) =>
                          setState(() => _selectedType = NoteType.regular),
                      selectedColor: AppColors.primaryColor.withValues(
                        alpha: 0.3,
                      ),
                    ),
                    8.horizontalSpace,
                    ChoiceChip(
                      label: const Text('مذكرة يومية (Journal)'),
                      selected: _selectedType == NoteType.journal,
                      onSelected: (val) =>
                          setState(() => _selectedType = NoteType.journal),
                      selectedColor: AppColors.secondaryColor.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ],
                ),
                16.verticalSpace,
              ],
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'عنوان النوت...',
                  border: InputBorder.none,
                ),
                style: AppTextStyle.style20W900.copyWith(
                  fontFamily: AppFonts.ar,
                ),
              ),
              const Divider(),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(
                    hintText: 'اكتب ما تفكر فيه...',
                    border: InputBorder.none,
                  ),
                  style: TextStyle(
                    fontFamily: AppFonts.ar,
                    fontSize: _fontSize,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
