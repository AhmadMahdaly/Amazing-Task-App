// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<String> saveImagePermanently(
  File imageFile,
) async {
  final appDir = await getApplicationDocumentsDirectory();

  final imagesDir = Directory(
    path.join(appDir.path, 'challenge_images'),
  );

  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  final extension = path.extension(imageFile.path);

  final fileName = '${DateTime.now().millisecondsSinceEpoch}$extension';

  final savedImage = await imageFile.copy(
    path.join(imagesDir.path, fileName),
  );

  return savedImage.path;
}
