import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/resources/app_colors.dart';
import 'package:s/core/resources/app_fonts.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/core/shared_widgets/custom_progress_indicator.dart';
import 'package:s/features/ai_tracker/presentation/cubit/ai_tracker_cubit.dart';

class AddEmailView extends StatefulWidget {
  const AddEmailView({super.key});

  @override
  State<AddEmailView> createState() => _AddEmailViewState();
}

class _AddEmailViewState extends State<AddEmailView> {
  final TextEditingController _emailController = TextEditingController();

  final List<String> _selectedPlatformsIds = [];

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _saveEmail() {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برجاء إدخال البريد الإلكتروني'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPlatformsIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('برجاء اختيار منصة واحدة على الأقل'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<AiTrackerCubit>().addEmailWithPlatforms(
      _emailController.text.trim(),
      _selectedPlatformsIds,
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
            'إضافة إيميل جديد',
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomPrimaryTextfield(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                text: 'البريد الإلكتروني',

                prefix: const Icon(Icons.email_outlined),
              ),
              24.verticalSpace,

              Text(
                'المنصات المسجل بها:',
                style: AppTextStyle.style16W900.copyWith(
                  fontFamily: AppFonts.ar,
                ),
              ),
              12.verticalSpace,

              BlocBuilder<AiTrackerCubit, AiTrackerState>(
                builder: (context, state) {
                  if (state is AiTrackerLoaded) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: state.availablePlatforms.map((platform) {
                        final isSelected = _selectedPlatformsIds.contains(
                          platform.id,
                        );

                        return FilterChip(
                          label: Text(
                            platform.name,
                            style: AppTextStyle.style16W300.copyWith(
                              fontFamily: AppFonts.ar,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: Theme.of(
                            context,
                          ).primaryColor.withAlpha(50),
                          checkmarkColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedPlatformsIds.add(platform.id);
                              } else {
                                _selectedPlatformsIds.remove(platform.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  }
                  return const Center(child: LoadingWidget());
                },
              ),

              const Spacer(),

              CustomPrimaryButton(
                width: double.infinity,
                onPressed: _saveEmail,
                text: 'حفظ الإيميل',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
