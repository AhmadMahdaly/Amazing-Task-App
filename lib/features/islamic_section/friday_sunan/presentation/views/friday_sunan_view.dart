// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/islamic_section/friday_sunan/presentation/cubit/friday_sunan_cubit.dart';
import 'package:s/features/islamic_section/friday_sunan/presentation/views/widgets/sunnah_card.dart';

class FridaySunanView extends StatefulWidget {
  const FridaySunanView({super.key});

  @override
  State<FridaySunanView> createState() => _FridaySunanViewState();
}

class _FridaySunanViewState extends State<FridaySunanView> {
  double _readingProgress = 0;
  final ScrollController _scrollController = ScrollController();
  double _fontSize = 18;
  @override
  void initState() {
    super.initState();
    _fontSize =
        (CacheHelper.getData(CacheKeys.fridaySunnahFontSize) as num?)
            ?.toDouble() ??
        18;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.position.maxScrollExtent;
      }
    });

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final max = _scrollController.position.maxScrollExtent;
    if (max == 0) return;

    setState(() {
      _readingProgress = (_scrollController.offset / max).clamp(0.0, 1.0);
    });
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
      key: CacheKeys.fridaySunnahFontSize,
      value: _fontSize,
    );
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          title: Text(
            'سنن يوم الجمعة',
            style: AppTextStyle.style20W900.copyWith(
              fontFamily: AppFonts.amiri,
              fontSize: (_fontSize + 2).sp,
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
                Icons.text_fields_rounded,
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
                                      color: AppColors.primaryColor.withAlpha(
                                        100,
                                      ),
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
                                      color: AppColors.primaryColor.withAlpha(
                                        100,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              20.verticalSpace,
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                'مجموعة من السنن والآداب المستحبة يوم الجمعة، مستندة إلى السنة النبوية الصحيحة',
                style: AppTextStyle.style14W500.copyWith(
                  fontFamily: AppFonts.amiri,
                  fontSize: (_fontSize - 4).sp,
                  color: Colors.white.withAlpha(200),
                  height: 1.5,
                ),
              ),
            ),

            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30.r),
                  ),
                ),
                child: BlocBuilder<FridaySunnahCubit, FridaySunnahState>(
                  builder: (context, state) {
                    if (state is FridaySunnahLoading) {
                      return const Center(child: LoadingWidget());
                    } else if (state is FridaySunnahLoaded) {
                      return ListView.separated(
                        controller: _scrollController,
                        padding: EdgeInsets.all(20.r),
                        itemCount: state.sunanList.length,
                        separatorBuilder: (context, index) => 16.verticalSpace,
                        itemBuilder: (context, index) {
                          final item = state.sunanList[index];
                          return SunnahCard(sunnah: item, fontSize: _fontSize);
                        },
                      );
                    } else if (state is FridaySunnahError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
