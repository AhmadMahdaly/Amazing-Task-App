// data/repositories/asmaa_repository_impl.dart
import 'package:s/features/islamic_section/asmaa/data/datasources/asmaa_local_data_source.dart';
import 'package:s/features/islamic_section/asmaa/domain/entities/asmaa_lesson.dart';
import 'package:s/features/islamic_section/asmaa/domain/repositories/asmaa_repository.dart';

class AsmaaRepositoryImpl implements AsmaaRepository {
  AsmaaRepositoryImpl(this.localDataSource);
  final AsmaaLocalDataSource localDataSource;

  @override
  @override
  Future<List<AsmaaLesson>> getAsmaaLessons() async {
    return localDataSource.fetchAndParseLessons();
  }
}
