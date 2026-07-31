import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';

import '../../domain/entities/note_type.dart';
import '../cubit/notes_cubit.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ملاحظاتي',

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
        body: BlocBuilder<NotesCubit, NotesState>(
          builder: (context, state) {
            if (state is NotesLoading) {
              return const Center(child: LoadingWidget());
            } else if (state is NotesLoaded) {
              if (state.notes.isEmpty) {
                return Center(
                  child: Text(
                    'لا توجد ملاحظات بعد',
                    style: AppTextStyle.style16W600.copyWith(
                      color: AppColors.thirdColor,
                      fontFamily: AppFonts.ar,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: EdgeInsets.all(16.r),
                itemCount: state.notes.length,
                itemBuilder: (context, index) {
                  final note = state.notes[index];
                  final isJournal = note.type == NoteType.journal;

                  final dateFormatted = DateFormat(
                    'dd MMM yyyy',
                  ).format(note.updatedAt);

                  return Card(
                    margin: EdgeInsets.only(bottom: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      side: BorderSide(
                        color: AppColors.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    elevation: 0,
                    child: ListTile(
                      onTap: () {
                        if (isJournal) {
                          context.pushNamed(AppRoutes.journalView, extra: note);
                        } else {
                          context.pushNamed(
                            AppRoutes.addEditNoteView,
                            extra: note,
                          );
                        }
                      },
                      leading: CircleAvatar(
                        backgroundColor: isJournal
                            ? AppColors.secondaryColor.withValues(alpha: 0.2)
                            : AppColors.primaryColor.withValues(alpha: 0.2),
                        child: Icon(
                          isJournal ? Icons.menu_book : Icons.note_alt,
                          color: isJournal
                              ? AppColors.secondaryColor
                              : AppColors.primaryColor,
                        ),
                      ),
                      title: Text(
                        note.title,
                        style: AppTextStyle.style16W600.copyWith(
                          fontFamily: AppFonts.ar,
                        ),
                      ),
                      subtitle: Text(
                        'آخر تعديل: $dateFormatted',
                        style: AppTextStyle.style12W400.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () {
                          context.read<NotesCubit>().deleteNote(note.id);
                        },
                      ),
                    ),
                  );
                },
              );
            } else if (state is NotesError) {
              return Center(child: Text('حدث خطأ: ${state.message}'));
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryColor,
          onPressed: () {
            context.pushNamed(AppRoutes.addEditNoteView, extra: null);
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
