// ignore_for_file: discarded_futures

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/islamic_section/tabeen/domain/entities/tabeen.dart';
import 'package:s/features/islamic_section/tabeen/presentation/cubit/tabeen_cubit.dart';

class TabeenReadingView extends StatefulWidget {
  const TabeenReadingView({required this.tabeen, super.key});
  final Tabeen tabeen;

  @override
  State<TabeenReadingView> createState() => _TabeenReadingViewState();
}

class _TabeenReadingViewState extends State<TabeenReadingView> {
  double _fontSize = 24;
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

  late TabeenCubit _tabeenCubit;
  double _readingProgress = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabeenCubit = context.read<TabeenCubit>();

    _fontSize =
        (CacheHelper.getData(CacheKeys.tabeenFontSize) as num?)?.toDouble() ??
        24;
    _screenOpacity =
        (CacheHelper.getData(CacheKeys.tabeenScreenOpacity) as num?)?.toInt() ??
        205;

    final colorValue = CacheHelper.getData(CacheKeys.tabeenTextColor) as int?;
    if (colorValue != null) {
      _textColor = Color(colorValue);
    }

    final offset =
        (CacheHelper.getData('tabeen_lesson_${widget.tabeen.id}_offset')
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
    _tabeenCubit.saveLastRead(widget.tabeen);

    super.dispose();
  }

  void _saveOffset() {
    CacheHelper.saveData(
      key: 'tabeen_lesson_${widget.tabeen.id}_offset',
      value: _scrollController.offset,
    );
  }

  void _goToNextLesson() {
    final nextLesson = _tabeenCubit.allTabeen.firstWhere(
      (l) => l.id == widget.tabeen.id + 1,
      orElse: () => widget.tabeen,
    );

    if (nextLesson.id != widget.tabeen.id) {
      context.pushReplacementNamed(
        AppRoutes.tabeenReadingView,
        extra: nextLesson,
      );
    }
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
                widget.tabeen.title,
                style: AppTextStyle.style20Bold.copyWith(
                  color: _textColor,
                  fontFamily: AppFonts.amiri,
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
                                            key: CacheKeys.tabeenTextColor,
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
                                  const Text('حجم الخط'),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          if (_fontSize > 18) {
                                            setState(() => _fontSize -= 2);
                                            setModalState(() {});
                                            CacheHelper.saveData(
                                              key: CacheKeys.tabeenFontSize,
                                              value: _fontSize,
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
                                        value: _fontSize,
                                        min: 16,
                                        max: 48,
                                        divisions: 16,
                                        label: _fontSize.round().toString(),
                                        onChanged: (value) {
                                          setState(() => _fontSize = value);
                                          setModalState(() {});
                                        },
                                        onChangeEnd: (value) {
                                          CacheHelper.saveData(
                                            key: CacheKeys.tabeenFontSize,
                                            value: value,
                                          );
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          if (_fontSize < 48) {
                                            setState(() => _fontSize += 2);
                                            setModalState(() {});
                                            CacheHelper.saveData(
                                              key: CacheKeys.tabeenFontSize,
                                              value: _fontSize,
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

                                  const Text('شفافية الشاشة'),
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
                                                  CacheKeys.tabeenScreenOpacity,
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
                                            key: CacheKeys.tabeenScreenOpacity,
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
                                                  CacheKeys.tabeenScreenOpacity,
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
                                        _fontSize = 24;
                                        _screenOpacity = 205;
                                        _textColor = Colors.white;
                                      });
                                      setModalState(() {});
                                      CacheHelper.saveData(
                                        key: CacheKeys.tabeenFontSize,
                                        value: 24,
                                      );
                                      CacheHelper.saveData(
                                        key: CacheKeys.tabeenScreenOpacity,
                                        value: 205,
                                      );
                                      CacheHelper.saveData(
                                        key: CacheKeys.tabeenTextColor,
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
                child: widget.tabeen.content.isEmpty
                    ? const Center(child: LoadingWidget())
                    : SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            Text.rich(
                              TextSpan(
                                children: _buildHighlightedSpans(
                                  widget.tabeen.content,
                                ),
                                style: AppTextStyle.style20W600.copyWith(
                                  fontFamily: AppFonts.amiri,
                                  color: _textColor,
                                  height: 1.8,
                                  fontSize: _fontSize.sp,
                                ),
                              ),
                              // textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                            ),
                            if (widget.tabeen.id <
                                _tabeenCubit.allTabeen.length) ...[
                              40.verticalSpace,
                              FilledButton.icon(
                                style: const ButtonStyle(
                                  iconAlignment: IconAlignment.end,
                                  backgroundColor: WidgetStatePropertyAll(
                                    AppColors.transparent,
                                  ),
                                ),
                                onPressed: _goToNextLesson,
                                icon: Icon(
                                  Icons.arrow_forward,
                                  size: 12.r,
                                  color: _textColor.withAlpha(200),
                                ),
                                label: Text(
                                  'الانتقال إلى التالي',
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

  List<InlineSpan> _buildHighlightedSpans(String text) {
    final spans = <InlineSpan>[];

    final regex = RegExp(r'([^\s()]+)\s*\(([^()]*)\)');

    var last = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > last) {
        spans.add(
          TextSpan(
            text: text.substring(last, match.start),
          ),
        );
      }

      final word = match.group(1)!;
      final note = match.group(2)!;

      spans.add(
        TextSpan(
          text: word,
          style: TextStyle(
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dotted,
            decorationColor: AppColors.buttonColor.withAlpha(100),
            color: _textColor,
          ),
          recognizer: TapGestureRecognizer()..onTap = () => _showMeaning(note),
        ),
      );

      last = match.end;
    }

    if (last < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(last),
        ),
      );
    }

    return spans;
  }

  void _showMeaning(String note) {
    showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.all(20.r),
          child: SizedBox(
            width: double.infinity,
            child: Text(
              note,
              style: AppTextStyle.style20W600.copyWith(
                fontFamily: AppFonts.amiri,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}

class NoteSpan {
  const NoteSpan({
    required this.text,
    this.note,
    this.clickable = false,
  });
  final String text;
  final String? note;
  final bool clickable;
}
