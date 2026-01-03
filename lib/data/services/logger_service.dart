import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LoggerService {
  // --- Singleton Pattern Implementation ---
  LoggerService._internal();
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;

  // --- Logging Logic ---
  /// requirement: by who, when, and what operation was made.
  void logAction({required String userId, required String operation, String? details,}) {
    // 1. "When" - Formatted for readability
    final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // 2. Construct the log message
    final String logMessage = '''
    -----------------------------------
    [AUDIT LOG]
    WHO:       $userId
    WHEN:      $timestamp
    OPERATION: $operation
    DETAILS:   ${details ?? "None"}
    -----------------------------------''';

    // 3. Print to the "Run" tab (Most reliable for Android Studio)
    print(logMessage);

    // 4. Log to the "Logcat" tab (Searchable by name)
    developer.log(logMessage, name: 'com.uca.project.logger');

    FirebaseFirestore.instance.collection('audit_logs').add({
      'userId': userId,
      'operation': operation,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });

  }
}