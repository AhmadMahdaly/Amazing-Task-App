import 'package:flutter/material.dart';

import '/../core/init/initializer.dart';
import '/../features/my_app/my_app.dart';

void main() async {
  await initializeApp();
  runApp(const MyApp());
}
