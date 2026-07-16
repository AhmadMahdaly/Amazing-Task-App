import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:s/features/islamic_section/hisn_azkar/data/models/hisn_chapter_model.dart';
import 'package:s/features/islamic_section/hisn_azkar/domain/entities/hisn_chapter_entity.dart';

part 'hisn_state.dart';

class HisnCubit extends Cubit<HisnState> {
  HisnCubit() : super(HisnInitial());

  List<HisnChapterEntity> allChapters = [];

  Future<void> loadHisnData() async {
    emit(HisnLoading());
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/hisn_almuslim.json',
      );

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      allChapters.clear();

      jsonMap.forEach((key, value) {
        allChapters.add(
          HisnChapterModel.fromJson(key, value as Map<String, dynamic>),
        );
      });

      emit(HisnLoaded(allChapters));
    } catch (e) {
      emit(HisnError('حدث خطأ أثناء تحميل حصن المسلم'));
    }
  }

  void search(String query) {
    if (query.trim().isEmpty) {
      emit(HisnLoaded(allChapters));
      return;
    }

    final result = allChapters.where((chapter) {
      return chapter.title.toLowerCase().contains(query.trim().toLowerCase());
    }).toList();

    emit(HisnLoaded(result));
  }
}
