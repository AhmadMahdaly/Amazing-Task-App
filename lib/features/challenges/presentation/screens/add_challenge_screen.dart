import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart' as intl;
import 'package:s/core/functions/save_image.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/resources/app_text_style.dart';
import 'package:s/core/responsive/responsive_config.dart';
import 'package:s/core/shared_widgets/custom_dropdown_button.dart';
import 'package:s/core/shared_widgets/custom_primary_button.dart';
import 'package:s/core/shared_widgets/custom_primary_textfield.dart';
import 'package:s/features/challenges/data/models/challenge_model.dart';
import 'package:s/features/challenges/presentation/cubit/challenge_cubit/challenge_cubit.dart';
import 'package:uuid/uuid.dart';

class AddChallengeScreen extends StatefulWidget {
  const AddChallengeScreen({super.key});

  @override
  State<AddChallengeScreen> createState() => _AddChallengeScreenState();
}

class _AddChallengeScreenState extends State<AddChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  ChallengeLevel _selectedLevel = ChallengeLevel.light;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final temporaryImageFile = File(pickedFile.path);
      final permanentPath = await saveImagePermanently(temporaryImageFile);
      setState(() {
        _imageFile = File(permanentPath);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_endDate.isBefore(_startDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppTexts.endDateMustBeInFuture),
          ),
        );
        return;
      }

      final newChallenge = ChallengeModel(
        id: const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        imagePath: _imageFile?.path,
        level: _selectedLevel,
        startDate: _startDate,
        endDate: _endDate,
        status: ChallengeStatus.active,
      );

      await context.read<ChallengeCubit>().addChallenge(newChallenge);
      context.pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppTexts.addNewChallenge),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomPrimaryTextfield(
                controller: _titleController,
                text: AppTexts.whatWillYouDo,
                validator: (value) =>
                    value!.isEmpty ? AppTexts.pleaseEnterTitle : null,
              ),
              16.verticalSpace,

              CustomPrimaryTextfield(
                controller: _descriptionController,
                maxLines: 6,
                text: AppTexts.describeTheChallenge,
                validator: (value) =>
                    value!.isEmpty ? AppTexts.pleaseEnterDescription : null,
              ),
              16.verticalSpace,
              CustomPrimaryTextfield(
                controller: _categoryController,
                text: AppTexts.whichActivityCategory,
                validator: (value) =>
                    value!.isEmpty ? AppTexts.pleaseEnterCategory : null,
              ),
              16.verticalSpace,
              CustomDropdownButtonFormField<ChallengeLevel>(
                value: _selectedLevel,
                hintText: AppTexts.challengeLevel,

                items: ChallengeLevel.values.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(
                      level == ChallengeLevel.light
                          ? AppTexts.light
                          : level == ChallengeLevel.medium
                          ? AppTexts.medium
                          : AppTexts.hard,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLevel = value;
                    });
                  }
                },
              ),
              24.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: _imageFile == null
                        ? Text(AppTexts.noImageSelected)
                        : Image.file(_imageFile!, height: 100),
                  ),
                  TextButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: Text(AppTexts.chooseImage),
                  ),
                ],
              ),
              24.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildDateTimePicker(
                      context: context,
                      label: AppTexts.whenWillItStart,
                      date: _startDate,
                      onChanged: (newDate) {
                        setState(() {
                          _startDate = newDate;
                        });
                      },
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: _buildDateTimePicker(
                      context: context,
                      label: AppTexts.setEndTime,
                      date: _endDate,
                      onChanged: (newDate) {
                        setState(() {
                          _endDate = newDate;
                        });
                      },
                    ),
                  ),
                ],
              ),
              32.verticalSpace,
              CustomPrimaryButton(
                width: double.infinity,
                onPressed: _submitForm,
                text: AppTexts.start,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required String label,
    required DateTime date,
    required ValueChanged<DateTime> onChanged,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyle.style16Bold,
        ),
        8.verticalSpace,
        CustomPrimaryButton(
          onPressed: () async {
            final newDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now().subtract(const Duration(days: 30)),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (newDate == null) return;

            final newTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(date),
            );
            if (newTime == null) return;

            final newDateTime = DateTime(
              newDate.year,
              newDate.month,
              newDate.day,
              newTime.hour,
              newTime.minute,
            );
            onChanged(newDateTime);
          },
          text: intl.DateFormat('MMM, dd yyyy').format(date),
        ),
      ],
    );
  }
}
