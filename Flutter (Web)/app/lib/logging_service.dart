import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

class LoggingService {
  static const String _defaultTag = 'LoggingService';

  static void _log(String type, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log('[$type] $message', name: tag ?? _defaultTag, error: error, stackTrace: stackTrace, time: DateTime.now());
    }
  }

  static void debug(String message, {String? tag}) {
    _log('DEBUG', message, tag: tag);
  }

  static void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag);
  }

  static void warning(String message, {String? tag}) {
    _log('WARNING', message, tag: tag);
  }

  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, tag: tag, error: error, stackTrace: stackTrace);
  }
}
