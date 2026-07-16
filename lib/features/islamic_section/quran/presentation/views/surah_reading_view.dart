// ignore_for_file: cascade_invocations, discarded_futures

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
import 'package:s/core/routing/app_routes.dart';
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
  int _screenOpacity = 200;
  Color _textColor = Colors.white;
  final List<Color> colors = [
    Colors.white,
    Colors.black,
    const Color(0xffF5E6C8),
    Colors.amber.shade100,
    Colors.green.shade100,
    Colors.brown.shade100,
  ];
  late List<String> surahAyahs;
  late QuranCubit _quranCubit;
  double _readingProgress = 0;
  @override
  void initState() {
    super.initState();
    _quranCubit = context.read<QuranCubit>();
    surahAyahs = _quranCubit.getAyahsForSurah(widget.surah.number);
    _fontSize =
        (CacheHelper.getData(CacheKeys.quranFontSize) as num?)?.toDouble() ??
        28;
    _screenOpacity =
        (CacheHelper.getData(CacheKeys.screenOpacity) as num?)?.toInt() ?? 200;
    final colorValue = CacheHelper.getData(CacheKeys.quranTextColor) as int?;

    if (colorValue != null) {
      _textColor = Color(colorValue);
    }
    final offset =
        (CacheHelper.getData('surah_${widget.surah.number}_offset') as num?)
            ?.toDouble() ??
        0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;

        _scrollController.jumpTo(
          offset.clamp(0.0, max),
        );
      }
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_saveOffset);
    _scrollController.dispose();
    _quranCubit.saveLastRead(widget.surah.number);

    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();
  String _convertToArabicNumber(int number) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var numStr = number.toString();
    for (var i = 0; i < english.length; i++) {
      numStr = numStr.replaceAll(english[i], arabic[i]);
    }
    return numStr;
  }

  void _saveOffset() {
    CacheHelper.saveData(
      key: 'surah_${widget.surah.number}_offset',
      value: _scrollController.offset,
    );
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

  void _goToNextSurah() {
    final nextSurah = _quranCubit.allSurahs[widget.surah.number];

    context.pushReplacement(
      AppRoutes.surahReadingView,
      extra: nextSurah,
    );
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;

    if (max == 0) return;

    setState(() {
      _readingProgress = (_scrollController.offset / max).clamp(0.0, 1.0);
    });

    _saveOffset();
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
                  color: _textColor,
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
                    Icons.tune,
                    color: AppColors.buttonColor.withAlpha(150),
                    size: 24.r,
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
                                    activeColor: AppColors.primaryColor,

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
                                  10.verticalSpace,
                                  const Text('لون الخط'),
                                  8.verticalSpace,
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: colors.map((color) {
                                      final selected = _textColor == color;

                                      return InkWell(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        onTap: () {
                                          setState(() => _textColor = color);
                                          setModalState(() {});

                                          CacheHelper.saveData(
                                            key: CacheKeys.quranTextColor,
                                            value: color.toARGB32(),
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: selected ? 22 : 18,
                                          backgroundColor: color,
                                          child: selected
                                              ? const Icon(
                                                  Icons.check,
                                                  color: Colors.black,
                                                )
                                              : null,
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  10.verticalSpace,
                                  const Text('شفافية الشاشة'),
                                  Slider(
                                    activeColor: AppColors.primaryColor,
                                    value: _screenOpacity.toDouble(),
                                    min: 50,
                                    max: 255,
                                    divisions: 20,
                                    label: _screenOpacity
                                        .toDouble()
                                        .round()
                                        .toString(),
                                    onChanged: (value) {
                                      setState(
                                        () => _screenOpacity = value.toInt(),
                                      );
                                      setModalState(() {});
                                    },
                                    onChangeEnd: (value) {
                                      CacheHelper.saveData(
                                        key: CacheKeys.screenOpacity,
                                        value: value,
                                      );
                                    },
                                  ),
                                  10.verticalSpace,
                                  FilledButton.icon(
                                    style: const ButtonStyle(
                                      backgroundColor: WidgetStatePropertyAll(
                                        AppColors.primaryColor,
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _fontSize = 28;
                                        _screenOpacity = 200;
                                        _textColor = Colors.white;
                                      });

                                      setModalState(() {});

                                      CacheHelper.saveData(
                                        key: CacheKeys.quranFontSize,
                                        value: 28,
                                      );

                                      CacheHelper.saveData(
                                        key: CacheKeys.screenOpacity,
                                        value: 200,
                                      );

                                      CacheHelper.saveData(
                                        key: CacheKeys.quranTextColor,
                                        value: Colors.white.toARGB32(),
                                      );
                                    },
                                    icon: const Icon(Icons.restart_alt),
                                    label: const Text('إعادة الضبط'),
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
                InkWell(
                  borderRadius: BorderRadius.circular(320),
                  child: SizedBox(
                    width: 24.w,
                    height: 24.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: _readingProgress,
                          strokeWidth: 1,
                          backgroundColor: AppColors.buttonColor.withAlpha(20),
                          color: AppColors.buttonColor.withAlpha(150),
                        ),
                        Text(
                          '${(_readingProgress * 100).round()}',
                          style: AppTextStyle.style9W700.copyWith(
                            color: AppColors.buttonColor.withAlpha(150),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onTap: () async {
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
                                  const Text('مستوى التقدم'),
                                  Slider(
                                    activeColor: AppColors.primaryColor,
                                    value: _readingProgress,
                                    onChanged: (value) {
                                      setModalState(() {
                                        _readingProgress = value;
                                      });

                                      final max = _scrollController
                                          .position
                                          .maxScrollExtent;

                                      _scrollController.animateTo(
                                        value * max,
                                        duration: const Duration(
                                          milliseconds: 150,
                                        ),
                                        curve: Curves.easeOut,
                                      );
                                    },
                                  ),
                                  10.verticalSpace,
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),

                20.horizontalSpace,
              ],
            ),
            resizeToAvoidBottomInset: false,
            backgroundColor: wallpaperState.settings.hasWallpaper
                ? Colors.transparent
                : AppColors.primaryColor,

            body: AppWallpaper(
              settings: wallpaperState.settings,
              child: ColoredBox(
                color: AppColors.primaryColor.withAlpha(_screenOpacity),
                child: surahAyahs.isEmpty
                    ? const Center(child: LoadingWidget())
                    : SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            if (widget.surah.number != 9) ...[
                              Text(
                                'بِسمِ اللَّهِ الرَّحمـٰنِ الرَّحيمِ ',
                                style: AppTextStyle.style20Bold.copyWith(
                                  fontFamily: AppFonts.quran,
                                  color: _textColor,
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
                                        recognizer: LongPressGestureRecognizer()
                                          ..onLongPress = () =>
                                              _openTafsir(index + 1),
                                        style: AppTextStyle.style20W900
                                            .copyWith(
                                              fontFamily: AppFonts.quran,
                                              color: _textColor,
                                              height: 1.8,
                                              fontSize: _fontSize.sp,
                                            ),
                                      ),

                                      // TextSpan(
                                      //   text: '$ayahText ',
                                      //   style: AppTextStyle.style20W900
                                      //       .copyWith(
                                      //         fontFamily: AppFonts.quran,
                                      //         color: _textColor,
                                      //         height: 1.8,
                                      //         fontSize: _fontSize.sp,
                                      //       ),
                                      // ),
                                      TextSpan(
                                        text: ' $ayahNumber ',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () =>
                                              _openTafsir(index + 1),
                                        style: AppTextStyle.style20W900
                                            .copyWith(
                                              fontFamily: AppFonts.quran,
                                              color: _textColor,
                                              height: 1.8,
                                              fontSize: _fontSize.sp,
                                            ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                            if (widget.surah.number <
                                _quranCubit.allSurahs.length) ...[
                              40.verticalSpace,
                              // const Divider(),
                              // 20.verticalSpace,
                              FilledButton.icon(
                                style: const ButtonStyle(
                                  iconAlignment: IconAlignment.end,
                                  backgroundColor: WidgetStatePropertyAll(
                                    AppColors.transparent,
                                  ),
                                ),
                                onPressed: _goToNextSurah,
                                icon: Icon(
                                  Icons.arrow_forward,
                                  size: 12.r,
                                  color: _textColor.withAlpha(200),
                                ),
                                label: Text(
                                  'الانتقال إلى سورة ${_quranCubit.allSurahs[widget.surah.number].name}',
                                  style: AppTextStyle.style12W700.copyWith(
                                    fontFamily: AppFonts.amiri,
                                    color: _textColor.withAlpha(200),
                                  ),
                                ),
                              ),
                              40.verticalSpace,
                            ],
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
                        fontSize: (_fontSize - 2).sp,
                      ),
                    ),
                    20.verticalSpace,
                    Text(
                      tafsir,
                      style: AppTextStyle.style18W800.copyWith(
                        height: 1.9,
                        fontFamily: AppFonts.amiri,
                        color: AppColors.primaryColor.withAlpha(210),
                        fontSize: (_fontSize - 2).sp,
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
