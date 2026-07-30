// ignore_for_file: unawaited_futures, discarded_futures

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/islamic_section/quran/data/models/reciter_model.dart';
import 'package:s/features/islamic_section/quran/presentation/controllers/audio_cubit/audio_cubit.dart';
import 'package:s/features/islamic_section/quran/presentation/views/surah_reading_view.dart';

class ReciterTileWidget extends StatelessWidget {
  const ReciterTileWidget({
    required this.widget,
    required this.context,
    required this.cubit,
    required this.reciter,
    required this.isDownloaded,
    super.key,
    this.onDeleted,
  });

  final SurahReadingView widget;
  final BuildContext context;
  final AudioCubit cubit;
  final ReciterModel reciter;
  final bool isDownloaded;
  final VoidCallback? onDeleted;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryColor.withAlpha(20),
        ),
        child: Center(
          child: Text(
            reciter.name.characters.first,
            style: AppTextStyle.style14W500.copyWith(
              color: AppColors.primaryColor,
              fontFamily: AppFonts.amiri,
            ),
          ),
        ),
      ),
      title: Text(
        reciter.name,
        style: AppTextStyle.style16W800.copyWith(
          fontFamily: AppFonts.amiri,
        ),
      ),
      trailing: Icon(
        isDownloaded ? Icons.play_circle_filled : Icons.cloud_download_outlined,
        color: AppColors.primaryColor,
      ),
      onLongPress: isDownloaded
          ? () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    title: Text(
                      'حذف الملف الصوتي',
                      style: AppTextStyle.style18W900.copyWith(
                        fontFamily: AppFonts.amiri,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    content: Text(
                      'هل أنت متأكد من حذف سورة ${widget.surah.name} بصوت ${reciter.name}؟',
                      style: AppTextStyle.style14W500.copyWith(
                        fontFamily: AppFonts.amiri,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'إلغاء',
                          style: AppTextStyle.style14W500.copyWith(
                            color: Colors.grey,
                            fontFamily: AppFonts.amiri,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'حذف',
                          style: AppTextStyle.style14W500.copyWith(
                            color: AppColors.errorColor,
                            fontFamily: AppFonts.amiri,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );

              if (confirm == true) {
                final dir = await getApplicationDocumentsDirectory();
                final surahPadded = widget.surah.number.toString().padLeft(
                  3,
                  '0',
                );
                final filePath =
                    '${dir.path}/quran_audio/${reciter.id}/$surahPadded.mp3';
                final file = File(filePath);

                if (file.existsSync()) {
                  await file.delete();

                  if (cubit.currentReciter?.id == reciter.id &&
                      cubit.currentSurah == widget.surah.number) {
                    cubit.stop();
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم حذف الملف الصوتي بنجاح'),
                        backgroundColor: AppColors.primaryColor,
                      ),
                    );

                    if (onDeleted != null) onDeleted?.call();
                  }
                }
              }
            }
          : null,
      onTap: () {
        Navigator.pop(context);
        cubit.playSurah(reciter, widget.surah.number, widget.surah.name);
      },
    );
  }
}
