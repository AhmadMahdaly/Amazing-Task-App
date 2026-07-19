// ignore_for_file: discarded_futures, omit_local_variable_types

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/cache_helper/cache_helper.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/islamic_section/azkar/presentation/controllers/cubit/azkar_cubit.dart';
import 'package:s/features/islamic_section/azkar/presentation/views/widgets/zekr_item_widget.dart';

class AzkarView extends StatefulWidget {
  const AzkarView({
    required this.azkarType,
    required this.title,
    super.key,
  });
  final AzkarType azkarType;
  final String title;

  @override
  State<AzkarView> createState() => _AzkarViewState();
}

class _AzkarViewState extends State<AzkarView> {
  double _fontSize = 18;
  @override
  void initState() {
    super.initState();
    context.read<AzkarCubit>().getAzkar(widget.azkarType);
    _fontSize =
        (CacheHelper.getData('azkar_font_size') as num?)?.toDouble() ?? 18;
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
      key: 'azkar_font_size',
      value: _fontSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: AppTextStyle.style18W900.copyWith(
              fontFamily: AppFonts.amiri,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          elevation: 0,
          toolbarHeight: 70.h,
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
          child: BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              if (state is AzkarLoading) {
                return const Center(
                  child: LoadingWidget(
                    color: AppColors.primaryColor,
                  ),
                );
              }

              if (state is AzkarError) {
                return Center(
                  child: Text(
                    state.message,
                    style: AppTextStyle.style14W500.copyWith(
                      color: AppColors.errorColor,
                      fontFamily: kPrimaryArFont,
                    ),
                  ),
                );
              }

              if (state is AzkarLoaded) {
                final azkarList = state.azkarCategory.items;
                final counters = state.counters;

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth = constraints.maxWidth > 600
                        ? 600
                        : constraints.maxWidth;

                    return Center(
                      child: SizedBox(
                        width: maxWidth,
                        child: ListView.separated(
                          padding: EdgeInsets.all(16.r),
                          itemCount: azkarList.length,
                          separatorBuilder: (context, index) =>
                              16.verticalSpace,
                          itemBuilder: (context, index) {
                            final zekr = azkarList[index];
                            final currentCount = counters[zekr.id] ?? 0;

                            return ZekrItemWidget(
                              fontSize: _fontSize.sp,
                              zekrText: zekr.zekr,
                              benefit: zekr.benefit,
                              totalCount: zekr.count,
                              currentCount: currentCount,
                              onTap: () {
                                context.read<AzkarCubit>().decrementZekrCount(
                                  zekr.id,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
