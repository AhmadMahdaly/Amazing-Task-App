import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:s/features/islamic_section/islamic_home/data/models/azkar_category_model.dart';

abstract class BaseAzkarDataSource {
  Future<AzkarCategoryModel> getMorningAzkar();
  Future<AzkarCategoryModel> getEveningAzkar();
  Future<AzkarCategoryModel> getSleepingAzkar();
}

class AzkarLocalDataSourceImpl implements BaseAzkarDataSource {
  @override
  Future<AzkarCategoryModel> getMorningAzkar() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/morning_zekr.json',
      );

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      return AzkarCategoryModel.fromJson(jsonMap);
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل أذكار الصباح: $e');
    }
  }

  @override
  Future<AzkarCategoryModel> getEveningAzkar() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/evening_zekr.json',
      );

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      return AzkarCategoryModel.fromJson(jsonMap);
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل أذكار المساء: $e');
    }
  }

  @override
  Future<AzkarCategoryModel> getSleepingAzkar() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/sleeping_zekr.json',
      );

      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

      return AzkarCategoryModel.fromJson(jsonMap);
    } catch (e) {
      throw Exception('حدث خطأ أثناء تحميل أذكار النوم: $e');
    }
  }
}
