part of 'hisn_cubit.dart';

abstract class HisnState {}

class HisnInitial extends HisnState {}

class HisnLoading extends HisnState {}

class HisnLoaded extends HisnState {
  HisnLoaded(this.chapters);
  final List<HisnChapterEntity> chapters;
}

class HisnError extends HisnState {
  HisnError(this.message);
  final String message;
}
