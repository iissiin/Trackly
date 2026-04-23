import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:trackly/core/router/router.dart';
import 'package:trackly/firebase_options.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load();
    AppLogger.info('main: .env загружен');
  } catch (_) {
    AppLogger.warning(
      'main: .env файл не найден — используем значения по умолчанию',
    );
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const Trackly());
}

class Trackly extends StatelessWidget {
  const Trackly({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
