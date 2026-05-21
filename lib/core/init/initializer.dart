import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/bloc_observer.dart';
import 'package:s/core/utils/home_widget_helper.dart';

import '/../core/di.dart';
import '../../core/routing/router_generation_config.dart';
import '../cache_helper/cache_helper.dart';
import '../services/task_notification_service.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await HomeWidgetHelper.initialize();
  await CacheHelper.init();
  initRouter();
  await setupGetIt();
  await getIt<TaskNotificationService>().initialize();
  Bloc.observer = MyBlocObserver();
}
