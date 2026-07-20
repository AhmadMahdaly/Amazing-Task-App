part of 'arbaoon_cubit.dart';

sealed class ArbaoonState extends Equatable {
  const ArbaoonState();

  @override
  List<Object?> get props => [];
}

final class ArbaoonInitial extends ArbaoonState {}

final class ArbaoonLoading extends ArbaoonState {}

final class ArbaoonLoaded extends ArbaoonState {
  const ArbaoonLoaded({
    required this.hadiths,
    this.lastReadHadith,
  });
  final List<Hadith> hadiths;
  final Hadith? lastReadHadith;

  @override
  List<Object?> get props => [
    hadiths,
    lastReadHadith,
  ];
}

final class ArbaoonError extends ArbaoonState {
  const ArbaoonError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
