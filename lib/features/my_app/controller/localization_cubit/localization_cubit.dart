import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '/../core/cache_helper/cache_helper.dart';
import '/./core/cache_helper/cache_values.dart';

part 'localization_state.dart';

class LocalizationCubit extends Cubit<LocalizationState> {
  LocalizationCubit()
    : super(
        LocalizationState(
          locale: Locale(
            CacheHelper.getData(CacheKeys.currentLanguage)?.toString() ?? 'en',
          ),
        ),
      );

  Future<void> changeLanguage(Locale locale) async {
    await CacheHelper.saveData(
      key: CacheKeys.currentLanguage,
      value: locale.languageCode,
    );
    emit(LocalizationState(locale: locale));
  }
}
