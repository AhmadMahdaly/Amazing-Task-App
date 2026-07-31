import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';

import '../../domain/entities/note_entity.dart';
import '../cubit/notes_cubit.dart';

class JournalView extends StatefulWidget {
  const JournalView({required this.note, super.key});
  final NoteEntity note;

  @override
  State<JournalView> createState() => _JournalViewState();
}

class _JournalViewState extends State<JournalView> {
  late TextEditingController _entryController;
  late ScrollController _scrollController;
  late double _fontSize;
  late NoteEntity _currentNote;

  @override
  void initState() {
    super.initState();
    _currentNote = widget.note;
    _entryController = TextEditingController();
    _scrollController = ScrollController();
    _fontSize = widget.note.fontSize;
  }

  @override
  void dispose() {
    _entryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _updateFontSizeInCubit(double newSize) {
    setState(() {
      _fontSize = newSize.clamp(12.0, 30.0);
    });

    context.read<NotesCubit>().updateRegularNote(
      _currentNote,
      _currentNote.title,
      _currentNote.content,
      _fontSize,
    );
  }

  void _saveEntry() {
    final newEntry = _entryController.text.trim();
    if (newEntry.isEmpty) return;

    context.read<NotesCubit>().addJournalEntry(_currentNote, newEntry);

    _entryController.clear();
    FocusScope.of(context).unfocus();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _currentNote.title,
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
              onPressed: () => _updateFontSizeInCubit(_fontSize - 2),
            ),
            IconButton(
              icon: const Icon(Icons.text_increase),
              onPressed: () => _updateFontSizeInCubit(_fontSize + 2),
            ),
          ],
        ),
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state is NotesLoaded) {
              final updatedNote = state.notes.firstWhere(
                (n) => n.id == _currentNote.id,
                orElse: () => _currentNote,
              );
              _currentNote = updatedNote;
            }

            return Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: Colors.grey.withValues(alpha: 0.05),
                    padding: EdgeInsets.all(16.r),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      child: Text(
                        _currentNote.content.isEmpty
                            ? 'لم تكتب أي مذكرات هنا بعد...'
                            : _currentNote.content,
                        style: TextStyle(
                          fontFamily: AppFonts.ar,
                          fontSize: _fontSize,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _entryController,
                            maxLines: 5,
                            minLines: 1,
                            decoration: InputDecoration(
                              hintText: 'كيف كان يومك؟...',
                              hintStyle: AppTextStyle.style14W400,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.r),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.r),
                                borderSide: const BorderSide(
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ),
                            style: AppTextStyle.style16W500.copyWith(
                              fontFamily: AppFonts.ar,
                            ),
                          ),
                        ),
                        8.horizontalSpace,
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.secondaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.send, color: Colors.white),
                            onPressed: _saveEntry,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
