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
import 'package:s/features/islamic_section/arbaoon/domain/entities/hadith.dart';
import 'package:s/features/islamic_section/arbaoon/presentation/cubit/arbaoon_cubit.dart';
import 'package:s/features/islamic_section/arbaoon/presentation/views/arbaoon_index_view.dart';
import 'package:s/features/islamic_section/arbaoon/presentation/views/arbaoon_reading_view.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_lesson.dart';
import 'package:s/features/islamic_section/asmaa/presentation/cubit/asmaa_cubit.dart';
import 'package:s/features/islamic_section/asmaa/presentation/views/asmaa_index_view.dart';
import 'package:s/features/islamic_section/asmaa/presentation/views/asmaa_reading_view.dart';
import 'package:s/features/islamic_section/azkar/presentation/controllers/cubit/azkar_cubit.dart';
import 'package:s/features/islamic_section/azkar/presentation/views/azkar_view.dart';
import 'package:s/features/islamic_section/friday_sunan/presentation/views/friday_sunan_view.dart';
import 'package:s/features/islamic_section/hisn_azkar/domain/entities/hisn_chapter_entity.dart';
import 'package:s/features/islamic_section/hisn_azkar/presentation/cubit/hisn_cubit.dart';
import 'package:s/features/islamic_section/hisn_azkar/presentation/views/hisn_index_view.dart';
import 'package:s/features/islamic_section/hisn_azkar/presentation/views/hisn_reading_view.dart';
import 'package:s/features/islamic_section/islamic_home/presentation/views/islamic_home.dart';
import 'package:s/features/islamic_section/islamic_home/presentation/views/sirah_view.dart';
import 'package:s/features/islamic_section/missed_prayers/domain/entities/missed_prayers_entity.dart';
import 'package:s/features/islamic_section/missed_prayers/presentation/cubit/missed_prayers_cubit.dart';
import 'package:s/features/islamic_section/missed_prayers/presentation/views/missed_prayers_wrapper_view.dart';
import 'package:s/features/islamic_section/missed_prayers/presentation/views/settings_calculation_view.dart';
import 'package:s/features/islamic_section/notes/presentation/cubit/notes_cubit.dart';
import 'package:s/features/islamic_section/notes/presentation/utils/notes_section_type.dart';
import 'package:s/features/islamic_section/notes/presentation/views/unified_notes_view.dart';
import 'package:s/features/islamic_section/quran/domain/entities/surah_entity.dart';
import 'package:s/features/islamic_section/quran/presentation/cubit/quran_cubit.dart';
import 'package:s/features/islamic_section/quran/presentation/views/quran_index_view.dart';
import 'package:s/features/islamic_section/quran/presentation/views/surah_reading_view.dart';
import 'package:s/features/islamic_section/tabeen/domain/entities/tabeen.dart';
import 'package:s/features/islamic_section/tabeen/presentation/cubit/tabeen_cubit.dart';
import 'package:s/features/islamic_section/tabeen/presentation/views/tabeen_index_view.dart';
import 'package:s/features/islamic_section/tabeen/presentation/views/tabeen_reading_view.dart';
import 'package:s/features/islamic_section/tafsir/presentation/cubit/tafsir_cubit.dart';
import 'package:s/features/islamic_section/tafsir/presentation/views/tafsir_index_view.dart';
import 'package:s/features/islamic_section/tafsir/presentation/views/tafsir_reading_view.dart';
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
        path: AppRoutes.islamicHomeView,
        name: AppRoutes.islamicHomeView,
        builder: (context, state) => const IslamicHomeView(),
      ),
      GoRoute(
        path: AppRoutes.sirahView,
        name: AppRoutes.sirahView,
        builder: (context, state) => const SirahView(),
      ),
      GoRoute(
        path: AppRoutes.azkarView,
        name: AppRoutes.azkarView,
        builder: (context, state) {
          final data = state.extra! as Map;
          return BlocProvider.value(
            value: getIt<AzkarCubit>(),
            child: AzkarView(
              azkarType: data['azkarType'] as AzkarType,
              title: data['title'] as String,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.missedPrayersScreen,
        name: AppRoutes.missedPrayersScreen,
        builder: (context, state) => BlocProvider<MissedPrayersCubit>.value(
          value: getIt<MissedPrayersCubit>()..loadPrayersData(),
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
      GoRoute(
        path: AppRoutes.quranIndexView,
        name: AppRoutes.quranIndexView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<QuranCubit>()..loadSurahs(),
            child: const QuranIndexView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.surahReadingView,
        name: AppRoutes.surahReadingView,
        builder: (context, state) {
          final data = state.extra! as Map;
          final surah = data['surah'] as SurahEntity;
          final startAyah = data['startAyah'] as int?;
          return BlocProvider.value(
            value: getIt<QuranCubit>(),
            child: SurahReadingView(surah: surah, startAyah: startAyah),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.hisnIndexView,
        name: AppRoutes.hisnIndexView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<HisnCubit>()..loadHisnData(),
            child: const HisnIndexView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.hisnReadingView,
        name: AppRoutes.hisnReadingView,
        builder: (context, state) {
          final chapter = state.extra! as HisnChapterEntity;
          return BlocProvider.value(
            value: getIt<HisnCubit>(),
            child: HisnReadingView(
              chapter: chapter,
            ),
          );
        },
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
        name: AppRoutes.platformDetailsView,
        path: AppRoutes.platformDetailsView,
        builder: (context, state) {
          final platform = state.extra! as AiPlatformEntity;
          return BlocProvider.value(
            value: getIt<AiTrackerCubit>(),
            child: PlatformDetailsView(platform: platform),
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
        path: AppRoutes.asmaaIndexView,
        name: AppRoutes.asmaaIndexView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<AsmaaCubit>()..loadLessons(),
            child: const AsmaaIndexView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.asmaaReadingView,
        name: AppRoutes.asmaaReadingView,
        builder: (context, state) {
          final lesson = state.extra! as AsmaaLesson;
          return BlocProvider.value(
            value: getIt<AsmaaCubit>(),
            child: AsmaaReadingView(
              lesson: lesson,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.unifiedNotesView,
        name: AppRoutes.unifiedNotesView,
        builder: (context, state) {
          final sectionType = state.extra! as NotesSectionType;
          return BlocProvider.value(
            value: getIt<NotesCubit>()..loadNotes(sectionType),
            child: UnifiedNotesView(sectionType: sectionType),
          );
        },
      ),

      GoRoute(
        path: AppRoutes.tafsirIndexView,
        name: AppRoutes.tafsirIndexView,
        builder: (context, state) {
          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: getIt<TafsirCubit>()..loadTafsirData(),
              ),
              BlocProvider.value(
                value: getIt<QuranCubit>()..loadSurahs(),
              ),
            ],
            child: const TafsirIndexView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.tafsirReadingView,
        name: AppRoutes.tafsirReadingView,
        builder: (context, state) {
          final surah = state.extra! as SurahEntity;

          return MultiBlocProvider(
            providers: [
              BlocProvider.value(
                value: getIt<TafsirCubit>(),
              ),
              BlocProvider.value(
                value: getIt<QuranCubit>(),
              ),
            ],
            child: TafsirReadingView(
              surah: surah,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.fridaySunanView,
        name: AppRoutes.fridaySunanView,
        builder: (context, state) => const FridaySunanView(),
      ),
      GoRoute(
        path: AppRoutes.arbaoonIndexView,
        name: AppRoutes.arbaoonIndexView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<ArbaoonCubit>()..loadHadiths(),
            child: const ArbaoonIndexView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.arbaoonReadingView,
        name: AppRoutes.arbaoonReadingView,
        builder: (context, state) {
          final hadith = state.extra! as Hadith;
          return BlocProvider.value(
            value: getIt<ArbaoonCubit>(),
            child: ArbaoonReadingView(
              hadith: hadith,
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.tabeenIndexView,
        name: AppRoutes.tabeenIndexView,
        builder: (context, state) {
          return BlocProvider.value(
            value: getIt<TabeenCubit>()..loadTabeen(),
            child: const TabeenIndexView(),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.tabeenReadingView,
        name: AppRoutes.tabeenReadingView,
        builder: (context, state) {
          final tabeen = state.extra! as Tabeen;
          return BlocProvider.value(
            value: getIt<TabeenCubit>(),
            child: TabeenReadingView(
              tabeen: tabeen,
            ),
          );
        },
      ),
      // GoRoute(
      //   path: AppRoutes.arbaoonNotesView,
      //   name: AppRoutes.arbaoonNotesView,
      //   builder: (context, state) {
      //     return const ArbaoonNotesView();
      //   },
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
