// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/cache_helper/cache_values.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/islamic_section/hisn_azkar/domain/entities/hisn_chapter_entity.dart';

class HisnReadingView extends StatefulWidget {
  const HisnReadingView({required this.chapter, super.key});
  final HisnChapterEntity chapter;

  @override
  State<HisnReadingView> createState() => _HisnReadingViewState();
}

class _HisnReadingViewState extends State<HisnReadingView> {
  double _fontSize = 18;
  @override
  void initState() {
    super.initState();
    _fontSize =
        (CacheHelper.getData(CacheKeys.hisnFontSize) as num?)?.toDouble() ?? 18;
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
      key: CacheKeys.hisnFontSize,
      value: _fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75.h,
          title: Text(
            widget.chapter.title,
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

            20.horizontalSpace,
          ],
        ),
        body: SafeArea(
          child: ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: widget.chapter.texts.length,
            separatorBuilder: (context, index) => 16.verticalSpace,
            itemBuilder: (context, index) {
              final text = widget.chapter.texts[index];

              final footnote = (index < widget.chapter.footnotes.length)
                  ? widget.chapter.footnotes[index]
                  : null;

              return Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: AppColors.thirdColor,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: AppTextStyle.style18W800.copyWith(
                        fontFamily: AppFonts.amiri,
                        fontSize: _fontSize.sp,
                        color: AppColors.primaryColor,
                        height: 1.8,
                      ),
                      textAlign: TextAlign.justify,
                    ),

                    if (footnote != null && footnote.isNotEmpty) ...[
                      16.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withAlpha(10),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          footnote,
                          style: AppTextStyle.style9W300.copyWith(
                            color: AppColors.primaryColor,
                            fontFamily: AppFonts.ar,

                            fontSize: (_fontSize - 10).sp,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
