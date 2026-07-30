import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/islamic_section/anbyaa/domain/entities/anbyaa.dart';
import 'package:s/features/islamic_section/anbyaa/domain/repository/anbyaa_repository.dart';

part 'anbyaa_state.dart';

class AnbyaaCubit extends Cubit<AnbyaaState> {
  AnbyaaCubit(this._repository) : super(AnbyaaInitial());

  final AnbyaaRepository _repository;

  List<Anbyaa> allAnbyaa = [];

  Anbyaa? lastReadAnbyaa;

  Future<void> loadTabeen() async {
    emit(AnbyaaLoading());

    try {
      allAnbyaa = await _repository.getAll();

      final lastReadId = CacheHelper.getData(CacheKeys.lastReadAnbyaa) as int?;

      if (lastReadId != null) {
        try {
          lastReadAnbyaa = allAnbyaa.firstWhere(
            (e) => e.id == lastReadId,
          );
        } catch (_) {}
      }

      emit(
        AnbyaaLoaded(
          anbyaa: allAnbyaa,
          lastReadAnbyaa: lastReadAnbyaa,
        ),
      );
    } catch (e) {
      emit(AnbyaaError(e.toString()));
    }
  }

  Future<void> saveLastRead(Anbyaa anbyaa) async {
    lastReadAnbyaa = anbyaa;

    await CacheHelper.saveData(
      key: CacheKeys.lastReadAnbyaa,
      value: anbyaa.id,
    );

    if (state is AnbyaaLoaded) {
      emit(
        AnbyaaLoaded(
          anbyaa: allAnbyaa,
          lastReadAnbyaa: lastReadAnbyaa,
        ),
      );
    }
  }

  Anbyaa? getNextAnbyaa(int currentId) {
    final index = allAnbyaa.indexWhere((e) => e.id == currentId);

    if (index == -1) return null;

    if (index == allAnbyaa.length - 1) return null;

    return allAnbyaa[index + 1];
  }

  Anbyaa? getPreviousAnbyaa(int currentId) {
    final index = allAnbyaa.indexWhere((e) => e.id == currentId);

    if (index <= 0) return null;

    return allAnbyaa[index - 1];
  }

  Anbyaa? getAnbyaaById(int id) {
    try {
      return allAnbyaa.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
