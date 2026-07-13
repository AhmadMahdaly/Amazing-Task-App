import 'package:dartz/dartz.dart';
import 'package:s/core/utils/failure.dart';
import 'package:s/features/islamic_section/islamic_home/domain/entities/azkar_category_entity.dart';

abstract class BaseAzkarRepository {
  Future<Either<Failure, AzkarCategoryEntity>> getMorningAzkar();
  Future<Either<Failure, AzkarCategoryEntity>> getEveningAzkar();
  Future<Either<Failure, AzkarCategoryEntity>> getSleepingAzkar();
}
