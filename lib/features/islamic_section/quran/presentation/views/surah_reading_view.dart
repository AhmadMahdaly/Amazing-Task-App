// ignore_for_file: unawaited_futures, discarded_futures, omit_local_variable_types, prefer_int_literals

import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
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
import 'package:s/features/islamic_section/notes/presentation/cubit/notes_cubit.dart';
import 'package:s/features/islamic_section/notes/presentation/utils/notes_section_type.dart';
import 'package:s/features/islamic_section/quran/data/models/reciter_model.dart';
import 'package:s/features/islamic_section/quran/domain/entities/saved_ayah_note_entity.dart';
import 'package:s/features/islamic_section/quran/domain/entities/surah_entity.dart';
import 'package:s/features/islamic_section/quran/presentation/controllers/audio_cubit/audio_cubit.dart';
import 'package:s/features/islamic_section/quran/presentation/controllers/quran_cubit/quran_cubit.dart';
import 'package:s/features/islamic_section/quran/presentation/views/widgets/reciter_tile_widget.dart';

class SurahReadingView extends StatefulWidget {
  const SurahReadingView({required this.surah, this.startAyah, super.key});
  final SurahEntity surah;
  final int? startAyah;

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
  final Map<int, GlobalKey> _ayahKeys = {};
  @override
  void initState() {
    super.initState();
    _quranCubit = context.read<QuranCubit>();
    surahAyahs = _quranCubit.getAyahsForSurah(widget.surah.number);
    context.read<NotesCubit>().loadNotes(NotesSectionType.quran);

    for (var i = 1; i <= surahAyahs.length; i++) {
      _ayahKeys[i] = GlobalKey();
    }
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

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (widget.startAyah != null && widget.startAyah! > 1) {
        final targetKey = _ayahKeys[widget.startAyah];
        if (targetKey != null && targetKey.currentContext != null) {
          Scrollable.ensureVisible(
            targetKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.1,
          );
        }
      } else if (_scrollController.hasClients) {
        final max = _scrollController.position.maxScrollExtent;
        _scrollController.jumpTo(offset.clamp(0.0, max));
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
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('تم حفظ الموضع عند الآية $ayah بنجاح'),
          backgroundColor: AppColors.primaryColor,
        ),
      );
  }

  void _showAyahOptions(
    int ayah,
    String ayahText,
    bool isSaved,
    SavedAyahNote? savedNote,
  ) {
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
                  leading: Icon(
                    isSaved ? Icons.bookmark_remove : Icons.turned_in_not,
                    color: AppColors.primaryColor,
                  ),
                  title: Text(
                    isSaved ? 'حذف من الحفظ' : 'حفظ الآية',
                    style: AppTextStyle.style18W900.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    if (isSaved && savedNote != null) {
                      context.read<NotesCubit>().deleteNote(
                        savedNote,
                        NotesSectionType.quran,
                      );
                    } else {
                      _saveAyahWithNote(ayah, ayahText, '', null);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.edit_note,
                    color: AppColors.primaryColor,
                  ),
                  title: Text(
                    isSaved && (savedNote?.note.isNotEmpty ?? false)
                        ? 'عرض وتعديل الملاحظة'
                        : 'إضافة ملاحظة',
                    style: AppTextStyle.style18W900.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddNoteBottomSheet(ayah, savedNote);
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

      extra: {
        'surah': nextSurah,
        'startAyah': 1,
      },
    );
  }

  void _goToPreviousSurah() {
    final prevSurah = _quranCubit.allSurahs[widget.surah.number - 2];
    context.pushReplacement(
      AppRoutes.surahReadingView,
      extra: {
        'surah': prevSurah,
        'startAyah': 1,
      },
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

  void _showReciterSelectionBottomSheet(
    BuildContext context,
    AudioCubit cubit,
  ) {
    final reciters = cubit.allReciters;

    if (reciters.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('جاري تجهيز قائمة القراء، يرجى المحاولة بعد قليل'),
            backgroundColor: AppColors.primaryColor,
          ),
        );

      cubit.loadReciters();
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Column(
                children: [
                  Text(
                    'اختر القارئ',
                    style: AppTextStyle.style18W900.copyWith(
                      fontFamily: AppFonts.amiri,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  10.verticalSpace,
                  const Divider(),
                  Expanded(
                    child: FutureBuilder<List<List<ReciterModel>>>(
                      future: _sortRecitersByDownloadStatus(
                        reciters,
                        widget.surah.number,
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryColor,
                            ),
                          );
                        }

                        final downloaded = snapshot.data![0];
                        final notDownloaded = snapshot.data![1];

                        return CustomScrollView(
                          slivers: [
                            if (downloaded.isNotEmpty) ...[
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: 20.w,
                                    bottom: 8.h,
                                    top: 8.h,
                                  ),
                                  child: Text(
                                    'السور المحملة مسبقاً',
                                    style: AppTextStyle.style14W800.copyWith(
                                      color: AppColors.successColor,
                                      fontFamily: AppFonts.amiri,
                                    ),
                                  ),
                                ),
                              ),
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) => ReciterTileWidget(
                                    context: context,
                                    widget: widget,
                                    onDeleted: () => setModalState(() {}),
                                    cubit: cubit,
                                    reciter: downloaded[index],
                                    isDownloaded: true,
                                  ),
                                  childCount: downloaded.length,
                                ),
                              ),

                              SliverToBoxAdapter(
                                child: Divider(
                                  color: AppColors.primaryColor.withAlpha(30),
                                  thickness: 1,
                                  indent: 20.w,
                                  endIndent: 20.w,
                                  height: 30.h,
                                ),
                              ),

                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    right: 20.w,
                                    bottom: 8.h,
                                  ),
                                  child: Text(
                                    'جميع القراء',
                                    style: AppTextStyle.style14W800.copyWith(
                                      color: AppColors.secondaryColor,
                                      fontFamily: AppFonts.amiri,
                                    ),
                                  ),
                                ),
                              ),
                            ],

                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) => ReciterTileWidget(
                                  context: context,
                                  cubit: cubit,
                                  widget: widget,
                                  reciter: notDownloaded[index],
                                  isDownloaded: false,
                                ),
                                childCount: notDownloaded.length,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<List<ReciterModel>>> _sortRecitersByDownloadStatus(
    List<ReciterModel> reciters,
    int surahNumber,
  ) async {
    final dir = await getApplicationDocumentsDirectory();
    final surahPadded = surahNumber.toString().padLeft(3, '0');

    final downloaded = <ReciterModel>[];
    final notDownloaded = <ReciterModel>[];

    for (final reciter in reciters) {
      if (reciter.server.isEmpty) continue;

      final filePath = '${dir.path}/quran_audio/${reciter.id}/$surahPadded.mp3';

      if (File(filePath).existsSync()) {
        downloaded.add(reciter);
      } else {
        notDownloaded.add(reciter);
      }
    }

    return [downloaded, notDownloaded];
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WallpaperCubit, WallpaperState>(
      builder: (context, wallpaperState) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            primary: false,
            extendBody: true,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              toolbarHeight: 70.h,
              title: Text(
                'سورة ${widget.surah.name}',
                style: AppTextStyle.style20Bold.copyWith(
                  color: _textColor,
                  fontFamily: AppFonts.quran,
                ),
              ),
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => context.pop(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    Icons.headset_mic_outlined,
                    color: AppColors.buttonColor.withAlpha(150),
                    size: 22.r,
                  ),
                  onPressed: () async {
                    await context.read<AudioCubit>().loadReciters();
                    _showReciterSelectionBottomSheet(
                      context,
                      context.read<AudioCubit>(),
                    );
                  },
                ),
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
                                      20.horizontalSpace,
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
                                      20.horizontalSpace,
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
                                      20.horizontalSpace,
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
                                      Expanded(
                                        child: Slider(
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
                                              () => _screenOpacity = value
                                                  .toInt(),
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
                                      20.horizontalSpace,
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

            backgroundColor: wallpaperState.settings.hasWallpaper
                ? Colors.transparent
                : AppColors.primaryColor,

            body: AppWallpaper(
              settings: wallpaperState.settings,
              child: ColoredBox(
                color: AppColors.primaryColor.withAlpha(_screenOpacity),
                child: surahAyahs.isEmpty
                    ? const Center(child: LoadingWidget())
                    : BlocBuilder<NotesCubit, NotesState>(
                        builder: (context, notesState) {
                          final List<SavedAyahNote> savedAyahs = [];
                          if (notesState is NotesLoaded) {
                            for (final note in notesState.notes) {
                              if (note is SavedAyahNote &&
                                  note.surahNumber.toString() ==
                                      widget.surah.number.toString()) {
                                savedAyahs.add(note);
                              }
                            }
                          }

                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
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
                                    children: surahAyahs.asMap().entries.expand((
                                      entry,
                                    ) {
                                      final index = entry.key;
                                      var ayahText = entry.value;
                                      final ayahNumberInt = index + 1;
                                      final ayahNumberStr =
                                          _convertToArabicNumber(ayahNumberInt);

                                      if (widget.surah.number != 9 &&
                                          index == 0) {
                                        ayahText = ayahText.replaceFirst(
                                          'بِسمِ اللَّهِ الرَّحمـٰنِ الرَّحيمِ',
                                          '',
                                        );
                                      }

                                      SavedAyahNote? savedNote;
                                      for (final n in savedAyahs) {
                                        if (n.ayahNumber.toString() ==
                                            ayahNumberInt.toString()) {
                                          if (savedNote == null ||
                                              (n.note != null &&
                                                  n.note.trim().isNotEmpty)) {
                                            savedNote = n;
                                          }
                                        }
                                      }

                                      final bool isSaved = savedNote != null;
                                      final bool hasNote =
                                          isSaved &&
                                          (savedNote.note != null &&
                                              savedNote.note.trim().isNotEmpty);

                                      final Color currentAyahColor = isSaved
                                          ? AppColors.successColor
                                          : _textColor;

                                      final juzList = _quranCubit.allJuz.where(
                                        (j) =>
                                            j.startSurah ==
                                                widget.surah.number &&
                                            j.startAyah == ayahNumberInt,
                                      );
                                      final juzStart = juzList.isEmpty
                                          ? null
                                          : juzList.first;
                                      final hizbList = _quranCubit.allHizb
                                          .where(
                                            (h) =>
                                                h.startSurah ==
                                                    widget.surah.number &&
                                                h.startAyah == ayahNumberInt,
                                          );
                                      final hizbStart = hizbList.isEmpty
                                          ? null
                                          : hizbList.first;
                                      final spans = <InlineSpan>[];

                                      if (juzStart != null ||
                                          hizbStart != null) {
                                        var markerText = '';
                                        if (juzStart != null &&
                                            hizbStart != null) {
                                          markerText =
                                              '${juzStart.name} - ${hizbStart.name}';
                                        } else if (juzStart != null) {
                                          markerText = juzStart.name;
                                        } else {
                                          markerText = hizbStart!.name;
                                        }
                                        spans.add(
                                          WidgetSpan(
                                            alignment:
                                                PlaceholderAlignment.middle,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  markerText,
                                                  style: AppTextStyle
                                                      .style12W800
                                                      .copyWith(
                                                        fontFamily:
                                                            AppFonts.amiri,
                                                        color: _textColor
                                                            .withAlpha(100),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }
                                      spans
                                        ..add(
                                          WidgetSpan(
                                            child: SizedBox(
                                              key: _ayahKeys[ayahNumberInt],
                                              width: 1,
                                              height: 1,
                                            ),
                                          ),
                                        )
                                        ..add(
                                          TextSpan(
                                            text: ' $ayahText ',
                                            recognizer:
                                                LongPressGestureRecognizer()
                                                  ..onLongPress = () =>
                                                      _openTafsir(
                                                        ayahNumberInt,
                                                      ),
                                            style: AppTextStyle.style20W900
                                                .copyWith(
                                                  fontFamily: AppFonts.quran,
                                                  color: currentAyahColor,
                                                  height: 1.8,
                                                  fontSize: _fontSize.sp,
                                                ),
                                          ),
                                        )
                                        ..add(
                                          TextSpan(
                                            text: ayahNumberStr,
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () => _showAyahOptions(
                                                ayahNumberInt,
                                                ayahText,
                                                isSaved,
                                                savedNote,
                                              ),
                                            style: AppTextStyle.style20W900
                                                .copyWith(
                                                  fontFamily: AppFonts.quran,
                                                  color: currentAyahColor,
                                                  decoration: hasNote
                                                      ? TextDecoration.underline
                                                      : null,
                                                  decorationColor:
                                                      AppColors.successColor,
                                                  height: 1.8,
                                                  fontSize: _fontSize.sp,
                                                ),
                                          ),
                                        );

                                      return spans;
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
                                                  color: _textColor.withAlpha(
                                                    200,
                                                  ),
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
                                          style: AppTextStyle.style12W700
                                              .copyWith(
                                                fontFamily: AppFonts.amiri,
                                                color: _textColor.withAlpha(
                                                  200,
                                                ),
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
                                                      fontFamily:
                                                          AppFonts.amiri,
                                                      color: _textColor
                                                          .withAlpha(
                                                            200,
                                                          ),
                                                    ),
                                              ),
                                              4.horizontalSpace,
                                              Icon(
                                                Icons.arrow_forward_ios,
                                                size: 14.r,
                                                color: _textColor.withAlpha(
                                                  200,
                                                ),
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
                          );
                        },
                      ),
              ),
            ),
            bottomNavigationBar: BlocConsumer<AudioCubit, AudioState>(
              listener: (context, audioState) {
                if (audioState is AudioError) {
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                          audioState.message,
                          style: AppTextStyle.style14W500.copyWith(
                            fontFamily: AppFonts.amiri,
                          ),
                        ),
                        backgroundColor: AppColors.errorColor,
                      ),
                    );
                }
              },
              builder: (context, audioState) {
                if (audioState is AudioInitial || audioState is AudioError) {
                  return const SizedBox.shrink();
                }

                final cubit = context.read<AudioCubit>();

                return Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 32.w,
                  ),
                  height: 110.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32.r),
                    color: AppColors.forthColor.withAlpha(240),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      24.verticalSpace,
                      if (audioState is AudioPlaying ||
                          audioState is AudioPaused)
                        StreamBuilder<Duration>(
                          stream: cubit.player.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration =
                                cubit.player.duration ?? Duration.zero;

                            double progressValue = 0.0;
                            if (duration.inMilliseconds > 0) {
                              progressValue =
                                  position.inMilliseconds /
                                  duration.inMilliseconds;
                            }
                            String formatDuration(Duration d) {
                              final minutes = d.inMinutes
                                  .remainder(60)
                                  .toString()
                                  .padLeft(2, '0');
                              final seconds = d.inSeconds
                                  .remainder(60)
                                  .toString()
                                  .padLeft(2, '0');
                              final hours = d.inHours > 0
                                  ? '${d.inHours}:'
                                  : '';
                              return '$hours$minutes:$seconds';
                            }

                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                              ),

                              child: Row(
                                children: [
                                  Text(
                                    formatDuration(position),
                                    style: AppTextStyle.style12W500.copyWith(
                                      color: Colors.white,
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderThemeData(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24.w,
                                        ),

                                        trackHeight: 3.h,
                                        thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 6.r,
                                        ),
                                        overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 12.r,
                                        ),
                                        activeTrackColor: AppColors.buttonColor,
                                        inactiveTrackColor: Colors.white
                                            .withAlpha(50),
                                        thumbColor: AppColors.buttonColor,
                                      ),
                                      child: Slider(
                                        value: progressValue.clamp(0.0, 1.0),
                                        onChanged: (value) {
                                          final newPosition = Duration(
                                            milliseconds:
                                                (duration.inMilliseconds *
                                                        value)
                                                    .round(),
                                          );
                                          cubit.seek(newPosition);
                                        },
                                      ),
                                    ),
                                  ),
                                  Text(
                                    formatDuration(duration),
                                    style: AppTextStyle.style12W500.copyWith(
                                      color: Colors.white.withAlpha(150),
                                    ),
                                    textDirection: TextDirection.ltr,
                                  ),
                                ],
                              ),
                            );
                          },
                        )
                      else if (audioState is AudioDownloading)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                          ),

                          child: LinearProgressIndicator(
                            value: audioState.progress,
                            backgroundColor: Colors.white.withAlpha(50),
                            color: AppColors.buttonColor,
                            minHeight: 3.h,
                          ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 24.w,
                          ),
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white.withAlpha(50),
                            color: AppColors.buttonColor,
                            minHeight: 3.h,
                          ),
                        ),

                      Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            if (audioState is AudioPlaying ||
                                audioState is AudioPaused)
                              Positioned(
                                left: 8.w,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.close_rounded,
                                    color: Colors.white.withAlpha(200),
                                    size: 24.r,
                                  ),
                                  onPressed: cubit.stop,
                                ),
                              ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (audioState is AudioLoading) ...[
                                  const CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                  16.horizontalSpace,
                                  Text(
                                    'جاري الاتصال وتحضير الملف...',
                                    style: AppTextStyle.style14W500.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ] else if (audioState is AudioDownloading) ...[
                                  Text(
                                    'جاري التحميل... ${(audioState.progress * 100).toInt()}%',
                                    style: AppTextStyle.style14W500.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ] else if (audioState is AudioPlaying) ...[
                                  IconButton(
                                    icon: Icon(
                                      Icons.pause_circle_filled,
                                      size: 40.r,
                                      color: Colors.white,
                                    ),
                                    onPressed: cubit.pause,
                                  ),
                                  Text(
                                    'قيد التشغيل',
                                    style: AppTextStyle.style14W500.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ] else if (audioState is AudioPaused) ...[
                                  IconButton(
                                    icon: Icon(
                                      Icons.play_circle_filled,
                                      size: 40.r,
                                      color: Colors.white,
                                    ),
                                    onPressed: cubit.resume,
                                  ),
                                  Text(
                                    'متوقف',
                                    style: AppTextStyle.style14W500.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      16.verticalSpace,
                    ],
                  ),
                );
              },
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

  Future<void> _saveAyahWithNote(
    int ayah,
    String ayahText,
    String note, [
    SavedAyahNote? existingNote,
  ]) async {
    final dataSource = getIt<NotesDataSource>();

    try {
      if (existingNote != null) {
        try {
          await dataSource.deleteNote(existingNote, NotesSectionType.quran);
        } catch (_) {}
      }

      final newNote = SavedAyahNote(
        id:
            existingNote?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        surahNumber: widget.surah.number,
        endAyahNumber: ayah,
        surahName: widget.surah.name,
        ayahNumber: ayah,
        ayahText: ayahText,
        note: note,
      );

      await dataSource.saveAyahNote(newNote);

      if (mounted) {
        await context.read<NotesCubit>().loadNotes(NotesSectionType.quran);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                note.isEmpty
                    ? 'تم حفظ الآية بنجاح'
                    : 'تم حفظ الآية والملاحظة بنجاح',
              ),
              backgroundColor: AppColors.primaryColor,
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('حدث خطأ أثناء الحفظ، يرجى المحاولة مرة أخرى'),
              backgroundColor: Colors.red,
            ),
          );
      }
    }
  }

  void _showAddNoteBottomSheet(int ayah, SavedAyahNote? existingNote) {
    final noteController = TextEditingController(
      text: existingNote?.note ?? '',
    );

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
                  existingNote != null && (existingNote.note.isNotEmpty)
                      ? 'عرض وتعديل ملاحظة الآية $ayah'
                      : 'إضافة ملاحظة للآية $ayah',
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
                        existingNote,
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
