import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiToken {
    return dotenv.env['API_KEY'] ?? 'API_KEY not found';
  }

  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }
}
