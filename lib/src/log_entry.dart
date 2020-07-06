import 'package:lumberdashui/src/level.dart';

class LogEntry {
  LogEntry({
    this.time,
    this.level,
    this.message,
    this.exception,
    this.stacktrace,
  });

  final Level level;
  final String message;
  final dynamic exception;
  final dynamic stacktrace;
  final DateTime time;

  List<String> get lines {
    return [
      if (time != null) time.toIso8601String(),
      if (message != null) message,
      if (exception != null) exception.toString(),
      if (stacktrace != null) stacktrace.toString(),
    ];
  }
}
