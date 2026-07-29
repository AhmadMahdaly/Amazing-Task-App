part of 'audio_cubit.dart';

abstract class AudioState {}

class AudioInitial extends AudioState {}

class AudioLoading extends AudioState {}

class AudioDownloading extends AudioState {
  AudioDownloading(this.progress);
  final double progress;
}

class AudioPlaying extends AudioState {}

class AudioPaused extends AudioState {}

class AudioError extends AudioState {
  AudioError(this.message);
  final String message;
}
