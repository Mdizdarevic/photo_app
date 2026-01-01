import 'dart:developer' as developer;

class LoggerService {
  // --- Singleton Pattern Implementation ---

  // Private constructor
  LoggerService._internal();

  // The single instance of the class
  static final LoggerService _instance = LoggerService._internal();

  // Factory constructor to return the same instance
  factory LoggerService() {
    return _instance;
  }

  // --- Logging Logic ---

  /// Logs an action to the console and potentially a local database.
  /// requirement: by who, when, and what operation was made.
  void logAction({
    required String userId,
    required String operation,
    String? details,
  }) {
    final DateTime timestamp = DateTime.now();

    // Construct the log message
    final String logMessage =
        'LOG | User: $userId | Time: $timestamp | Action: $operation | Details: ${details ?? "None"}';

    // For now, we print to the developer console.
    // Later, this can also write to your local_db.dart.
    developer.log(logMessage, name: 'com.uca.project.logger');
  }
}