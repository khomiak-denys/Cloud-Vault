import 'package:flutter/material.dart';

import 'app.dart';
import 'state/locale_controller.dart';
import 'state/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([appThemeController.init(), appLocaleController.init()]);
  runApp(const CloudVaultApp());
}
