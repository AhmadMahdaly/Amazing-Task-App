import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';

import '../../domain/entities/note_entity.dart';
import '../../domain/entities/note_type.dart';
import '../cubit/notes_cubit.dart';

bool _isArabic(String text) {
  return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
}

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

  bool _isBold = false;

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
      _isBold = widget.note!.isBold;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _insertBullet() {
    final text = _contentController.text;
    final selection = _contentController.selection;

    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;

    final prefix = start > 0 && text[start - 1] != '\n' ? '\n' : '';
    final insertText = '$prefix• ';

    final newText = text.replaceRange(start, end, insertText);

    _contentController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + insertText.length),
    );
  }

  Future<void> _saveNote({bool goToJournal = false}) async {
    final title = _titleController.text.trim();
    final content = _selectedType == NoteType.regular
        ? _contentController.text.trim()
        : '';

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write the title first.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (widget.note == null) {
      final newNote = await context.read<NotesCubit>().addNote(
        title: title,
        content: content,
        type: _selectedType,
        fontSize: _fontSize,
        isBold: _isBold,
      );

      if (!mounted) return;

      if (goToJournal && newNote != null) {
        context.pop();
        context.pushNamed(
          AppRoutes.journalView,
          extra: newNote,
        );
      } else {
        context.pop();
      }
    } else {
      await context.read<NotesCubit>().updateRegularNote(
        widget.note!,
        title,
        content,
        _fontSize,
        _isBold,
      );
      if (!mounted) return;
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.note == null;

    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: wallpaperState.settings.hasWallpaper
              ? Colors.transparent
              : AppColors.primaryColor,

          appBar: AppBar(
            title: Text(
              isNew ? 'New note' : 'Edit note',
              style: AppTextStyle.style20W900.copyWith(),
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
                icon: const Icon(Icons.check),
                onPressed: () => _saveNote(goToJournal: false),
              ),
              if (!isNew)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'delete') {
                      context.read<NotesCubit>().deleteNote(widget.note!.id);
                      context.pop();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete note',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
          body: AppWallpaper(
            settings: wallpaperState.settings,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isNew) ...[
                          Row(
                            children: [
                              Text(
                                'Type:',
                                style: AppTextStyle.style16W600.copyWith(
                                  color: AppColors.thirdColor,
                                ),
                              ),
                              8.horizontalSpace,
                              ChoiceChip(
                                label: const Text('Notes'),
                                selected: _selectedType == NoteType.regular,
                                onSelected: (val) => setState(
                                  () => _selectedType = NoteType.regular,
                                ),
                                selectedColor: AppColors.white.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                              8.horizontalSpace,
                              ChoiceChip(
                                label: const Text('Journals'),
                                selected: _selectedType == NoteType.journal,
                                onSelected: (val) => setState(
                                  () => _selectedType = NoteType.journal,
                                ),
                                selectedColor: AppColors.white.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ],
                          ),
                          16.verticalSpace,
                        ],
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _titleController,
                          builder: (context, value, child) {
                            final isRtl = _isArabic(value.text);
                            return TextField(
                              controller: _titleController,
                              textAlign: isRtl
                                  ? TextAlign.right
                                  : TextAlign.left,
                              textDirection: isRtl
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              decoration: InputDecoration(
                                hintText: _selectedType == NoteType.regular
                                    ? 'Note title...'
                                    : 'Journal title...',
                                border: InputBorder.none,
                                hintStyle: AppTextStyle.style16W600.copyWith(
                                  color: AppColors.white.withAlpha(
                                    150,
                                  ),
                                ),
                              ),
                              style: AppTextStyle.style16W600.copyWith(
                                color: AppColors.white,
                              ),
                            );
                          },
                        ),
                        const Divider(),
                        if (_selectedType == NoteType.regular)
                          Expanded(
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: _contentController,
                              builder: (context, value, child) {
                                final isRtl = _isArabic(value.text);
                                return TextField(
                                  controller: _contentController,
                                  textAlign: isRtl
                                      ? TextAlign.right
                                      : TextAlign.left,
                                  textDirection: isRtl
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  maxLines: null,
                                  expands: true,
                                  decoration: InputDecoration(
                                    hintText: "Write what you're thinking...",
                                    hintStyle: AppTextStyle.style12W500
                                        .copyWith(
                                          color: AppColors.white.withAlpha(
                                            150,
                                          ),
                                        ),
                                    border: InputBorder.none,
                                  ),
                                  style: TextStyle(
                                    color: AppColors.white,
                                    fontSize: _fontSize,
                                    fontWeight: _isBold
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    height: 1.5,
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Expanded(
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book,
                                    size: 70.r,
                                    color: AppColors.secondaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                  16.verticalSpace,
                                  Text(
                                    'This notebook is for writing and organizing diaries and separate topics.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.style16W600.copyWith(
                                      color: AppColors.secondaryColor,
                                      height: 1.6,
                                    ),
                                  ),
                                  24.verticalSpace,
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 24.w,
                                    ),
                                    child: CustomPrimaryButton(
                                      text: 'Save and start adding topics',
                                      onPressed: () =>
                                          _saveNote(goToJournal: true),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                if (_selectedType == NoteType.regular)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.format_list_bulleted,
                              color: AppColors.primaryColor,
                            ),
                            tooltip: 'Add Bullet Point',
                            onPressed: _insertBullet,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.format_bold,
                              color: _isBold
                                  ? AppColors.primaryColor
                                  : Colors.grey,
                            ),
                            tooltip: 'Bold Text',
                            onPressed: () => setState(() => _isBold = !_isBold),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.text_decrease,
                              color: Colors.grey,
                            ),
                            tooltip: 'Decrease Font Size',
                            onPressed: () => setState(
                              () =>
                                  _fontSize = (_fontSize - 2).clamp(12.0, 30.0),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.text_increase,
                              color: Colors.grey,
                            ),
                            tooltip: 'Increase Font Size',
                            onPressed: () => setState(
                              () =>
                                  _fontSize = (_fontSize + 2).clamp(12.0, 30.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
