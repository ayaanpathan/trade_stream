import 'package:flutter_dotenv/flutter_dotenv.dart';

/// A utility class for managing environment variables.
class Env {
  /// Initializes the environment variables by loading them from a .env file.
  ///
  /// This method should be called before accessing any environment variables.
  /// It loads the variables from a file named ".env" in the project root.
  ///
  /// Throws a [FileSystemException] if the .env file is not found or cannot be read.
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  /// Retrieves the API URL from the environment variables.
  ///
  /// Returns the value of the 'API_URL' environment variable.
  /// If the variable is not set, it returns the string 'API_URL not found'.
  static String get apiUrl {
    return dotenv.env['API_URL'] ?? 'API_URL not found';
  }

  /// Retrieves the API key from the environment variables.
  ///
  /// Returns the value of the 'API_KEY' environment variable.
  /// If the variable is not set, it returns the string 'API_KEY not found'.
  static String get apiKey {
    return dotenv.env['API_KEY'] ?? 'API_KEY not found';
  }
}
