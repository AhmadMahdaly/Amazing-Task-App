// ignore_for_file: discarded_futures, omit_local_variable_types, prefer_int_literals

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/features/islamic_section/quran/presentation/controllers/audio_cubit/audio_cubit.dart';

class GlobalAudioPlayer extends StatelessWidget {
  const GlobalAudioPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioCubit, AudioState>(
      builder: (context, state) {
        if (state is AudioInitial || state is AudioError) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<AudioCubit>();

        return Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state is AudioPlaying || state is AudioPaused)
                StreamBuilder<Duration>(
                  stream: cubit.player.positionStream,
                  builder: (context, snapshot) {
                    final position = snapshot.data ?? Duration.zero;
                    final duration = cubit.player.duration ?? Duration.zero;

                    double progressValue = 0.0;
                    if (duration.inMilliseconds > 0) {
                      progressValue =
                          position.inMilliseconds / duration.inMilliseconds;
                    }

                    return SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: AppColors.buttonColor,
                        inactiveTrackColor: Colors.white.withAlpha(50),
                        thumbColor: AppColors.buttonColor,
                      ),
                      child: Slider(
                        value: progressValue.clamp(0.0, 1.0),
                        onChanged: (value) {
                          final newPosition = Duration(
                            milliseconds: (duration.inMilliseconds * value)
                                .round(),
                          );
                          cubit.seek(newPosition);
                        },
                      ),
                    );
                  },
                )
              else if (state is AudioDownloading)
                LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: Colors.white.withAlpha(50),
                  color: AppColors.buttonColor,
                  minHeight: 3,
                )
              else
                LinearProgressIndicator(
                  backgroundColor: Colors.white.withAlpha(50),
                  color: AppColors.buttonColor,
                  minHeight: 3,
                ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                        ),
                        onPressed: cubit.stop,
                      ),

                      const Spacer(),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'سورة رقم ${cubit.currentSurah}',
                            style: AppTextStyle.style14W800.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            cubit.currentReciter?.name ?? '',
                            style: AppTextStyle.style12W500.copyWith(
                              color: Colors.white.withAlpha(200),
                              fontFamily: AppFonts.amiri,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      if (state is AudioLoading || state is AudioDownloading)
                        const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      else if (state is AudioPlaying)
                        IconButton(
                          icon: const Icon(
                            Icons.pause_circle_filled,
                            size: 36,
                            color: Colors.white,
                          ),
                          onPressed: cubit.pause,
                        )
                      else if (state is AudioPaused)
                        IconButton(
                          icon: const Icon(
                            Icons.play_circle_filled,
                            size: 36,
                            color: Colors.white,
                          ),
                          onPressed: cubit.resume,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
