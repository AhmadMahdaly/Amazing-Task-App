import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/features/islamic_section/tafsir/data/models/tafsir_model.dart';
import 'package:s/features/islamic_section/tafsir/domain/entities/tafsir_entity.dart';

part 'tafsir_state.dart';

class TafsirCubit extends Cubit<TafsirState> {
  TafsirCubit() : super(TafsirInitial());
  int? lastReadSurah;
  Map<int, List<TafsirEntity>> groupedTafsir = {};
  Future<void> loadTafsirData() async {
    emit(TafsirLoading());
    try {
      lastReadSurah = CacheHelper.getData('last_read_tafsir_surah') as int?;
      final jsonString = await rootBundle.loadString(
        'assets/json/muyassar.json',
      );
      final jsonList = json.decode(jsonString) as List<dynamic>;

      for (final item in jsonList) {
        final tafsir = TafsirModel.fromJson(item as Map<String, dynamic>);
        if (!groupedTafsir.containsKey(tafsir.suraNumber)) {
          groupedTafsir[tafsir.suraNumber] = [];
        }
        groupedTafsir[tafsir.suraNumber]!.add(tafsir);
      }

      emit(TafsirLoaded(groupedTafsir, lastReadSurah));
    } catch (e) {
      emit(TafsirError('حدث خطأ أثناء تحميل التفاسير: $e'));
    }
  }

  List<TafsirEntity> getTafsirForSurah(int suraNumber) {
    if (state is TafsirLoaded) {
      final loadedState = state as TafsirLoaded;
      return loadedState.tafsirBySura[suraNumber] ?? [];
    }
    return [];
  }

  Future<void> saveLastRead(int surahNumber) async {
    lastReadSurah = surahNumber;
    await CacheHelper.saveData(
      key: 'last_read_tafsir_surah',
      value: surahNumber,
    );
    emit(TafsirLoaded(groupedTafsir, lastReadSurah));
  }
}
