import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/islamic_section/arbaoon/domain/entities/hadith.dart';
import 'package:s/features/islamic_section/arbaoon/domain/repository/arbaoon_repository.dart';

part 'arbaoon_state.dart';

class ArbaoonCubit extends Cubit<ArbaoonState> {
  ArbaoonCubit(this._repository) : super(ArbaoonInitial());

  final ArbaoonRepository _repository;

  List<Hadith> allHadiths = [];

  Hadith? lastReadHadith;

  Future<void> loadHadiths() async {
    emit(ArbaoonLoading());

    try {
      allHadiths = await _repository.getHadiths();

      final lastReadId = CacheHelper.getData(CacheKeys.lastReadHadith) as int?;

      if (lastReadId != null) {
        try {
          lastReadHadith = allHadiths.firstWhere(
            (e) => e.id == lastReadId,
          );
        } catch (_) {}
      }

      emit(
        ArbaoonLoaded(
          hadiths: allHadiths,
          lastReadHadith: lastReadHadith,
        ),
      );
    } catch (e) {
      emit(ArbaoonError(e.toString()));
    }
  }

  Future<void> saveLastRead(Hadith hadith) async {
    lastReadHadith = hadith;

    await CacheHelper.saveData(
      key: CacheKeys.lastReadHadith,
      value: hadith.id,
    );

    if (state is ArbaoonLoaded) {
      emit(
        ArbaoonLoaded(
          hadiths: allHadiths,
          lastReadHadith: lastReadHadith,
        ),
      );
    }
  }

  Hadith? getNextHadith(int currentId) {
    final index = allHadiths.indexWhere((e) => e.id == currentId);

    if (index == -1) return null;

    if (index == allHadiths.length - 1) return null;

    return allHadiths[index + 1];
  }

  Hadith? getPreviousHadith(int currentId) {
    final index = allHadiths.indexWhere((e) => e.id == currentId);

    if (index <= 0) return null;

    return allHadiths[index - 1];
  }

  Hadith? getHadithById(int id) {
    try {
      return allHadiths.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
