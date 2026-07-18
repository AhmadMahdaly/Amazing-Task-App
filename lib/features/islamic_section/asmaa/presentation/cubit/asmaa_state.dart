part of 'asmaa_cubit.dart';

abstract class AsmaaState {}

class AsmaaInitial extends AsmaaState {}

class AsmaaLoading extends AsmaaState {}

class AsmaaLoaded extends AsmaaState {
  // تمت الإضافة

  AsmaaLoaded(this.lessons, {this.lastReadLessonId});
  final List<AsmaaLesson> lessons;
  final int? lastReadLessonId;
}

class AsmaaError extends AsmaaState {
  AsmaaError(this.message);
  final String message;
}
