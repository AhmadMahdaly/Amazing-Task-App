part of 'tabeen_cubit.dart';

sealed class TabeenState extends Equatable {
  const TabeenState();

  @override
  List<Object?> get props => [];
}

final class TabeenInitial extends TabeenState {}

final class TabeenLoading extends TabeenState {}

final class TabeenLoaded extends TabeenState {
  const TabeenLoaded({
    required this.tabeen,
    this.lastReadTabeen,
  });
  final List<Tabeen> tabeen;
  final Tabeen? lastReadTabeen;

  @override
  List<Object?> get props => [
    tabeen,
    lastReadTabeen,
  ];
}

final class TabeenError extends TabeenState {
  const TabeenError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
