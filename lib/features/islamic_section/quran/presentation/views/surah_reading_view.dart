// ignore_for_file: discarded_futures

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/islamic_section/quran/domain/entities/surah_entity.dart';
import 'package:s/features/islamic_section/quran/presentation/cubit/quran_cubit.dart';

class SurahReadingView extends StatefulWidget {
  const SurahReadingView({required this.surah, super.key});
  final SurahEntity surah;

  @override
  State<SurahReadingView> createState() => _SurahReadingViewState();
}

class _SurahReadingViewState extends State<SurahReadingView> {
  double _fontSize = 28;
  late List<String> surahAyahs;

  late QuranCubit _quranCubit;

  @override
  void initState() {
    super.initState();

    _quranCubit = context.read<QuranCubit>();

    surahAyahs = _quranCubit.getAyahsForSurah(widget.surah.number);
    _fontSize =
        (CacheHelper.getData(CacheKeys.quranFontSize) as num?)?.toDouble() ??
        28;
  }

  @override
  void dispose() {
    _quranCubit.saveLastRead(widget.surah.number);

    super.dispose();
  }

  String _convertToArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var numStr = number.toString();
    for (var i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], arabic[i]);
    }
    return numStr;
  }

  void _openTafsir(int ayah) {
    final tafsir = _quranCubit.getTafsir(
      surah: widget.surah.number,
      ayah: ayah,
    );

    if (tafsir != null) {
      _showTafsirBottomSheet(tafsir.text, ayah);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              toolbarHeight: 70.h,
              title: Text(
                'سورة ${widget.surah.name}',
                style: AppTextStyle.style20Bold.copyWith(
                  fontFamily: AppFonts.quran,
                ),
              ),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.text_fields,
                    color: AppColors.buttonColor.withAlpha(150),
                    size: 20.r,
                  ),
                  onPressed: () async {
                    await showModalBottomSheet<void>(
                      context: context,
                      builder: (_) {
                        return StatefulBuilder(
                          builder: (context, setModalState) {
                            return Padding(
                              padding: EdgeInsets.all(16.r),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('حجم الخط'),
                                  Slider(
                                    value: _fontSize,
                                    min: 18,
                                    max: 48,
                                    divisions: 15,
                                    label: _fontSize.round().toString(),
                                    onChanged: (value) {
                                      setState(() => _fontSize = value);
                                      setModalState(() {});
                                    },
                                    onChangeEnd: (value) {
                                      CacheHelper.saveData(
                                        key: CacheKeys.quranFontSize,
                                        value: value,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                8.horizontalSpace,
              ],
            ),
            resizeToAvoidBottomInset: false,
            backgroundColor: wallpaperState.settings.hasWallpaper
                ? Colors.transparent
                : AppColors.primaryColor,

            body: AppWallpaper(
              settings: wallpaperState.settings,
              child: ColoredBox(
                color: AppColors.secondaryColor,
                child: surahAyahs.isEmpty
                    ? const Center(child: LoadingWidget())
                    : SingleChildScrollView(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            if (widget.surah.number != 9) ...[
                              Text(
                                'بِسمِ اللَّهِ الرَّحمـٰنِ الرَّحيمِ ',
                                style: AppTextStyle.style20Bold.copyWith(
                                  fontFamily: AppFonts.quran,
                                  color: AppColors.buttonColor,
                                  fontSize: _fontSize.sp,
                                ),
                              ),
                              24.verticalSpace,
                            ],

                            RichText(
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                              text: TextSpan(
                                children: surahAyahs.asMap().entries.map((
                                  entry,
                                ) {
                                  final index = entry.key;
                                  var ayahText = entry.value;
                                  final ayahNumber = _convertToArabicNumber(
                                    index + 1,
                                  );

                                  if (widget.surah.number != 9 && index == 0) {
                                    ayahText = ayahText.replaceFirst(
                                      'بِسمِ اللَّهِ الرَّحمـٰنِ الرَّحيمِ',
                                      '',
                                    );
                                  }
                                  return TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '$ayahText ',
                                        style: AppTextStyle.style20W900
                                            .copyWith(
                                              fontFamily: AppFonts.quran,
                                              color: AppColors.white,
                                              height: 1.8,
                                              fontSize: _fontSize.sp,
                                            ),
                                      ),
                                      TextSpan(
                                        text: ' $ayahNumber ',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () =>
                                              _openTafsir(index + 1),
                                        style: AppTextStyle.style20W900
                                            .copyWith(
                                              fontFamily: AppFonts.quran,
                                              color: AppColors.white,
                                              height: 1.8,
                                              fontSize: _fontSize.sp,
                                            ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showTafsirBottomSheet(
    String tafsir,
    int ayah,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفسير الآية $ayah',
                      style: AppTextStyle.style20Bold.copyWith(
                        fontFamily: AppFonts.amiri,
                        fontSize: _fontSize - 2.sp,
                      ),
                    ),
                    20.verticalSpace,
                    Text(
                      tafsir,
                      style: AppTextStyle.style18W800.copyWith(
                        height: 1.9,
                        fontFamily: AppFonts.amiri,
                        fontSize: _fontSize - 4.sp,
                      ),
                    ),
                    24.verticalSpace,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
