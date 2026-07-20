// data/repositories/asmaa_repository_impl.dart
import 'package:s/features/islamic_section/arbaoon/data/data_source/arbaoon_local_data_source.dart';
import 'package:s/features/islamic_section/arbaoon/domain/entities/hadith.dart';
import 'package:s/features/islamic_section/arbaoon/domain/repository/arbaoon_repository.dart';

class ArbaoonRepositoryImpl implements ArbaoonRepository {
  ArbaoonRepositoryImpl(this.localDataSource);
  final ArbaoonLocalDataSource localDataSource;

  @override
  @override
  Future<List<Hadith>> getHadiths() async {
    return localDataSource.getHadiths();
  }
}
