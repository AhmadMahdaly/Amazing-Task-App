import 'package:get_it/get_it.dart';
import 'package:s/features/task_list/data/datasource/lists_local_data_source.dart';
import 'package:s/features/task_list/data/repo/lists_repository_impl.dart';
import 'package:s/features/task_list/domain/repo/lists_repository.dart';
import 'package:s/features/task_list/presentation/controllers/cubit/lists_cubit.dart';
import 'package:s/features/task_management/data/datasource/tasks_local_data_source.dart';
import 'package:s/features/task_management/data/repo/tasks_repository_impl.dart';
import 'package:s/features/task_management/domain/repo/tasks_repository.dart';
import 'package:s/features/task_management/presentation/controllers/cubit/tasks_cubit.dart';

import '../features/my_app/controller/localization_cubit/localization_cubit.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupGetIt() async {
  getIt
    ..registerLazySingleton<LocalizationCubit>(LocalizationCubit.new)
    /// ------------------ < Tasks Feature > ------------------
    ..registerLazySingleton<TasksLocalDataSource>(TasksLocalDataSourceImpl.new)
    ..registerLazySingleton<TasksRepository>(
      () => TasksRepositoryImpl(getIt<TasksLocalDataSource>()),
    )
    ..registerFactory<TasksCubit>(() => TasksCubit(getIt<TasksRepository>()))
    /// ------------------ < Task Lists Feature > ------------------
    ..registerLazySingleton<ListsLocalDataSource>(ListsLocalDataSourceImpl.new)
    ..registerLazySingleton<ListsRepository>(
      () => ListsRepositoryImpl(getIt<ListsLocalDataSource>()),
    )
    ..registerFactory<ListsCubit>(() => ListsCubit(getIt<ListsRepository>()));
}
