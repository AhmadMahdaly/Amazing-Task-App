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
import 'package:s/features/notes/data/datasources/base_note_local_data_source.dart';
import 'package:s/features/notes/data/datasources/note_local_data_source_impl.dart';
import 'package:s/features/notes/data/repositories/notes_repository_impl.dart';
import 'package:s/features/notes/domain/repositories/base_notes_repository.dart';
import 'package:s/features/notes/presentation/cubit/notes_cubit.dart';
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
    ..registerLazySingleton<BaseNoteLocalDataSource>(
      NoteLocalDataSourceImpl.new,
    )
    ..registerLazySingleton<BaseNotesRepository>(
      () => NotesRepositoryImpl(getIt()),
    )
    ..registerLazySingleton<NotesCubit>(
      () => NotesCubit(getIt()),
    )
    ..registerLazySingleton<AiTrackerCubit>(AiTrackerCubit.new);
}
