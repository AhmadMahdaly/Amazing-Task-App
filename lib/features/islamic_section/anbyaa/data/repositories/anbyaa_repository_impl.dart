// data/repositories/asmaa_repository_impl.dart
import 'package:s/features/islamic_section/anbyaa/data/data_source/anbyaa_local_data_source.dart';
import 'package:s/features/islamic_section/anbyaa/domain/entities/anbyaa.dart';
import 'package:s/features/islamic_section/anbyaa/domain/repository/anbyaa_repository.dart';

class AnbyaaRepositoryImpl implements AnbyaaRepository {
  AnbyaaRepositoryImpl(this.localDataSource);
  final AnbyaaLocalDataSource localDataSource;

  @override
  Future<List<Anbyaa>> getAll() async {
    return localDataSource.getAll();
  }
}
