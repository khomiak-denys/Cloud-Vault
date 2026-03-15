import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app.dart';
import 'api/auth_session.dart';
import 'firebase_options.dart';
import 'state/locale_controller.dart';
import 'state/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.wait([
    appThemeController.init(),
    appLocaleController.init(),
    AuthSession.instance.init(),
  ]);
  runApp(const CloudVaultApp());
}
