// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:s/core/resources/app_text.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/features/challenges/presentation/cubit/challenge_cubit/challenge_cubit.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

import '/core/di.dart';
import '/core/responsive/responsive_config.dart';
import '/core/routing/router_generation_config.dart';
import '../../core/resources/app_themes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<TasksCubit>()..loadTasks(),
        ),
        BlocProvider(
          create: (_) => getIt<ListsCubit>()..loadLists(),
        ),
        BlocProvider.value(
          value: getIt<WallpaperCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<ChallengeCubit>()..loadChallenges(),
        ),
      ],
      child: GestureDetector(
        onTap: () => unfocusScope(context),
        child: MaterialApp.router(
          title: AppTexts.appTitle,
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          theme: Appthemes.lightTheme(),
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: child!,
            );
          },
        ),
      ),
    );
  }
}

void unfocusScope(BuildContext context) {
  final currentFocus = FocusScope.of(context);
  if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
    currentFocus.unfocus();
  }
}

class GlobalVariable {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void showMessage(String msg, {bool isError = false}) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
