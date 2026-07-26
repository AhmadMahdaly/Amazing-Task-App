// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/features/islamic_section/quran/data/models/hizb_model.dart';
import 'package:s/features/islamic_section/quran/data/models/juz_model.dart';
import 'package:s/features/islamic_section/quran/data/models/surah_model.dart';
import 'package:s/features/islamic_section/quran/data/models/tafsir_model.dart';
import 'package:s/features/islamic_section/quran/domain/entities/hizb_entity.dart';
import 'package:s/features/islamic_section/quran/domain/entities/juz_entity.dart';
import 'package:s/features/islamic_section/quran/domain/entities/surah_entity.dart';

part 'quran_state.dart';

class QuranCubit extends Cubit<QuranState> {
  QuranCubit() : super(QuranInitial());

  List<SurahEntity> allSurahs = [];
  List<JuzEntity> allJuz = [];
  List<HizbEntity> allHizb = [];
  List<String> allAyahsText = [];
  List<TafsirModel> allTafsir = [];
  int? lastReadSurah;
  QuranIndexType indexType = QuranIndexType.surahs;
  Future<void> loadSurahs() async {
    emit(QuranLoading());
    try {
      lastReadSurah = CacheHelper.getData(CacheKeys.lastReadSurah) as int?;

      final jsonString = await rootBundle.loadString('assets/json/surahs.json');
      final jsonList = json.decode(jsonString) as List<dynamic>;
      allSurahs = jsonList
          .map((e) => SurahModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final quranText = await rootBundle.loadString(
        'assets/text/quran-uthmani-min.txt',
      );
      allAyahsText = quranText.trim().split('\n');
      final tafsirJson = await rootBundle.loadString(
        'assets/json/muyassar.json',
      );
      final divisionString = await rootBundle.loadString(
        'assets/json/quran_divisions.json',
      );

      final divisionJson = json.decode(divisionString);

      allJuz = (divisionJson['juz'] as List)
          .map((e) => JuzModel.fromJson(e as Map<String, dynamic>))
          .toList();

      allHizb = (divisionJson['hizb'] as List)
          .map((e) => HizbModel.fromJson(e as Map<String, dynamic>))
          .toList();
      final tafsirList = json.decode(tafsirJson) as List;

      allTafsir = tafsirList
          .map((e) => TafsirModel.fromJson(e as Map<String, dynamic>))
          .toList();
      emit(QuranLoaded(surahs: allSurahs, lastReadSurahNumber: lastReadSurah));
    } catch (e) {
      emit(QuranError('حدث خطأ أثناء التحميل'));
    }
  }

  TafsirModel? getTafsir({
    required int surah,
    required int ayah,
  }) {
    try {
      return allTafsir.firstWhere(
        (e) => e.sura == surah && e.aya == ayah,
      );
    } catch (_) {
      return null;
    }
  }

  List<String> getAyahsForSurah(int surahNumber) {
    if (allAyahsText.isEmpty) return [];

    final ayahs = <String>[];

    for (final line in allAyahsText) {
      if (line.trim().isEmpty) continue;

      final parts = line.split('|');

      if (parts.length >= 3) {
        final fileSurahNum = int.tryParse(parts[0].trim());

        if (fileSurahNum == surahNumber) {
          ayahs.add(parts.sublist(2).join('|').trim());
        }
      }
    }

    return ayahs;
  }

  List<SurahEntity> getSurahsInJuz(int juzNumber) {
    return allSurahs
        .where((s) => _getJuzForPage(s.startPage) == juzNumber)
        .toList();
  }

  int _getJuzForPage(int page) {
    return ((page - 1) ~/ 20) + 1;
  }

  Future<void> saveLastRead(int surahNumber) async {
    lastReadSurah = surahNumber;
    await CacheHelper.saveData(
      key: CacheKeys.lastReadSurah,
      value: surahNumber,
    );
    emit(QuranLoaded(surahs: allSurahs, lastReadSurahNumber: lastReadSurah));
  }

  void changeIndex(QuranIndexType type) {
    indexType = type;

    emit(
      QuranLoaded(
        surahs: allSurahs,
        lastReadSurahNumber: lastReadSurah,
      ),
    );
  }

  void refreshIndex() {
    emit(QuranLoaded(surahs: allSurahs, lastReadSurahNumber: lastReadSurah));
  }
}
