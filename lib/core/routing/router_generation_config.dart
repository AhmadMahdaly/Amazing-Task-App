import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/di.dart';
import 'package:s/features/analytics/presentation/views/analytics_screen.dart';
import 'package:s/features/challenges/presentation/screens/add_challenge_screen.dart';
import 'package:s/features/challenges/presentation/screens/analysis_screen.dart';
import 'package:s/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:s/features/missed_prayers/domain/entities/missed_prayers_entity.dart';
import 'package:s/features/missed_prayers/presentation/cubit/missed_prayers_cubit.dart';
import 'package:s/features/missed_prayers/presentation/views/missed_prayers_wrapper_view.dart';
import 'package:s/features/missed_prayers/presentation/views/settings_calculation_view.dart';
import 'package:s/features/planner/planner_screen.dart';
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
        path: AppRoutes.plannerView,
        name: AppRoutes.plannerView,
        builder: (context, state) => const PlannerScreen(),
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

      GoRoute(
        path: AppRoutes.missedPrayersScreen,
        name: AppRoutes.missedPrayersScreen,
        builder: (context, state) => BlocProvider<MissedPrayersCubit>.value(
          value: getIt<MissedPrayersCubit>(),
          child: const MissedPrayersWrapperView(),
        ),
      ),

      GoRoute(
        path: AppRoutes.settingsCalculationView,
        name: AppRoutes.settingsCalculationView,
        builder: (context, state) {
          final currentData = state.extra! as MissedPrayersEntity;
          return BlocProvider<MissedPrayersCubit>.value(
            value: getIt<MissedPrayersCubit>(),
            child: SettingsCalculationView(currentData: currentData),
          );
        },
      ),
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
