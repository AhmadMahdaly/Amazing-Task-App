part of 'anbyaa_cubit.dart';

sealed class AnbyaaState extends Equatable {
  const AnbyaaState();

  @override
  List<Object?> get props => [];
}

final class AnbyaaInitial extends AnbyaaState {}

final class AnbyaaLoading extends AnbyaaState {}

final class AnbyaaLoaded extends AnbyaaState {
  const AnbyaaLoaded({
    required this.anbyaa,
    this.lastReadAnbyaa,
  });
  final List<Anbyaa> anbyaa;
  final Anbyaa? lastReadAnbyaa;

  @override
  List<Object?> get props => [
    anbyaa,
    lastReadAnbyaa,
  ];
}

final class AnbyaaError extends AnbyaaState {
  const AnbyaaError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
