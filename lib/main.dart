import 'package:flutter/material.dart';

import 'app.dart';
import 'state/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appThemeController.init();
  runApp(const CloudVaultApp());
}
