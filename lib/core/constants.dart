import 'package:flutter/material.dart';

import '../core/responsive/responsive_config.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final double radius = 12.r;
const String appSound = 'audio/notification.mp3';
const appGooglePlayUrl =
    'https://play.google.com/store/apps/details?id=com.mahdaly.my_task';
const kPrimaryEnFont = 'Almarai';
const kPrimaryArFont = 'IBMPlexSansArabic';

class AppFonts {
  static String en = kPrimaryEnFont;
  static String ar = kPrimaryArFont;
  static String amiri = 'Amiri';
}
