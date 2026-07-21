// data/repositories/asmaa_repository_impl.dart
import 'package:s/features/islamic_section/tabeen/data/data_source/tabeen_local_data_source.dart';
import 'package:s/features/islamic_section/tabeen/domain/entities/tabeen.dart';
import 'package:s/features/islamic_section/tabeen/domain/repository/tabeen_repository.dart';

class TabeenRepositoryImpl implements TabeenRepository {
  TabeenRepositoryImpl(this.localDataSource);
  final TabeenLocalDataSource localDataSource;

  @override
  Future<List<Tabeen>> getAll() async {
    return localDataSource.getAll();
  }
}
