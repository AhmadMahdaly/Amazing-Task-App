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
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _savePlatform() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برجاء إدخال اسم المنصة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AiTrackerCubit>().addPlatform(name);

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

              CustomPrimaryTextfield(
                controller: _nameController,
                text: 'اسم المنصة (مثال: ChatGPT)',
                prefix: const Icon(Icons.smart_toy_outlined),
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
