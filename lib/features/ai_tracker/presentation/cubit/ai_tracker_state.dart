part of 'ai_tracker_cubit.dart';

abstract class AiTrackerState {}

class AiTrackerInitial extends AiTrackerState {}

class AiTrackerLoaded extends AiTrackerState {
  AiTrackerLoaded(this.emails, this.availablePlatforms);
  final List<EmailAccountEntity> emails;
  final List<AiPlatformEntity> availablePlatforms;
}
