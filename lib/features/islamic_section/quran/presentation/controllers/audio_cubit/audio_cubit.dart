// ignore_for_file: unawaited_futures, discarded_futures, avoid_slow_async_io

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s/features/islamic_section/quran/data/models/reciter_model.dart';

part 'audio_state.dart';

class AudioCubit extends Cubit<AudioState> {
  AudioCubit() : super(AudioInitial()) {
    _initPlayerListener();
  }

  List<ReciterModel> allReciters = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  StreamSubscription? _playerStateSubscription;

  ReciterModel? currentReciter;
  int? currentSurah;
  String? currentSurahName;
  void _initPlayerListener() {
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((
      playerState,
    ) {
      if (currentSurah == null || state is AudioInitial) {
        return;
      }

      if (playerState.processingState == ProcessingState.completed) {
        _audioPlayer
          ..pause()
          ..seek(Duration.zero);
        emit(AudioPaused());
      } else if (playerState.playing) {
        emit(AudioPlaying());
      } else {
        if (state is! AudioLoading && state is! AudioDownloading) {
          emit(AudioPaused());
        }
      }
    });
  }

  Future<void> loadReciters() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/reciters.json',
      );
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final recitersJsonList = jsonMap['reciters'] as List<dynamic>;

      allReciters = recitersJsonList
          .map((e) => ReciterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      emit(AudioError('حدث خطأ أثناء تحميل قائمة القراء'));
    }
  }

  Future<void> playSurah(
    ReciterModel reciter,
    int surahNumber,
    String surahName,
  ) async {
    currentReciter = reciter;
    currentSurah = surahNumber;
    currentSurahName = surahName;
    try {
      emit(AudioLoading());

      final dir = await getApplicationDocumentsDirectory();
      final surahPadded = surahNumber.toString().padLeft(3, '0');
      final filePath = '${dir.path}/quran_audio/${reciter.id}/$surahPadded.mp3';
      final audioFile = File(filePath);

      if (await audioFile.exists()) {
        await _setupAndPlay(audioFile.path);
        return;
      }

      await audioFile.parent.create(recursive: true);
      final url = '${reciter.server}$surahPadded.mp3';

      await Dio().download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            emit(AudioDownloading(received / total));
          }
        },
      );

      await _setupAndPlay(audioFile.path);
    } catch (e) {
      emit(
        AudioError(
          'حدث خطأ أثناء التحميل. تأكد من اتصالك بالإنترنت وحاول مجدداً.',
        ),
      );
    }
  }

  AudioPlayer get player => _audioPlayer;

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> _setupAndPlay(String filePath) async {
    try {
      final mediaItem = MediaItem(
        id: currentSurah.toString(),
        album: currentReciter?.name ?? 'القرآن الكريم',
        title: 'سورة $currentSurahName',
        // artUri: Uri.parse('https://example.com/image.jpg'),
      );

      final audioSource = AudioSource.uri(
        Uri.parse(filePath),
        tag: mediaItem,
      );

      await _audioPlayer.setAudioSource(audioSource);
      _audioPlayer.play();
    } catch (e) {
      emit(AudioError('لا يمكن تشغيل الملف الصوتي.'));
    }
  }

  void pause() => _audioPlayer.pause();
  void resume() => _audioPlayer.play();

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _audioPlayer.dispose();
    return super.close();
  }

  Future<void> stop() async {
    emit(AudioInitial());
    currentSurah = null;
    await _audioPlayer.stop();
  }
}
