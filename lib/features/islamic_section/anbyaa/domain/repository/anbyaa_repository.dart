import 'package:s/features/islamic_section/anbyaa/domain/entities/anbyaa.dart';

abstract class AnbyaaRepository {
  Future<List<Anbyaa>> getAll();
}
