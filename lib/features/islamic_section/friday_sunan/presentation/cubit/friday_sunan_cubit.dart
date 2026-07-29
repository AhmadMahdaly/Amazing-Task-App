import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:s/features/islamic_section/friday_sunan/data/models/sunnah_model.dart';
import 'package:s/features/islamic_section/friday_sunan/domain/entities/sunnah_entity.dart';

part 'friday_sunan_state.dart';

class FridaySunnahCubit extends Cubit<FridaySunnahState> {
  FridaySunnahCubit() : super(FridaySunnahInitial());
  List<SunnahEntity> data = [];

  Future<void> getSunanData() async {
    emit(FridaySunnahLoading());

    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/friday_sunnah.json',
      );

      final jsonList = json.decode(jsonString) as List<dynamic>;

      data = jsonList.map((item) {
        return SunnahModel.fromJson(item as Map<String, dynamic>);
      }).toList();
      emit(FridaySunnahLoaded(data));
    } catch (e) {
      emit(FridaySunnahError('حدث خطأ أثناء جلب البيانات: $e'));
    }
  }
}
