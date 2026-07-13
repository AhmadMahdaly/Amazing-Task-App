part of 'azkar_cubit.dart';

abstract class AzkarState {}

class AzkarInitial extends AzkarState {}

class AzkarLoading extends AzkarState {}

class AzkarLoaded extends AzkarState {
  AzkarLoaded({required this.azkarCategory, required this.counters});
  final AzkarCategoryEntity azkarCategory;
  final Map<int, int> counters;
}

class AzkarError extends AzkarState {
  AzkarError(this.message);
  final String message;
}
