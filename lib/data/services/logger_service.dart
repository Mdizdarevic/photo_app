import 'package:cloud_firestore/cloud_firestore.dart';

// This is my example for ASPECT-ORIENTED PROGRAMMING
// It contains all the cross-cutting concern logic in one single place.
class AuditAspect {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // @Before
  void beforeAdvice(String operation) {
    print("[AOP BEFORE] Starting operation: $operation");
  }

  // @AfterReturning
  void afterReturningAdvice(String userId, String operation, Object? result) {
    print("[AOP AFTER RETURNING] Operation $operation succeeded.");
    _firestore.collection('audit_logs').add({
      'userId': userId,
      'operation': operation,
      'status': 'SUCCESS',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // @AfterThrowing
  void afterThrowingAdvice(String userId, String operation, Object error) {
    print("[AOP AFTER THROWING] Operation $operation failed.");
    _firestore.collection('audit_logs').add({
      'userId': userId,
      'operation': "${operation}_FAILED",
      'status': 'ERROR',
      'details': error.toString(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

abstract interface class IUserService {
  Future<void> deleteUser(String userId);
}

class UserService implements IUserService {
  @override
  Future<void> deleteUser(String userId) async {
    print("Deleting user from database...");
  }
}

class UserServiceAopProxy implements IUserService {
  final IUserService _target; // The clean UserService
  final AuditAspect _aspect;  // The LoggingAspect

  UserServiceAopProxy(this._target, this._aspect);

  @override
  Future<void> deleteUser(String userId) async {
    const String operation = "DELETE_USER";

    _aspect.beforeAdvice(operation);

    try {
      await _target.deleteUser(userId);
      _aspect.afterReturningAdvice(userId, operation, null);

    } catch (error) {
      _aspect.afterThrowingAdvice(userId, operation, error);
      rethrow;
    }
  }
}

// // Nonfunctional requirements:
// // Logging of every action has to be implemented: by who, when, and what operation was
// // made – 5 points for LO3 Minimum
//
// import 'dart:developer' as developer;
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
//
// class LoggerService {
//   // --- Singleton Design Pattern Implementation ---
//
//   // 1. Private Constructor:
//   // (_internal) makes this constructor private to this file.
//   // This prevents other classes from doing "new LoggerService()" and creating multiple instances.
//   LoggerService._internal();
//
//   // 2. Private Static Instance:
//   // This holds the one and only instance of the class.
//   static final LoggerService _instance = LoggerService._internal();
//
//   // 3. Factory Constructor:
//   // When someone calls LoggerService(), it doesn't create a new object; it returns the one stored in _instance.
//   // Instead of getInstance(), 'factory' is the Dart word for returning an existing instance instead of creating a new one.
//   factory LoggerService() => _instance;
//
//   void logAction({required String userId, required String operation, String? details,}) {
//
//     final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
//
//     final String logMessage = '''
//     -----------------------------------
//     [AUDIT LOG]
//     WHO:       $userId
//     WHEN:      $timestamp
//     OPERATION: $operation
//     DETAILS:   ${details ?? "None"}
//     -----------------------------------''';
//
//     print(logMessage);
//     developer.log(logMessage, name: 'com.uca.project.logger');
//
//     FirebaseFirestore.instance.collection('audit_logs').add({
//       'userId': userId,
//       'operation': operation,
//       'details': details,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//
//   }
// }