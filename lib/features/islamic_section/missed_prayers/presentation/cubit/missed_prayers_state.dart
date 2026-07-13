part of 'missed_prayers_cubit.dart';

abstract class MissedPrayersState {}

class MissedPrayersInitial extends MissedPrayersState {}

class MissedPrayersLoading extends MissedPrayersState {}

class MissedPrayersLoaded extends MissedPrayersState {
  MissedPrayersLoaded(this.prayersData);
  final MissedPrayersEntity prayersData;
}

class MissedPrayersError extends MissedPrayersState {
  MissedPrayersError(this.message);
  final String message;
}
