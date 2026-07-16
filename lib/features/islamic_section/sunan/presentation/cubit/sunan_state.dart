part of 'sunan_cubit.dart';

abstract class SunanState {}

class SunanInitial extends SunanState {}

class SunanLoading extends SunanState {}

class SunanLoaded extends SunanState {
  SunanLoaded(this.sunanData);
  final SunanDataEntity sunanData;
}

class SunanError extends SunanState {
  SunanError(this.message);
  final String message;
}
