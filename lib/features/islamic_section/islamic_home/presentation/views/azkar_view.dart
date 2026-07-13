// ignore_for_file: omit_local_variable_types

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/islamic_section/islamic_home/presentation/controllers/cubit/azkar_cubit.dart';
import 'package:s/features/islamic_section/islamic_home/presentation/views/widgets/zekr_item_widget.dart';

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
  @override
  void initState() {
    super.initState();
    context.read<AzkarCubit>().getAzkar(widget.azkarType);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: AppTextStyle.style16Bold.copyWith(
              fontFamily: kPrimaryArFont,
            ),
          ),
          backgroundColor: AppColors.primaryColor,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AzkarCubit, AzkarState>(
            builder: (context, state) {
              if (state is AzkarLoading) {
                return const Center(
                  child: CircularProgressIndicator(
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
