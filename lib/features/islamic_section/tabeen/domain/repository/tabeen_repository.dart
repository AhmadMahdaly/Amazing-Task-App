import 'package:s/features/islamic_section/tabeen/domain/entities/tabeen.dart';

abstract class TabeenRepository {
  Future<List<Tabeen>> getAll();
}
