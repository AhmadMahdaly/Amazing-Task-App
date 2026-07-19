part of 'tafsir_cubit.dart';

abstract class TafsirState {}

class TafsirInitial extends TafsirState {}

class TafsirLoading extends TafsirState {}

class TafsirLoaded extends TafsirState {
  TafsirLoaded(this.tafsirBySura, this.lastReadSurahNumber);

  final Map<int, List<TafsirEntity>> tafsirBySura;
  final int? lastReadSurahNumber;
}

class TafsirError extends TafsirState {
  TafsirError(this.message);
  final String message;
}
