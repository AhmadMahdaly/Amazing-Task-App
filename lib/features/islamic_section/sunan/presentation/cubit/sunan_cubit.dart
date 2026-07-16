import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:s/features/islamic_section/sunan/data/models/sunan_model.dart';
import 'package:s/features/islamic_section/sunan/domain/entities/sunan_entity.dart';

part 'sunan_state.dart';

class SunanCubit extends Cubit<SunanState> {
  SunanCubit() : super(SunanInitial());

  Future<void> loadSunanData() async {
    emit(SunanLoading());
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/alsonn.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      final data = SunanDataModel.fromJson(jsonMap);

      emit(SunanLoaded(data));
    } catch (e) {
      emit(SunanError('حدث خطأ أثناء تحميل السنن: $e'));
    }
  }
}
