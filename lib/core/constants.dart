import 'package:flutter/material.dart';

import '../../core/cache_helper/cache_values.dart';
import '../core/responsive/responsive_config.dart';
import './cache_helper/cache_helper.dart';

final navigatorKey = GlobalKey<NavigatorState>();

final double radius = 30.r;
const kPrimaryEnFont = 'Cairo';
const kPrimaryArFont = 'Cairo';
final bool latinLang =
    !(CacheHelper.getData(CacheKeys.currentLanguage) == 'ar');
