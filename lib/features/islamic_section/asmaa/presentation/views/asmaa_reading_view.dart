// ignore_for_file: cascade_invocations, discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/routing/app_routes.dart';
import 'package:s/core/shared_widgets/app_wallpaper.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_lesson.dart';
import 'package:s/features/islamic_section/asmaa/presentation/cubit/asmaa_cubit.dart';

class AsmaaReadingView extends StatefulWidget {
  const AsmaaReadingView({required this.lesson, super.key});
  final AsmaaLesson lesson;

  @override
  State<AsmaaReadingView> createState() => _AsmaaReadingViewState();
}

class _AsmaaReadingViewState extends State<AsmaaReadingView> {
  double _fontSize = 24;
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

  late AsmaaCubit _asmaaCubit;
  double _readingProgress = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _asmaaCubit = context.read<AsmaaCubit>();

    // يمكن استخدام مفاتيح الكاش القديمة أو تعريف مفاتيح خاصة للأسماء
    _fontSize =
        (CacheHelper.getData('asmaa_font_size') as num?)?.toDouble() ?? 24;
    _screenOpacity =
        (CacheHelper.getData('asmaa_screen_opacity') as num?)?.toInt() ?? 200;

    final colorValue = CacheHelper.getData('asmaa_text_color') as int?;
    if (colorValue != null) {
      _textColor = Color(colorValue);
    }

    final offset =
        (CacheHelper.getData('asmaa_lesson_${widget.lesson.id}_offset') as num?)
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
    _asmaaCubit.saveLastRead(widget.lesson.id);

    super.dispose();
  }

  void _saveOffset() {
    CacheHelper.saveData(
      key: 'asmaa_lesson_${widget.lesson.id}_offset',
      value: _scrollController.offset,
    );
  }

  void _goToNextLesson() {
    final nextLesson = _asmaaCubit.allLessons.firstWhere(
      (l) => l.id == widget.lesson.id + 1,
      orElse: () => widget.lesson,
    );

    if (nextLesson.id != widget.lesson.id) {
      context.pushReplacementNamed(
        AppRoutes.asmaaReadingView,
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
                widget.lesson.title,
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
                                  const Text('حجم الخط'),
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
                                        key: 'asmaa_font_size',
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
                                            key: 'asmaa_text_color',
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
                                    label: _screenOpacity.toString(),
                                    onChanged: (value) {
                                      setState(
                                        () => _screenOpacity = value.toInt(),
                                      );
                                      setModalState(() {});
                                    },
                                    onChangeEnd: (value) {
                                      CacheHelper.saveData(
                                        key: 'asmaa_screen_opacity',
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
                                        _fontSize = 24;
                                        _screenOpacity = 200;
                                        _textColor = Colors.white;
                                      });
                                      setModalState(() {});
                                      CacheHelper.saveData(
                                        key: 'asmaa_font_size',
                                        value: 24,
                                      );
                                      CacheHelper.saveData(
                                        key: 'asmaa_screen_opacity',
                                        value: 200,
                                      );
                                      CacheHelper.saveData(
                                        key: 'asmaa_text_color',
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
                child: widget.lesson.content.isEmpty
                    ? const Center(child: LoadingWidget())
                    : SingleChildScrollView(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          children: [
                            Text(
                              widget.lesson.content,
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                              style: AppTextStyle.style20W900.copyWith(
                                fontFamily: AppFonts.amiri,
                                color: _textColor,
                                height: 1.8,
                                fontSize: _fontSize.sp,
                              ),
                            ),
                            // التحقق مما إذا كان هناك درس تالي في القائمة لإظهار الزر
                            if (widget.lesson.id <
                                _asmaaCubit.allLessons.length) ...[
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
                                  'الانتقال إلى الاسم التالي',
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
}
