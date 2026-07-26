part of 'quran_cubit.dart';

enum QuranIndexType {
  surahs,
  juz,
  hizb,
}

abstract class QuranState {}

class QuranInitial extends QuranState {}

class QuranLoading extends QuranState {}

class QuranLoaded extends QuranState {
  QuranLoaded({required this.surahs, this.lastReadSurahNumber});
  final List<SurahEntity> surahs;
  final int? lastReadSurahNumber;
}

class QuranError extends QuranState {
  QuranError(this.message);
  final String message;
}
