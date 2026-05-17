import 'package:go_router/go_router.dart';
import 'package:s/features/analytics/presentation/views/analytics_screen.dart';
import 'package:s/features/challenges/presentation/screens/add_challenge_screen.dart';
import 'package:s/features/challenges/presentation/screens/analysis_screen.dart';
import 'package:s/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:s/features/task_management/presentation/views/main_tasks_screen.dart';
import 'package:s/features/task_management/presentation/views/task_detail_screen.dart';

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
      GoRoute(
        path: AppRoutes.analyticsScreen,
        name: AppRoutes.analyticsScreen,
        builder: (context, state) => const AnalyticsScreen(),
      ),
      GoRoute(
        path: AppRoutes.taskDetailScreen,
        name: AppRoutes.taskDetailScreen,
        builder: (context, state) {
          final taskId = state.pathParameters['taskId']!;
          return TaskDetailScreen(taskId: taskId);
        },
      ),
      GoRoute(
        path: AppRoutes.challengesScreen,
        name: AppRoutes.challengesScreen,
        builder: (context, state) => const ChallengesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addChallengeScreen,
        name: AppRoutes.addChallengeScreen,
        builder: (context, state) => const AddChallengeScreen(),
      ),
      GoRoute(
        path: AppRoutes.challengeAnalysisScreen,
        name: AppRoutes.challengeAnalysisScreen,
        builder: (context, state) => const ChallengeAnalysisScreen(),
      ),
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
