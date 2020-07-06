import 'dart:collection';

import 'package:lumberdash/lumberdash.dart';
import 'package:lumberdashui/src/level.dart';
import 'package:lumberdashui/src/log_entry.dart';

class LumberdashUiClient extends LumberdashClient {
  static Queue<LogEntry> queue = Queue<LogEntry>();

  @override
  void logError(exception, [stacktrace]) {
    queue.add(LogEntry(
      time: DateTime.now(),
      level: Level.error,
      exception: exception,
      stacktrace: stacktrace,
    ));
  }

  @override
  void logFatal(String exception, [Map<String, String> stacktrace]) {
    queue.add(LogEntry(
      time: DateTime.now(),
      level: Level.fatal,
      message: exception,
      stacktrace: stacktrace,
    ));
  }

  @override
  void logMessage(String exception, [Map<String, String> stacktrace]) {
    queue.add(LogEntry(
      time: DateTime.now(),
      level: Level.message,
      message: exception,
      stacktrace: stacktrace,
    ));
  }

  @override
  void logWarning(String exception, [Map<String, String> stacktrace]) {
    queue.add(LogEntry(
      time: DateTime.now(),
      level: Level.warning,
      message: exception,
      stacktrace: stacktrace,
    ));
  }
}
