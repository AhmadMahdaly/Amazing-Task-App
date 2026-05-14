import 'package:go_router/go_router.dart';
import 'package:s/features/task_management/presentation/views/main_tasks_screen.dart';

import '../../core/constants.dart';
import '../../core/routing/app_routes.dart';
import '../../features/my_app/splash/splash_view.dart';

late final GoRouter appRouter;

void initRouter() {
  appRouter = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splashScreen,
    routes: [
      GoRoute(
        path: AppRoutes.splashScreen,
        name: AppRoutes.splashScreen,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: AppRoutes.mainTasksScreen,
        name: AppRoutes.mainTasksScreen,
        builder: (context, state) => const MainTasksScreen(),
      ),
      // GoRoute(
      //   path: AppRoutes.settingsAndStatsScreen,
      //   name: AppRoutes.settingsAndStatsScreen,
      //   builder: (context, state) => const SettingsAndStatsScreen(),
      // ),
      // GoRoute(
      //   path: AppRoutes.mainLayoutScreen,
      //   name: AppRoutes.mainLayoutScreen,
      //   builder: (context, state) => BlocProvider(
      //     create: (_) => getIt<MainLayoutCubit>(),
      //     child: const MainLayoutView(),
      //   ),
      // ),
      // GoRoute(
      //   path: AppRoutes.loginScreen,
      //   name: AppRoutes.loginScreen,
      //   builder: (context, state) => BlocProvider<AuthCubit>.value(
      //     value: getIt<AuthCubit>(),
      //     child: const AuthScreen(),
      //   ),
      // ),
      // GoRoute(
      //   path: AppRoutes.errorScreen,
      //   name: AppRoutes.errorScreen,
      //   builder: (context, state) {
      //     final args = state.extra! as ErrorScreenArgs;
      //     return ErrorScreen(args: args);
      //   },
      // ),
    ],
  );
}
