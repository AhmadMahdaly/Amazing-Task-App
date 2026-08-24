// ignore_for_file: discarded_futures

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:s/core/di.dart';
import 'package:s/features/ai_tracker/domain/entities/ai_tracker_entities.dart';
import 'package:s/features/ai_tracker/presentation/cubit/ai_tracker_cubit.dart';
import 'package:s/features/ai_tracker/presentation/views/add_email_view.dart';
import 'package:s/features/ai_tracker/presentation/views/add_platform_view.dart';
import 'package:s/features/ai_tracker/presentation/views/ai_tracker_main_view.dart';
import 'package:s/features/ai_tracker/presentation/views/platform_details_view.dart';
import 'package:s/features/analytics/presentation/views/analytics_screen.dart';
import 'package:s/features/challenges/presentation/screens/add_challenge_screen.dart';
import 'package:s/features/challenges/presentation/screens/analysis_screen.dart';
import 'package:s/features/challenges/presentation/screens/challenges_screen.dart';
import 'package:s/features/day_schedule/presentation/views/day_schedule_screen.dart';
import 'package:s/features/my_app/backup_screen.dart';
import 'package:s/features/notes/domain/entities/note_entity.dart';
import 'package:s/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:s/features/notes/presentation/views/add_edit_note_view.dart';
import 'package:s/features/notes/presentation/views/journal_view.dart';
import 'package:s/features/notes/presentation/views/notes_view.dart';
import 'package:s/features/planner/planner_screen.dart';
import 'package:s/features/task_management/presentation/views/main_tasks_screen.dart';
import 'package:s/features/task_management/presentation/views/task_detail_screen.dart';

import '../../features/my_app/splash/splash_view.dart';
import '../constants.dart';
import 'app_routes.dart';

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
        path: AppRoutes.dayScheduleScreen,
        name: AppRoutes.dayScheduleScreen,
        builder: (context, state) => const DayScheduleScreen(),
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
        path: AppRoutes.aiTrackerMainView,
        name: AppRoutes.aiTrackerMainView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<AiTrackerCubit>()..loadTrackerData(),
            child: const AiTrackerMainView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.platformDetailsView,
        name: AppRoutes.platformDetailsView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<AiTrackerCubit>(),
            child: PlatformDetailsView(
              platform: state.extra! as AiPlatformEntity,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addEmailView,
        name: AppRoutes.addEmailView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<AiTrackerCubit>(),
            child: const AddEmailView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addPlatformView,
        name: AppRoutes.addPlatformView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<AiTrackerCubit>(),
            child: const AddPlatformView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.noteView,
        name: AppRoutes.noteView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<NotesCubit>()..getAllNotes(),
            child: const NotesView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.journalView,
        name: AppRoutes.journalView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<NotesCubit>(),
            child: JournalView(
              note: state.extra! as NoteEntity,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.addEditNoteView,
        name: AppRoutes.addEditNoteView,
        builder: (context, state) {
          final note = state.extra as NoteEntity?;
          return BlocProvider.value(
            value: getIt<NotesCubit>(),
            child: AddEditNoteView(
              note: note,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.backupScreen,
        name: AppRoutes.backupScreen,
        builder: (context, state) {
          return const BackupScreen();
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
