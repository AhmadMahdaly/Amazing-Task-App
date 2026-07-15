import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/constants.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/features/islamic_section/hisn_azkar/domain/entities/hisn_chapter_entity.dart';

class HisnReadingView extends StatelessWidget {
  const HisnReadingView({required this.chapter, super.key});
  final HisnChapterEntity chapter;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75.h,
          title: Text(
            chapter.title,
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
        ),
        body: SafeArea(
          child: ListView.separated(
            padding: EdgeInsets.all(16.r),
            itemCount: chapter.texts.length,
            separatorBuilder: (context, index) => 16.verticalSpace,
            itemBuilder: (context, index) {
              final text = chapter.texts[index];

              final footnote = (index < chapter.footnotes.length)
                  ? chapter.footnotes[index]
                  : null;

              return Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: AppColors.buttonColor.withAlpha(100),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.thirdColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          footnote,
                          style: AppTextStyle.style9W500.copyWith(
                            color: AppColors.thirdColor,
                            fontFamily: kPrimaryArFont,
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
