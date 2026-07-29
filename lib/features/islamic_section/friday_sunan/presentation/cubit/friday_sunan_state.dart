part of 'friday_sunan_cubit.dart';

abstract class FridaySunnahState {}

class FridaySunnahInitial extends FridaySunnahState {}

class FridaySunnahLoading extends FridaySunnahState {}

class FridaySunnahLoaded extends FridaySunnahState {
  FridaySunnahLoaded(this.sunanList);
  final List<SunnahEntity> sunanList;
}

class FridaySunnahError extends FridaySunnahState {
  FridaySunnahError(this.message);
  final String message;
}
