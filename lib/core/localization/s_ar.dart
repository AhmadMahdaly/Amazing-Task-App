// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 's.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class SAr extends S {
  SAr([String locale = 'ar']) : super(locale);

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get lang => 'En';

  @override
  String get skip => 'تخطى';

  @override
  String get next => 'التالى';

  @override
  String get onboard1Title => 'مرحبًا بك في تطبيقنا';

  @override
  String get onboard1Desc => 'اكتشف ميزاتنا الرائعة وسهولة الاستخدام.';

  @override
  String get onboard2Title => 'ابق على اتصال';

  @override
  String get onboard2Desc => 'تواصل مع أصدقائك وعائلتك بسهولة.';

  @override
  String get onboard3Title => 'ابدأ الآن';

  @override
  String get onboard3Desc => 'قم بالتسجيل وابدأ رحلتك معنا اليوم!';

  @override
  String get home => 'الرئيسية';

  @override
  String get search => 'بحث';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get services => 'الخدمات';

  @override
  String get support => 'الدعم';

  @override
  String get error => 'خطأ';

  @override
  String get somethingWentWrong => 'حدث خطأ ما!';

  @override
  String get goBack => 'الرجوع';

  @override
  String get updateStatus => 'تحديث الحالة';

  @override
  String get serverMaintenanceMessage =>
      'نواجه حالياً بعض التحديثات في السيرفر لتحسين الخدمة.\nيرجى المحاولة مرة أخرى بعد قليل.';

  @override
  String get underMaintenance => 'تحت الصيانة';
}
