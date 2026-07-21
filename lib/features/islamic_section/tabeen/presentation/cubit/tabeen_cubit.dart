import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/islamic_section/tabeen/domain/entities/tabeen.dart';
import 'package:s/features/islamic_section/tabeen/domain/repository/tabeen_repository.dart';

part 'tabeen_state.dart';

class TabeenCubit extends Cubit<TabeenState> {
  TabeenCubit(this._repository) : super(TabeenInitial());

  final TabeenRepository _repository;

  List<Tabeen> allTabeen = [];

  Tabeen? lastReadTabeen;

  Future<void> loadTabeen() async {
    emit(TabeenLoading());

    try {
      allTabeen = await _repository.getAll();

      final lastReadId = CacheHelper.getData(CacheKeys.lastReadTabeen) as int?;

      if (lastReadId != null) {
        try {
          lastReadTabeen = allTabeen.firstWhere(
            (e) => e.id == lastReadId,
          );
        } catch (_) {}
      }

      emit(
        TabeenLoaded(
          tabeen: allTabeen,
          lastReadTabeen: lastReadTabeen,
        ),
      );
    } catch (e) {
      emit(TabeenError(e.toString()));
    }
  }

  Future<void> saveLastRead(Tabeen hadith) async {
    lastReadTabeen = hadith;

    await CacheHelper.saveData(
      key: CacheKeys.lastReadTabeen,
      value: hadith.id,
    );

    if (state is TabeenLoaded) {
      emit(
        TabeenLoaded(
          tabeen: allTabeen,
          lastReadTabeen: lastReadTabeen,
        ),
      );
    }
  }

  Tabeen? getNextHadith(int currentId) {
    final index = allTabeen.indexWhere((e) => e.id == currentId);

    if (index == -1) return null;

    if (index == allTabeen.length - 1) return null;

    return allTabeen[index + 1];
  }

  Tabeen? getPreviousHadith(int currentId) {
    final index = allTabeen.indexWhere((e) => e.id == currentId);

    if (index <= 0) return null;

    return allTabeen[index - 1];
  }

  Tabeen? getHadithById(int id) {
    try {
      return allTabeen.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
