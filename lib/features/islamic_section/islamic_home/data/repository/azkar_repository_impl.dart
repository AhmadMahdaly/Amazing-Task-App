import 'package:dartz/dartz.dart';
import 'package:s/core/utils/failure.dart';
import 'package:s/features/islamic_section/islamic_home/data/data_sources/base_azkar_data_source.dart';
import 'package:s/features/islamic_section/islamic_home/domain/entities/azkar_category_entity.dart';
import 'package:s/features/islamic_section/islamic_home/domain/repositories/base_azkar_repository.dart';

class AzkarRepositoryImpl implements BaseAzkarRepository {
  AzkarRepositoryImpl(this.baseAzkarDataSource);
  final BaseAzkarDataSource baseAzkarDataSource;

  @override
  Future<Either<Failure, AzkarCategoryEntity>> getMorningAzkar() async {
    try {
      final result = await baseAzkarDataSource.getMorningAzkar();

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AzkarCategoryEntity>> getEveningAzkar() async {
    try {
      final result = await baseAzkarDataSource.getEveningAzkar();

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AzkarCategoryEntity>> getSleepingAzkar() async {
    try {
      final result = await baseAzkarDataSource.getSleepingAzkar();

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
