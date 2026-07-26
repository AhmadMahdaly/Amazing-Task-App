// ignore_for_file: discarded_futures

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/core/di.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/islamic_section/notes/data/data_sources/notes_data_source.dart';
import 'package:s/features/islamic_section/quran/domain/entities/saved_ayah_note_entity.dart';
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
  int _screenOpacity = 205;
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
        (CacheHelper.getData(CacheKeys.quranScreenOpacity) as num?)?.toInt() ??
        200;
    final colorValue = CacheHelper.getData(CacheKeys.quranTextColor) as int?;
    if (colorValue != null) {
      _textColor = Color(colorValue);
    }

    final isFromBookmark =
        CacheHelper.getData(CacheKeys.isFromBookmark) as bool? ?? false;
    CacheHelper.removeData(CacheKeys.isFromBookmark);

    double offset = 0;
    if (isFromBookmark) {
      offset =
          (CacheHelper.getData(CacheKeys.bookmarkedOffset) as num?)
              ?.toDouble() ??
          0;
    } else {
      offset =
          (CacheHelper.getData('surah_${widget.surah.number}_offset') as num?)
              ?.toDouble() ??
          0;
    }

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

  void _saveBookmark(int ayah) {
    CacheHelper.saveData(
      key: CacheKeys.bookmarkedSurah,
      value: widget.surah.number,
    );
    CacheHelper.saveData(key: CacheKeys.bookmarkedAyah, value: ayah);

    CacheHelper.saveData(
      key: CacheKeys.bookmarkedOffset,
      value: _scrollController.offset,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حفظ الموضع عند الآية $ayah بنجاح'),
        backgroundColor: AppColors.primaryColor,
      ),
    );
  }

  void _showAyahOptions(int ayah, String ayahText) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.menu_book,
                    color: AppColors.primaryColor,
                  ),
                  title: Text(
                    'عرض تفسير الآية',
                    style: AppTextStyle.style18W900.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _openTafsir(ayah);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.bookmark_add,
                    color: AppColors.primaryColor,
                  ),
                  title: Text(
                    'علامة مرجعية',
                    style: AppTextStyle.style18W900.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _saveBookmark(ayah);
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(
                    Icons.turned_in_not,
                    color: AppColors.primaryColor,
                  ),
                  title: Text(
                    'حفظ الآية',
                    style: AppTextStyle.style18W900.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _saveAyahWithNote(ayah, ayahText, '');
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(
                    Icons.edit_note,
                    color: AppColors.primaryColor,
                  ),
                  title: Text(
                    'إضافة ملاحظة',
                    style: AppTextStyle.style18W900.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddNoteBottomSheet(ayah);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _goToNextSurah() {
    final nextSurah = _quranCubit.allSurahs[widget.surah.number];

    context.pushReplacement(
      AppRoutes.surahReadingView,
      extra: nextSurah,
    );
  }

  void _goToPreviousSurah() {
    final prevSurah = _quranCubit.allSurahs[widget.surah.number - 2];
    context.pushReplacement(
      AppRoutes.surahReadingView,
      extra: prevSurah,
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
      key: CacheKeys.quranFontSize,
      value: _fontSize,
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
                                              key: CacheKeys.quranScreenOpacity,
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
                                            key: CacheKeys.quranScreenOpacity,
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
                                              key: CacheKeys.quranScreenOpacity,
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
                                        key: CacheKeys.quranFontSize,
                                        value: 28,
                                      );

                                      CacheHelper.saveData(
                                        key: CacheKeys.quranScreenOpacity,
                                        value: 205,
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
                                  8.verticalSpace,

                                  Row(
                                    children: [
                                      if (widget.surah.number <
                                          _quranCubit.allSurahs.length)
                                        Expanded(
                                          child: InkWell(
                                            onTap: _goToNextSurah,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .arrow_back_ios_new_outlined,
                                                  size: 14.r,
                                                  color: AppColors.primaryColor
                                                      .withAlpha(
                                                        200,
                                                      ),
                                                ),
                                                4.horizontalSpace,
                                                Text(
                                                  'السورة التالية',
                                                  style: AppTextStyle.style9W700
                                                      .copyWith(
                                                        color: AppColors
                                                            .primaryColor
                                                            .withAlpha(
                                                              200,
                                                            ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        const Spacer(),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            _scrollController.animateTo(
                                              0,
                                              duration: const Duration(
                                                milliseconds: 500,
                                              ),
                                              curve: Curves.easeInOut,
                                            );
                                          },
                                          child: Column(
                                            children: [
                                              Icon(
                                                Icons.keyboard_double_arrow_up,
                                                size: 16.r,
                                                color: AppColors.primaryColor
                                                    .withAlpha(200),
                                              ),
                                              Text(
                                                'أعلى الصفحة',
                                                style: AppTextStyle.style9W700
                                                    .copyWith(
                                                      color: AppColors
                                                          .primaryColor
                                                          .withAlpha(
                                                            200,
                                                          ),
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (widget.surah.number > 1)
                                        Expanded(
                                          child: InkWell(
                                            onTap: _goToPreviousSurah,
                                            child: Row(
                                              children: [
                                                Text(
                                                  'السورة السابقة',
                                                  style: AppTextStyle.style9W700
                                                      .copyWith(
                                                        color: AppColors
                                                            .primaryColor
                                                            .withAlpha(
                                                              200,
                                                            ),
                                                      ),
                                                ),
                                                4.horizontalSpace,
                                                Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 14.r,
                                                  color: AppColors.primaryColor
                                                      .withAlpha(200),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      else
                                        const Spacer(),
                                    ],
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

                                      TextSpan(
                                        text: ' $ayahNumber ',
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () => _showAyahOptions(
                                            index + 1,
                                            ayahText,
                                          ),
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
                            40.verticalSpace,

                            Row(
                              children: [
                                if (widget.surah.number > 1)
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: _goToPreviousSurah,
                                      icon: Icon(
                                        Icons.arrow_back_ios_new_outlined,
                                        size: 14.r,
                                        color: _textColor.withAlpha(200),
                                      ),
                                      label: Text(
                                        'السورة السابقة',
                                        style: AppTextStyle.style12W700
                                            .copyWith(
                                              fontFamily: AppFonts.amiri,
                                              color: _textColor.withAlpha(200),
                                            ),
                                      ),
                                    ),
                                  )
                                else
                                  const Spacer(),

                                Expanded(
                                  child: TextButton.icon(
                                    onPressed: () {
                                      _scrollController.animateTo(
                                        0,
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.keyboard_double_arrow_up,
                                      size: 16.r,
                                      color: _textColor.withAlpha(200),
                                    ),
                                    label: Text(
                                      'أعلى الصفحة',
                                      style: AppTextStyle.style12W700.copyWith(
                                        fontFamily: AppFonts.amiri,
                                        color: _textColor.withAlpha(200),
                                      ),
                                    ),
                                  ),
                                ),

                                if (widget.surah.number <
                                    _quranCubit.allSurahs.length)
                                  Expanded(
                                    child: TextButton(
                                      onPressed: _goToNextSurah,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'السورة التالية',
                                            style: AppTextStyle.style12W700
                                                .copyWith(
                                                  fontFamily: AppFonts.amiri,
                                                  color: _textColor.withAlpha(
                                                    200,
                                                  ),
                                                ),
                                          ),
                                          4.horizontalSpace,
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 14.r,
                                            color: _textColor.withAlpha(200),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                else
                                  const Spacer(),
                              ],
                            ),
                            40.verticalSpace,
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
                        fontSize: (_fontSize - 4).sp,
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

  Future<void> _saveAyahWithNote(int ayah, String ayahText, String note) async {
    final newNote = SavedAyahNote(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surahNumber: widget.surah.number,

      endAyahNumber: ayah,
      surahName: widget.surah.name,
      ayahNumber: ayah,
      ayahText: ayahText,
      note: note,
    );

    final dataSource = getIt<NotesDataSource>();
    await dataSource.saveAyahNote(newNote);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الآية والملاحظة بنجاح'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
    }
  }

  void _showAddNoteBottomSheet(int ayah) {
    final noteController = TextEditingController();

    final ayahText = surahAyahs[ayah - 1]
        .replaceFirst('بِسمِ اللَّهِ الرَّحمـٰنِ الرَّحيمِ', '')
        .trim();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.r,
              right: 16.r,
              top: 20.r,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إضافة ملاحظة للآية $ayah',
                  style: AppTextStyle.style18W900.copyWith(
                    fontFamily: AppFonts.amiri,
                  ),
                ),
                16.verticalSpace,
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    ayahText,
                    style: AppTextStyle.style16W800.copyWith(
                      fontFamily: AppFonts.quran,
                      color: AppColors.primaryColor,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                16.verticalSpace,
                TextField(
                  controller: noteController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'اكتب خواطرك أو ملاحظتك حول الآية...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                16.verticalSpace,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        AppColors.primaryColor,
                      ),
                    ),
                    onPressed: () {
                      _saveAyahWithNote(
                        ayah,
                        ayahText,
                        noteController.text.trim(),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('حفظ'),
                  ),
                ),
                20.verticalSpace,
              ],
            ),
          ),
        );
      },
    );
  }
}
