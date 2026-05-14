part of 'localization_cubit.dart';

class LocalizationState extends Equatable {
  const LocalizationState({required this.locale});
  final Locale locale;

  @override
  List<Object> get props => [locale];
}
