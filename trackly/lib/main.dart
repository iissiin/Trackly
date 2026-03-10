import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  runApp(const Trackly());
}

class Trackly extends StatelessWidget {
  const Trackly({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp();
  }
}
