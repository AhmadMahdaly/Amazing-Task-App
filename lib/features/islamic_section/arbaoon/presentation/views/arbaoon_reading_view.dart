// ignore_for_file: discarded_futures, cascade_invocations
import 'dart:math' as math;

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
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/islamic_section/arbaoon/domain/entities/hadith.dart';
import 'package:s/features/islamic_section/arbaoon/presentation/cubit/arbaoon_cubit.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_highlight.dart';

class ArbaoonReadingView extends StatefulWidget {
  const ArbaoonReadingView({required this.hadith, super.key});
  final Hadith hadith;

  @override
  State<ArbaoonReadingView> createState() => _ArbaoonReadingViewState();
}

class _ArbaoonReadingViewState extends State<ArbaoonReadingView> {
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
  List<Highlight> _highlights = [];
  final List<Color> _highlightColors = [
    Colors.orange,
    Colors.green,
    Colors.blue,
    Colors.redAccent,
    Colors.purple,
  ];
  late ArbaoonCubit _arbaoonCubit;
  double _readingProgress = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _arbaoonCubit = context.read<ArbaoonCubit>();

    _fontSize =
        (CacheHelper.getData(CacheKeys.hadithFontSize) as num?)?.toDouble() ??
        24;
    _screenOpacity =
        (CacheHelper.getData(CacheKeys.hadithScreenOpacity) as num?)?.toInt() ??
        205;

    final colorValue = CacheHelper.getData(CacheKeys.hadithTextColor) as int?;
    if (colorValue != null) {
      _textColor = Color(colorValue);
    }

    final offset =
        (CacheHelper.getData('arbaoon_lesson_${widget.hadith.id}_offset')
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
    _loadHighlights();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _arbaoonCubit.saveLastRead(widget.hadith);

    super.dispose();
  }

  void _saveOffset() {
    CacheHelper.saveData(
      key: 'arbaoon_lesson_${widget.hadith.id}_offset',
      value: _scrollController.offset,
    );
  }

  void _goToNextLesson() {
    final nextLesson = _arbaoonCubit.allHadiths.firstWhere(
      (l) => l.id == widget.hadith.id + 1,
      orElse: () => widget.hadith,
    );

    if (nextLesson.id != widget.hadith.id) {
      context.pushReplacementNamed(
        AppRoutes.arbaoonReadingView,
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

  void _loadHighlights() {
    final savedData =
        CacheHelper.getData('arbaoon_highlights_${widget.hadith.id}')
            as String?;
    if (savedData != null) {
      setState(() {
        _highlights = Highlight.decode(savedData);
      });
    }
  }

  void _saveHighlights() {
    CacheHelper.saveData(
      key: 'arbaoon_highlights_${widget.hadith.id}',
      value: Highlight.encode(_highlights),
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
                widget.hadith.title,
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
                                            key: CacheKeys.hadithTextColor,
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
                                              key: CacheKeys.hadithFontSize,
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
                                            key: CacheKeys.hadithFontSize,
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
                                              key: CacheKeys.hadithFontSize,
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
                                                  CacheKeys.hadithScreenOpacity,
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
                                            key: CacheKeys.hadithScreenOpacity,
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
                                                  CacheKeys.hadithScreenOpacity,
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
                                        key: CacheKeys.hadithFontSize,
                                        value: 24,
                                      );
                                      CacheHelper.saveData(
                                        key: CacheKeys.hadithScreenOpacity,
                                        value: 205,
                                      );
                                      CacheHelper.saveData(
                                        key: CacheKeys.hadithTextColor,
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
                child: widget.hadith.content.isEmpty
                    ? const Center(child: LoadingWidget())
                    : SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            SelectableText.rich(
                              TextSpan(
                                children: _buildHighlightedSpans(
                                  widget.hadith.content,
                                ),
                                style: AppTextStyle.style20W600.copyWith(
                                  fontFamily: AppFonts.amiri,
                                  color: _textColor,
                                  height: 1.8,
                                  fontSize: _fontSize.sp,
                                ),
                              ),
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                              contextMenuBuilder: (context, editableTextState) {
                                final buttonItems =
                                    editableTextState.contextMenuButtonItems;

                                buttonItems.insert(
                                  0,
                                  ContextMenuButtonItem(
                                    label: 'تحديد / ملاحظة',
                                    type: ContextMenuButtonType.liveTextInput,
                                    onPressed: () {
                                      final selection = editableTextState
                                          .textEditingValue
                                          .selection;
                                      if (!selection.isCollapsed) {
                                        final selectedText = editableTextState
                                            .textEditingValue
                                            .text
                                            .substring(
                                              selection.start,
                                              selection.end,
                                            );

                                        ContextMenuController.removeAny();

                                        _showHighlightBottomSheet(
                                          selection.start,
                                          selection.end,
                                          selectedText,
                                        );
                                      }
                                    },
                                  ),
                                );

                                return AdaptiveTextSelectionToolbar.buttonItems(
                                  anchors: editableTextState.contextMenuAnchors,
                                  buttonItems: buttonItems,
                                );
                              },
                            ),
                            if (widget.hadith.id <
                                _arbaoonCubit.allHadiths.length) ...[
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
                                  'الانتقال إلى الحديث التالي',
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
    _highlights.sort((a, b) => a.startOffset.compareTo(b.startOffset));

    final spans = <InlineSpan>[];
    var currentIndex = 0;

    for (final h in _highlights) {
      if (h.startOffset < currentIndex) continue;

      if (h.startOffset > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, h.startOffset)));
      }

      spans.add(
        TextSpan(
          text: text.substring(h.startOffset, h.endOffset),
          style: TextStyle(
            color: Color(h.colorValue),
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _showEditHighlightBottomSheet(h);
            },
        ),
      );
      currentIndex = h.endOffset;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  void _showHighlightBottomSheet(int start, int end, String text) {
    var selectedColor = _highlightColors.first;
    final noteController = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'تحديد النص وإضافة ملاحظة',
                    style: AppTextStyle.style18W900.copyWith(
                      fontFamily: AppFonts.amiri,
                    ),
                  ),
                  16.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _highlightColors.map((color) {
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = color),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  16.verticalSpace,
                  CustomPrimaryTextfield(
                    controller: noteController,
                    text: 'اكتب ملاحظتك هنا (اختياري)',
                    textAlign: TextAlign.center,
                    hintStyle: AppTextStyle.style16W600.copyWith(
                      fontFamily: AppFonts.amiri,
                      color: AppColors.secondaryColor,
                    ),

                    maxLines: 3,
                  ),
                  16.verticalSpace,
                  FilledButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        AppColors.primaryColor,
                      ),
                    ),
                    onPressed: () {
                      // بناء كائن التحديد الجديد
                      final newHighlight = Highlight(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        lessonId: widget.hadith.id,
                        startOffset: start,
                        endOffset: end,
                        selectedText: text,
                        colorValue: selectedColor.toARGB32(),
                        note: noteController.text,
                      );

                      // استدعاء دالة الدمج الذكية بدلاً من الإضافة المباشرة
                      _addAndMergeHighlight(newHighlight);

                      Navigator.pop(context);
                    },
                    child: Text(
                      'حفظ',
                      style: AppTextStyle.style18W900.copyWith(
                        fontFamily: AppFonts.amiri,
                      ),
                    ),
                  ),
                  20.verticalSpace,
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _addAndMergeHighlight(Highlight newHighlight) {
    setState(() {
      // 1. إضافة التحديد الجديد
      _highlights.add(newHighlight);

      // 2. الترتيب المكاني (حسب بداية التحديد)
      _highlights.sort((a, b) => a.startOffset.compareTo(b.startOffset));

      // 3. خوارزمية الدمج (Merge Intervals)
      final mergedHighlights = <Highlight>[];
      if (_highlights.isEmpty) return;

      var current = _highlights.first;

      for (var i = 1; i < _highlights.length; i++) {
        final next = _highlights[i];

        // التحقق مما إذا كان التحديدان متقاطعين أو متلامسين
        if (current.endOffset >= next.startOffset) {
          // دمج الأرقام
          final mergedStart = current.startOffset;
          final mergedEnd = math.max(current.endOffset, next.endOffset);

          // استخراج النص المدمج بسلاسة من محتوى الدرس الأصلي
          final mergedText = widget.hadith.content.substring(
            mergedStart,
            mergedEnd,
          );

          // دمج الملاحظات (نحتفظ بالقديمة إن وجدت، وإلا نأخذ الجديدة)
          final mergedNote = current.note.isNotEmpty ? current.note : next.note;

          // إنشاء الكائن المدمج
          current = Highlight(
            id: current.id, // نحتفظ بالـ ID القديم
            lessonId: current.lessonId,
            startOffset: mergedStart,
            endOffset: mergedEnd,
            selectedText: mergedText,
            colorValue: next.colorValue, // اللون الجديد يطغى على القديم
            note: mergedNote,
          );
        } else {
          // إذا لم يتقاطعا، نضيف الحالي للقائمة وننتقل للتالي
          mergedHighlights.add(current);
          current = next;
        }
      }
      mergedHighlights.add(current);

      // 4. تحديث القائمة الأساسية
      _highlights = mergedHighlights;
    });

    // حفظ التغييرات بعد الدمج
    _saveHighlights();
  }

  void _showEditHighlightBottomSheet(Highlight highlight) {
    var selectedColor = Color(highlight.colorValue);
    final noteController = TextEditingController(
      text: highlight.note,
    );

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16.w,
                right: 16.w,
                top: 16.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () {
                          setState(() {
                            _highlights.removeWhere(
                              (h) => h.id == highlight.id,
                            );
                          });
                          _saveHighlights();
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'تعديل أو إزالة التحديد',
                        style: AppTextStyle.style18W900.copyWith(
                          fontFamily: AppFonts.amiri,
                        ),
                      ),
                    ],
                  ),
                  16.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _highlightColors.map((color) {
                      return GestureDetector(
                        onTap: () => setSheetState(() => selectedColor = color),
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8.r),
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  selectedColor.toARGB32() == color.toARGB32()
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  16.verticalSpace,
                  CustomPrimaryTextfield(
                    controller: noteController,
                    textAlign: TextAlign.center,
                    text: 'اكتب ملاحظتك هنا (اختياري)',
                    hintStyle: AppTextStyle.style16W600.copyWith(
                      fontFamily: AppFonts.amiri,
                      color: AppColors.secondaryColor,
                    ),
                    maxLines: 3,
                  ),
                  16.verticalSpace,
                  FilledButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        AppColors.primaryColor,
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        final index = _highlights.indexWhere(
                          (h) => h.id == highlight.id,
                        );
                        if (index != -1) {
                          _highlights[index] = Highlight(
                            id: highlight.id,
                            lessonId: highlight.lessonId,
                            startOffset: highlight.startOffset,
                            endOffset: highlight.endOffset,
                            selectedText: highlight.selectedText,
                            colorValue: selectedColor.toARGB32(),
                            note: noteController.text,
                          );
                        }
                      });
                      _saveHighlights();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'حفظ التعديلات',
                      style: AppTextStyle.style18W900.copyWith(
                        fontFamily: AppFonts.amiri,
                      ),
                    ),
                  ),
                  20.verticalSpace,
                ],
              ),
            );
          },
        );
      },
    );
  }
}
