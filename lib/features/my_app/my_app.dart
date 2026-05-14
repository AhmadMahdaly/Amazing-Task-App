// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

import '/../core/di.dart';
import '/../core/localization/s.dart';
import '/../core/responsive/responsive_config.dart';
import '/../core/routing/router_generation_config.dart';
import '/../core/theme/app_themes.dart';
import '../my_app/controller/localization_cubit/localization_cubit.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalizationCubit>(
          create: (context) => getIt<LocalizationCubit>(),
        ),
        BlocProvider(
          create: (_) => getIt<TasksCubit>()..loadTasks(),
        ),
        BlocProvider(
          create: (_) => getIt<ListsCubit>()..loadLists(),
        ),
      ],
      child: BlocBuilder<LocalizationCubit, LocalizationState>(
        builder: (context, localeState) {
          return GestureDetector(
            onTap: () => unfocusScope(context),
            child: MaterialApp.router(
              title: 'My Tasks',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              theme: Appthemes.lightTheme(),
              locale: localeState.locale,
              supportedLocales: S.supportedLocales,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            ),
          );
        },
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
