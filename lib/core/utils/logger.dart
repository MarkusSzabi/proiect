import 'package:logger/logger.dart';

class AppLogger {
  static late Logger _logger;

  static void init() {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  static void debug(dynamic message, [dynamic error, StackTrace? stack]) =>
      _logger.d(message, error: error, stackTrace: stack);

  static void info(dynamic message, [dynamic error, StackTrace? stack]) =>
      _logger.i(message, error: error, stackTrace: stack);

  static void warning(dynamic message, [dynamic error, StackTrace? stack]) =>
      _logger.w(message, error: error, stackTrace: stack);

  static void error(dynamic message, [dynamic error, StackTrace? stack]) =>
      _logger.e(message, error: error, stackTrace: stack);
}