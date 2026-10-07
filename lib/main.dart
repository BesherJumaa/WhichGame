import 'package:flutter/material.dart';
import 'package:whichgame/app.dart';
import 'package:whichgame/data/local/app_storage.dart';
import 'package:whichgame/presentation/app_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final controller = AppController(storage: AppStorage());
  await controller.initialize();

  runApp(WhichGameApp(controller: controller));
}
