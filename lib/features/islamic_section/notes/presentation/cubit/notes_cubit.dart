import 'package:bloc/bloc.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_highlight.dart';
import 'package:s/features/islamic_section/notes/data/data_sources/notes_data_source.dart';
import 'package:s/features/islamic_section/notes/presentation/utils/notes_section_type.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(
    this._dataSource,
  ) : super(NotesInitial());
  final NotesDataSource _dataSource;

  Future<void> loadNotes(NotesSectionType sectionType) async {
    emit(NotesLoading());

    try {
      final notes = await _dataSource.getNotes(sectionType);
      emit(NotesLoaded(notes));
    } catch (e) {
      emit(NotesError('حدث خطأ أثناء تحميل البيانات'));
    }
  }

  Future<void> deleteNote(dynamic note, NotesSectionType sectionType) async {
    try {
      await _dataSource.deleteNote(note, sectionType);
      emit(NotesActionSuccess('تم الحذف بنجاح'));
      await loadNotes(sectionType);
    } catch (e) {
      emit(NotesError('حدث خطأ أثناء الحذف'));
      await loadNotes(sectionType);
    }
  }

  Future<void> updateHighlight(
    Highlight updatedHighlight,
    NotesSectionType sectionType,
  ) async {
    try {
      await _dataSource.updateHighlight(updatedHighlight, sectionType);
      emit(NotesActionSuccess('تم حفظ التعديلات بنجاح'));
      await loadNotes(sectionType);
    } catch (e) {
      emit(NotesError('حدث خطأ أثناء التعديل'));
      await loadNotes(sectionType);
    }
  }
}
