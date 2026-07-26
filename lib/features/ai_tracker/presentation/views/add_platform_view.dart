import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/features/ai_tracker/presentation/cubit/ai_tracker_cubit.dart';

class AddPlatformView extends StatefulWidget {
  const AddPlatformView({super.key});

  @override
  State<AddPlatformView> createState() => _AddPlatformViewState();
}

class _AddPlatformViewState extends State<AddPlatformView> {
  // متغير لتخزين القيمة سواء تم كتابتها أو اختيارها
  String _enteredPlatformName = '';
  final List<String> _selectedEmailIds = [];

  void _savePlatform() {
    final name = _enteredPlatformName.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برجاء إدخال اسم المنصة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final currentState = context.read<AiTrackerCubit>().state;
    if (currentState is AiTrackerLoaded) {
      if (currentState.availablePlatforms.any(
        (p) => p.name.toLowerCase() == name.toLowerCase(),
      )) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('هذه المنصة مسجلة بالفعل!'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // استدعاء دالة الإضافة الجديدة مع الإيميلات المحددة
    context.read<AiTrackerCubit>().addPlatformWithEmails(
      name,
      _selectedEmailIds,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'إضافة منصة AI',
            style: AppTextStyle.style20W900.copyWith(
              fontFamily: AppFonts.ar,
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
        body: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تفاصيل المنصة',
                style: AppTextStyle.style18W900.copyWith(
                  fontFamily: AppFonts.ar,
                ),
              ),
              16.verticalSpace,

              // استخدام BlocBuilder لجلب المنصات المسجلة للاقتراحات
              BlocBuilder<AiTrackerCubit, AiTrackerState>(
                builder: (context, state) {
                  var existingPlatforms = <String>[];
                  if (state is AiTrackerLoaded) {
                    existingPlatforms = state.availablePlatforms
                        .map((p) => p.name)
                        .toList();
                  }

                  return Autocomplete<String>(
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return existingPlatforms.where((option) {
                        return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    onSelected: (selection) {
                      _enteredPlatformName = selection;
                    },
                    fieldViewBuilder:
                        (
                          context,
                          controller,
                          focusNode,
                          onFieldSubmitted,
                        ) {
                          // تتبع النص المكتوب يدوياً
                          controller.addListener(() {
                            _enteredPlatformName = controller.text;
                          });

                          return CustomPrimaryTextfield(
                            controller: controller,
                            focusNode: focusNode,
                            text: 'اسم المنصة (مثال: ChatGPT)',
                            prefix: const Icon(Icons.smart_toy_outlined),
                          );
                        },
                  );
                },
              ),
              24.verticalSpace,
              Text(
                'الإيميلات المسجلة بها:',
                style: AppTextStyle.style16W600.copyWith(
                  fontFamily: AppFonts.ar,
                ),
              ),
              8.verticalSpace,

              // قائمة اختيار الإيميلات
              Expanded(
                child: BlocBuilder<AiTrackerCubit, AiTrackerState>(
                  builder: (context, state) {
                    if (state is AiTrackerLoaded && state.emails.isNotEmpty) {
                      return ListView.builder(
                        itemCount: state.emails.length,
                        itemBuilder: (context, index) {
                          final email = state.emails[index];
                          final isSelected = _selectedEmailIds.contains(
                            email.id,
                          );

                          return CheckboxListTile(
                            title: Text(
                              email.emailAddress,
                              style: AppTextStyle.style14W500,
                            ),
                            value: isSelected,
                            activeColor: AppColors.primaryColor,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedEmailIds.add(email.id);
                                } else {
                                  _selectedEmailIds.remove(email.id);
                                }
                              });
                            },
                          );
                        },
                      );
                    }
                    return Text(
                      'لا توجد إيميلات مسجلة بعد',
                      style: AppTextStyle.style14W500.copyWith(
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              16.verticalSpace,
              const Spacer(),

              CustomPrimaryButton(
                width: double.infinity,
                onPressed: _savePlatform,
                text: 'حفظ المنصة',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
