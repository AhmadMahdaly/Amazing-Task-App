import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/bloc_observer.dart';
import 'package:s/core/functions/navigation_preferences.dart';

// import 'package:window_manager/window_manager.dart';

import '/core/di.dart';
import '../cache_helper/cache_helper.dart';
import '../routing/router_generation_config.dart';
import '../services/task_notification_service.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  // if (Platform.isWindows) {
  //   await windowManager.ensureInitialized();
  //   const windowOptions = WindowOptions(
  //     size: Size(660, 980),
  //     minimumSize: Size(660, 980),
  //     center: true,
  //     backgroundColor: Colors.white,
  //     titleBarStyle: TitleBarStyle.normal,
  //     title: 'TSX',
  //     windowButtonVisibility: true,
  //   );
  //   await windowManager.waitUntilReadyToShow(windowOptions, () async {
  //     await windowManager.setResizable(true);
  //     await windowManager.show();
  //     await windowManager.focus();
  //   });
  // }
  await CacheHelper.init();

  await setupGetIt();
  initRouter();
  if (Platform.isAndroid || Platform.isIOS) {
    await NavigationPreferences.init();
    await getIt<TaskNotificationService>().initialize();
  }

  Bloc.observer = MyBlocObserver();
}
