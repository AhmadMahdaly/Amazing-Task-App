import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';

import '../../domain/entities/note_type.dart';
import '../cubit/notes_cubit.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppTexts.myNote,
          style: AppTextStyle.style20W900.copyWith(),
        ),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('الكل'),
                    selected: _selectedFilter == 0,
                    onSelected: (val) => setState(() => _selectedFilter = 0),
                    selectedColor: AppColors.primaryColor.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  8.horizontalSpace,
                  ChoiceChip(
                    label: const Text('نوت عادية'),
                    selected: _selectedFilter == 1,
                    onSelected: (val) => setState(() => _selectedFilter = 1),
                    selectedColor: AppColors.primaryColor.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  8.horizontalSpace,
                  ChoiceChip(
                    label: const Text('الدفاتر (Journal)'),
                    selected: _selectedFilter == 2,
                    onSelected: (val) => setState(() => _selectedFilter = 2),
                    selectedColor: AppColors.secondaryColor.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<NotesCubit, NotesState>(
              builder: (context, state) {
                if (state is NotesLoading) {
                  return const Center(child: LoadingWidget());
                } else if (state is NotesLoaded) {
                  final filteredNotes = state.notes.where((note) {
                    if (_selectedFilter == 1)
                      return note.type == NoteType.regular;
                    if (_selectedFilter == 2)
                      return note.type == NoteType.journal;
                    return true;
                  }).toList();

                  if (filteredNotes.isEmpty) {
                    return Center(
                      child: Text(
                        AppTexts.noNotesAdded,
                        style: AppTextStyle.style16W600.copyWith(
                          color: AppColors.thirdColor,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    separatorBuilder: (context, index) => 12.verticalSpace,
                    padding: EdgeInsets.all(16.r),
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      final isJournal = note.type == NoteType.journal;

                      final dateFormatted = DateFormat(
                        'dd MMM yyyy',
                      ).format(note.updatedAt);

                      return InkWell(
                        borderRadius: BorderRadius.circular(12.r),
                        onTap: () async {
                          if (isJournal) {
                            await context.pushNamed(
                              AppRoutes.journalView,
                              extra: note,
                            );
                          } else {
                            await context.pushNamed(
                              AppRoutes.addEditNoteView,
                              extra: note,
                            );
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isJournal
                                  ? AppColors.secondaryColor.withValues(
                                      alpha: 0.2,
                                    )
                                  : AppColors.primaryColor.withValues(
                                      alpha: 0.2,
                                    ),
                              child: Icon(
                                isJournal ? Icons.menu_book : Icons.note_alt,
                                color: isJournal
                                    ? AppColors.thirdColor
                                    : AppColors.primaryColor,
                              ),
                            ),
                            title: Text(
                              note.title,
                              style: AppTextStyle.style16W600.copyWith(),
                            ),
                            subtitle: isJournal
                                ? null
                                : Text(
                                    '${AppTexts.lastEdit}: $dateFormatted',
                                    style: AppTextStyle.style12W400.copyWith(
                                      color: AppColors.secondaryColor,
                                      fontSize: 10.sp,
                                    ),
                                  ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is NotesError) {
                  return Center(child: Text(AppTexts.thereIsAnError));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(320.r),
        ),
        backgroundColor: AppColors.primaryColor,
        onPressed: () async {
          await context.pushNamed(AppRoutes.addEditNoteView);
        },
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
