import 'package:s/features/islamic_section/arbaoon/domain/entities/hadith.dart';

abstract class ArbaoonRepository {
  Future<List<Hadith>> getHadiths();
}
