// Nonfunctional requirements:
// Logging of every action has to be implemented: by who, when, and what operation was
// made – 5 points for LO3 Minimum

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LoggerService {
  // --- Singleton Design Pattern Implementation ---

  // 1. Private Constructor:
  // (_internal) makes this constructor private to this file.
  // This prevents other classes from doing "new LoggerService()" and creating multiple instances.
  LoggerService._internal();

  // 2. Private Static Instance:
  // This holds the one and only instance of the class.
  static final LoggerService _instance = LoggerService._internal();

  // 3. Factory Constructor:
  // When someone calls LoggerService(), it doesn't create a new object; it returns the one stored in _instance.
  // Instead of getInstance(), 'factory' is the Dart word for returning an existing instance instead of creating a new one.
  factory LoggerService() => _instance;

  void logAction({required String userId, required String operation, String? details,}) {

    final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final String logMessage = '''
    -----------------------------------
    [AUDIT LOG]
    WHO:       $userId
    WHEN:      $timestamp
    OPERATION: $operation
    DETAILS:   ${details ?? "None"}
    -----------------------------------''';

    print(logMessage);
    developer.log(logMessage, name: 'com.uca.project.logger');

    FirebaseFirestore.instance.collection('audit_logs').add({
      'userId': userId,
      'operation': operation,
      'details': details,
      'timestamp': FieldValue.serverTimestamp(),
    });

  }
}