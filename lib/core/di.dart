// ignore_for_file: discarded_futures

import 'package:get_it/get_it.dart';
import 'package:s/core/services/task_notification_service.dart';
import 'package:s/core/wallpaper/wallpaper_cubit.dart';
import 'package:s/core/wallpaper/wallpaper_repository.dart';
import 'package:s/features/ai_tracker/presentation/cubit/ai_tracker_cubit.dart';
import 'package:s/features/challenges/data/datasource/challenges_local_datasource.dart';
import 'package:s/features/challenges/data/repositories/challenge_repository_impl.dart';
import 'package:s/features/challenges/domain/repositories/challenge_repository.dart';
import 'package:s/features/challenges/presentation/cubit/challenge_cubit/challenge_cubit.dart';
import 'package:s/features/islamic_section/anbyaa/data/data_source/anbyaa_local_data_source.dart';
import 'package:s/features/islamic_section/anbyaa/data/repositories/anbyaa_repository_impl.dart';
import 'package:s/features/islamic_section/anbyaa/domain/repository/anbyaa_repository.dart';
import 'package:s/features/islamic_section/anbyaa/presentation/cubit/anbyaa_cubit.dart';
import 'package:s/features/islamic_section/arbaoon/data/data_source/arbaoon_local_data_source.dart';
import 'package:s/features/islamic_section/arbaoon/data/repositories/arbaoon_repository_impl.dart';
import 'package:s/features/islamic_section/arbaoon/domain/repository/arbaoon_repository.dart';
import 'package:s/features/islamic_section/arbaoon/presentation/cubit/arbaoon_cubit.dart';
import 'package:s/features/islamic_section/asmaa/data/datasources/asmaa_local_data_source.dart';
import 'package:s/features/islamic_section/asmaa/data/repositories/asmaa_repository_impl.dart';
import 'package:s/features/islamic_section/asmaa/domain/repositories/asmaa_repository.dart';
import 'package:s/features/islamic_section/asmaa/presentation/cubit/asmaa_cubit.dart';
import 'package:s/features/islamic_section/azkar/data/data_sources/base_azkar_data_source.dart';
import 'package:s/features/islamic_section/azkar/data/repository/azkar_repository_impl.dart';
import 'package:s/features/islamic_section/azkar/domain/repositories/base_azkar_repository.dart';
import 'package:s/features/islamic_section/azkar/presentation/controllers/cubit/azkar_cubit.dart';
import 'package:s/features/islamic_section/friday_sunan/presentation/cubit/friday_sunan_cubit.dart';
import 'package:s/features/islamic_section/hisn_azkar/presentation/cubit/hisn_cubit.dart';
import 'package:s/features/islamic_section/missed_prayers/data/datasource/missed_prayers_local_data_source.dart';
import 'package:s/features/islamic_section/missed_prayers/data/repo/missed_prayers_repository_impl.dart';
import 'package:s/features/islamic_section/missed_prayers/domain/repo/missed_prayers_repository.dart';
import 'package:s/features/islamic_section/missed_prayers/presentation/cubit/missed_prayers_cubit.dart';
import 'package:s/features/islamic_section/notes/data/data_sources/notes_data_source.dart';
import 'package:s/features/islamic_section/notes/presentation/cubit/notes_cubit.dart';
import 'package:s/features/islamic_section/quran/presentation/controllers/audio_cubit/audio_cubit.dart';
import 'package:s/features/islamic_section/quran/presentation/controllers/quran_cubit/quran_cubit.dart';
import 'package:s/features/islamic_section/tabeen/data/data_source/tabeen_local_data_source.dart';
import 'package:s/features/islamic_section/tabeen/data/repositories/tabeen_repository_impl.dart';
import 'package:s/features/islamic_section/tabeen/domain/repository/tabeen_repository.dart';
import 'package:s/features/islamic_section/tabeen/presentation/cubit/tabeen_cubit.dart';
import 'package:s/features/islamic_section/tafsir/presentation/cubit/tafsir_cubit.dart';
import 'package:s/features/task_list/data/datasource/lists_local_data_source.dart';
import 'package:s/features/task_list/data/repo/lists_repository_impl.dart';
import 'package:s/features/task_list/domain/repo/lists_repository.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_management/data/datasource/tasks_local_data_source.dart';
import 'package:s/features/task_management/data/repo/tasks_repository_impl.dart';
import 'package:s/features/task_management/domain/repo/tasks_repository.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupGetIt() async {
  getIt
    ..registerLazySingleton<TaskNotificationService>(
      () => TaskNotificationService.instance,
    )
    ..registerLazySingleton<WallpaperRepository>(WallpaperRepository.new)
    ..registerLazySingleton<WallpaperCubit>(
      () => WallpaperCubit(getIt<WallpaperRepository>())..load(),
    )
    /// ------------------ < Tasks Feature > ------------------
    ..registerLazySingleton<TasksLocalDataSource>(TasksLocalDataSourceImpl.new)
    ..registerLazySingleton<TasksRepository>(
      () => TasksRepositoryImpl(getIt<TasksLocalDataSource>()),
    )
    ..registerFactory<TasksCubit>(
      () => TasksCubit(
        getIt<TasksRepository>(),
        getIt<TaskNotificationService>(),
      ),
    )
    /// ------------------ < Task Lists Feature > ------------------
    ..registerLazySingleton<ListsLocalDataSource>(ListsLocalDataSourceImpl.new)
    ..registerLazySingleton<ListsRepository>(
      () => ListsRepositoryImpl(getIt<ListsLocalDataSource>()),
    )
    ..registerFactory<ListsCubit>(() => ListsCubit(getIt<ListsRepository>()))
    ///
    ..registerLazySingleton<ChallengeLocalDataSource>(
      ChallengeLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<ChallengeRepository>(
      () => ChallengeRepositoryImpl(getIt()),
    )
    ..registerFactory<ChallengeCubit>(() => ChallengeCubit(getIt()))
    ///
    ..registerLazySingleton<MissedPrayersLocalDataSource>(
      MissedPrayersLocalDataSource.new,
    )
    ..registerLazySingleton<MissedPrayersRepository>(
      () => MissedPrayersRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<MissedPrayersCubit>(
      () => MissedPrayersCubit(getIt()),
    )
    ///
    ..registerLazySingleton<BaseAzkarDataSource>(
      AzkarLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<BaseAzkarRepository>(
      () => AzkarRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<AzkarCubit>(() => AzkarCubit(getIt()))
    ..registerLazySingleton<QuranCubit>(QuranCubit.new)
    ..registerLazySingleton<HisnCubit>(HisnCubit.new)
    ..registerLazySingleton<TafsirCubit>(TafsirCubit.new)
    ..registerLazySingleton<AsmaaLocalDataSource>(
      AsmaaLocalDataSource.new,
    )
    ..registerLazySingleton<AsmaaRepository>(
      () => AsmaaRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<AsmaaCubit>(() => AsmaaCubit(getIt()))
    ///
    ..registerLazySingleton<ArbaoonLocalDataSource>(
      ArbaoonLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<ArbaoonRepository>(
      () => ArbaoonRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<ArbaoonCubit>(() => ArbaoonCubit(getIt()))
    ..registerLazySingleton<TabeenLocalDataSource>(
      TabeenLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<TabeenRepository>(
      () => TabeenRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<TabeenCubit>(() => TabeenCubit(getIt()))
    ..registerLazySingleton<AnbyaaLocalDataSource>(
      AnbyaaLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<AnbyaaRepository>(
      () => AnbyaaRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<AnbyaaCubit>(() => AnbyaaCubit(getIt()))
    ..registerLazySingleton<NotesDataSource>(NotesDataSource.new)
    ..registerLazySingleton<NotesCubit>(() => NotesCubit(getIt()))
    ///
    ..registerLazySingleton<AiTrackerCubit>(AiTrackerCubit.new)
    ..registerLazySingleton<FridaySunnahCubit>(FridaySunnahCubit.new)
    ..registerLazySingleton<AudioCubit>(AudioCubit.new);
}
