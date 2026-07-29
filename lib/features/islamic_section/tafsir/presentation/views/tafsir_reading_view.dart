// ignore_for_file: use_string_buffers, discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/islamic_section/quran/domain/entities/surah_entity.dart';
import 'package:s/features/islamic_section/quran/presentation/controllers/quran_cubit/quran_cubit.dart';
import 'package:s/features/islamic_section/tafsir/data/models/tafsir_model.dart';
import 'package:s/features/islamic_section/tafsir/domain/entities/tafsir_entity.dart';
import 'package:s/features/islamic_section/tafsir/presentation/cubit/tafsir_cubit.dart';

class TafsirReadingView extends StatefulWidget {
  const TafsirReadingView({required this.surah, super.key});
  final SurahEntity surah;

  @override
  State<TafsirReadingView> createState() => _TafsirReadingViewState();
}

class _TafsirReadingViewState extends State<TafsirReadingView> {
  late final TafsirCubit _tafsirCubit;

  late List<String> surahAyahs;
  late List<TafsirEntity> tafsirList;
  List<GroupedAyaTafsir> groupedTafsirList = [];
  double _fontSize = 28;
  int _screenOpacity = 205;
  Color _textColor = Colors.white;
  double _readingProgress = 0;
  final List<Color> colors = [
    Colors.white,
    Colors.black,
    const Color(0xffF5E6C8),
    Colors.amber.shade100,
    Colors.green.shade100,
    Colors.brown.shade100,
  ];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tafsirCubit = context.read<TafsirCubit>();
    surahAyahs = context.read<QuranCubit>().getAyahsForSurah(
      widget.surah.number,
    );
    tafsirList = _tafsirCubit.getTafsirForSurah(
      widget.surah.number,
    );
    _groupTafsirData();
    _fontSize =
        (CacheHelper.getData(CacheKeys.tafsirFontSize) as num?)?.toDouble() ??
        24;
    _screenOpacity =
        (CacheHelper.getData(CacheKeys.tafsirScreenOpacity) as num?)?.toInt() ??
        205;

    final colorValue = CacheHelper.getData(CacheKeys.tafsirTextColor) as int?;
    if (colorValue != null) {
      _textColor = Color(colorValue);
    }

    final offset =
        (CacheHelper.getData('tafsir_lesson_${widget.surah.number}_offset')
                as num?)
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
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    _tafsirCubit.saveLastRead(widget.surah.number);

    super.dispose();
  }

  void _groupTafsirData() {
    if (surahAyahs.isEmpty || tafsirList.isEmpty) return;

    final count = surahAyahs.length < tafsirList.length
        ? surahAyahs.length
        : tafsirList.length;

    var currentAyahs = <String>[surahAyahs[0]];
    var currentAyahNums = <int>[1];
    var currentTafsir = tafsirList[0].tafsirText;

    for (var i = 1; i < count; i++) {
      final tafsir = tafsirList[i].tafsirText;

      if (tafsir == currentTafsir) {
        currentAyahs.add(surahAyahs[i]);
        currentAyahNums.add(i + 1);
      } else {
        groupedTafsirList.add(
          GroupedAyaTafsir(
            ayahs: currentAyahs,
            ayahNumbers: currentAyahNums,
            tafsir: currentTafsir,
          ),
        );

        currentAyahs = [surahAyahs[i]];
        currentAyahNums = [i + 1];
        currentTafsir = tafsir;
      }
    }

    groupedTafsirList.add(
      GroupedAyaTafsir(
        ayahs: currentAyahs,
        ayahNumbers: currentAyahNums,
        tafsir: currentTafsir,
      ),
    );
  }

  void _saveOffset() {
    CacheHelper.saveData(
      key: 'tafsir_lesson_${widget.surah.number}_offset',
      value: _scrollController.offset,
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

  void _updateFontSize(
    double value,
    void Function(void Function()) setModalState,
  ) {
    setState(() {
      _fontSize = value.clamp(18, 48);
    });

    setModalState(() {});

    CacheHelper.saveData(
      key: CacheKeys.tafsirFontSize,
      value: _fontSize,
    );
  }

  String _cleanHtmlTags(String htmlString) {
    final exp = RegExp('<[^>]*>', multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').trim();
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

  Widget _buildTafsirText(String text) {
    final spans = <InlineSpan>[];

    final exp = RegExp(r'(\{.*?\})|(\[.*?\])');
    var lastMatchEnd = 0;

    for (final match in exp.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style: AppTextStyle.style16W500.copyWith(
              fontFamily: AppFonts.amiri,
              color: _textColor,
              height: 1.8,
            ),
          ),
        );
      }

      final matchedString = match.group(0)!;

      if (matchedString.startsWith('{') && matchedString.endsWith('}')) {
        spans.add(
          TextSpan(
            text:
                ' ﴿${matchedString.substring(1, matchedString.length - 1).trim()}﴾ ',
            style: AppTextStyle.style16Bold.copyWith(
              fontFamily: AppFonts.quran,
              fontSize: _fontSize.sp,
              color: _textColor,
              height: 1.8,
            ),
          ),
        );
      } else if (matchedString.startsWith('[') && matchedString.endsWith(']')) {
        spans.add(
          TextSpan(
            text:
                ' ${matchedString.substring(1, matchedString.length - 1).trim()} ',
            style: AppTextStyle.style14W800.copyWith(
              fontFamily: AppFonts.amiri,
              fontSize: _fontSize.sp,
              color: _textColor,
              height: 1.8,
            ),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style: AppTextStyle.style16W700.copyWith(
            fontFamily: AppFonts.amiri,
            fontSize: (_fontSize - 4).sp,
            color: _textColor,
            height: 1.8,
          ),
        ),
      );
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'تفسير سورة ${widget.surah.name}',
                style: AppTextStyle.style20W900.copyWith(
                  fontFamily: AppFonts.amiri,
                ),
              ),
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
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
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'لون الخط',
                                    style: AppTextStyle.style14W500,
                                  ),
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
                                            key: CacheKeys.tafsirTextColor,
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

                                  Text(
                                    'حجم الخط',
                                    style: AppTextStyle.style14W500,
                                  ),
                                  8.verticalSpace,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          _updateFontSize(
                                            _fontSize - 2,
                                            setModalState,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: AppColors.primaryColor
                                              .withAlpha(100),
                                        ),
                                      ),

                                      Expanded(
                                        child: Slider(
                                          activeColor: AppColors.primaryColor,
                                          value: _fontSize,
                                          min: 18,
                                          max: 48,
                                          divisions: 15,
                                          label: _fontSize.toString(),
                                          onChanged: (value) {
                                            setState(() {
                                              _fontSize = value;
                                            });
                                            setModalState(() {});
                                          },
                                          onChangeEnd: (value) {
                                            _updateFontSize(
                                              value,
                                              setModalState,
                                            );
                                          },
                                        ),
                                      ),

                                      IconButton(
                                        onPressed: () {
                                          _updateFontSize(
                                            _fontSize + 2,
                                            setModalState,
                                          );
                                        },
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          color: AppColors.primaryColor
                                              .withAlpha(100),
                                        ),
                                      ),
                                    ],
                                  ),
                                  10.verticalSpace,
                                  Text(
                                    'شفافية الشاشة',
                                    style: AppTextStyle.style14W500,
                                  ),
                                  8.verticalSpace,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (_screenOpacity > 35) {
                                            setState(
                                              () => _screenOpacity -= 20,
                                            );
                                            setModalState(() {});
                                            CacheHelper.saveData(
                                              key:
                                                  CacheKeys.tafsirScreenOpacity,
                                              value: _screenOpacity,
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.remove_circle_outline,
                                          color: AppColors.primaryColor
                                              .withAlpha(100),
                                        ),
                                      ),
                                      Slider(
                                        activeColor: AppColors.primaryColor,
                                        value: _screenOpacity
                                            .clamp(35, 255)
                                            .toDouble(),
                                        min: 35,
                                        max: 255,
                                        divisions: 10,
                                        label: _screenOpacity.toString(),
                                        onChanged: (value) {
                                          setState(
                                            () =>
                                                _screenOpacity = value.toInt(),
                                          );
                                          setModalState(() {});
                                        },
                                        onChangeEnd: (value) {
                                          CacheHelper.saveData(
                                            key: CacheKeys.tafsirScreenOpacity,
                                            value: value,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          if (_screenOpacity <= 235) {
                                            setState(
                                              () => _screenOpacity += 20,
                                            );
                                            setModalState(() {});
                                            CacheHelper.saveData(
                                              key:
                                                  CacheKeys.tafsirScreenOpacity,
                                              value: _screenOpacity,
                                            );
                                          }
                                        },
                                        icon: Icon(
                                          Icons.add_circle_outline,
                                          color: AppColors.primaryColor
                                              .withAlpha(100),
                                        ),
                                      ),
                                    ],
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
                                        _screenOpacity = 205;
                                        _textColor = Colors.white;
                                      });

                                      setModalState(() {});

                                      CacheHelper.saveData(
                                        key: CacheKeys.tafsirFontSize,
                                        value: 28,
                                      );

                                      CacheHelper.saveData(
                                        key: CacheKeys.tafsirScreenOpacity,
                                        value: 205,
                                      );

                                      CacheHelper.saveData(
                                        key: CacheKeys.tafsirTextColor,
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
                child: (surahAyahs.isEmpty || tafsirList.isEmpty)
                    ? Center(
                        child: Text(
                          'التفسير غير متوفر لهذه السورة حالياً',
                          style: AppTextStyle.style16W500.copyWith(
                            color: AppColors.errorColor,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.r),
                        itemCount: groupedTafsirList.length,
                        separatorBuilder: (context, index) => 24.verticalSpace,
                        itemBuilder: (context, index) {
                          final group = groupedTafsirList[index];

                          final cleanTafsirText = _cleanHtmlTags(
                            group.tafsir,
                          );

                          var combinedAyahs = '';
                          for (var i = 0; i < group.ayahs.length; i++) {
                            final ayaNum = _convertToArabicNumber(
                              group.ayahNumbers[i],
                            );
                            combinedAyahs += '${group.ayahs[i]} $ayaNum ';
                          }

                          return Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: AppColors.buttonColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: AppColors.buttonColor.withAlpha(30),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  combinedAyahs.trim(),
                                  style: AppTextStyle.style20W900.copyWith(
                                    fontFamily: AppFonts.quran,
                                    color: _textColor,
                                    height: 1.8,
                                    fontSize: _fontSize,
                                  ),
                                  textAlign: TextAlign.justify,
                                ),
                                Divider(
                                  color: AppColors.buttonColor.withAlpha(30),
                                ),
                                _buildTafsirText(cleanTafsirText),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
