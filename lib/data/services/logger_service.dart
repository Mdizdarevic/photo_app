import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import '../../../domain/models/user_entity.dart';
import '../../../data/services/auth_service.dart';
import 'metrics_service.dart'; // 🟢 Added import to access PerformanceAspect

class AuditAspect {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // @Before Advice
  void beforeAdvice(String operation) {
    final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final String logMessage = '''
    -----------------------------------
    [AOP LOG - BEFORE EXECUTION]
    WHEN:      $timestamp
    OPERATION: $operation
    STAGE:     STARTING
    -----------------------------------''';

    print(logMessage);
    developer.log(logMessage, name: 'com.uca.project.aop.before');
  }

  // @AfterReturning Advice
  void afterReturningAdvice(String userId, String operation, Object? result) {
    final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final String logMessage = '''
    -----------------------------------
    [AOP LOG - AFTER RETURNING]
    WHO:       $userId
    WHEN:      $timestamp
    OPERATION: $operation
    STATUS:    SUCCESS 
    -----------------------------------''';

    print(logMessage);
    developer.log(logMessage, name: 'com.uca.project.aop.success');

    _firestore.collection('audit_logs').add({
      'userId': userId,
      'operation': operation,
      'status': 'SUCCESS',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // @AfterThrowing Advice
  void afterThrowingAdvice(String userId, String operation, Object error) {
    final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final String logMessage = '''
    -----------------------------------
    [AOP LOG - AFTER THROWING]
    WHO:       $userId
    WHEN:      $timestamp
    OPERATION: ${operation}_FAILED
    STATUS:    ERROR 
    DETAILS:   ${error.toString()}
    -----------------------------------''';

    print(logMessage);
    developer.log(logMessage, name: 'com.uca.project.aop.error');

    _firestore.collection('audit_logs').add({
      'userId': userId,
      'operation': "${operation}_FAILED",
      'status': 'ERROR',
      'details': error.toString(),
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}

abstract interface class IAopAuthService {
  Future<UserEntity?> registerWithEmail(String email, String password, PackageTier tier);
  Future<UserEntity?> signInWithEmail(String email, String password);
  Future<UserEntity?> signInWithGoogle();
  Future<UserEntity?> signInWithGithub();
  Future<UserEntity?> signInAnonymously();
  Future<void> signOut(String fallbackEmail);
}

class AopAuthService implements IAopAuthService {
  final AuthService _realAuth = AuthService();

  @override
  Future<UserEntity?> registerWithEmail(String email, String password, PackageTier tier) {
    return _realAuth.registerWithEmail(email, password, tier);
  }

  @override
  Future<UserEntity?> signInWithEmail(String email, String password) {
    return _realAuth.signInWithEmail(email, password);
  }

  @override
  Future<UserEntity?> signInWithGoogle() {
    return _realAuth.signInWithGoogle();
  }

  @override
  Future<UserEntity?> signInWithGithub() {
    return _realAuth.signInWithGithub();
  }

  @override
  Future<UserEntity?> signInAnonymously() {
    return _realAuth.signInAnonymously();
  }

  @override
  Future<void> signOut(String fallbackEmail) {
    return _realAuth.signOut();
  }
}

class AuthServiceAopProxy implements IAopAuthService {
  final IAopAuthService _target;
  final AuditAspect _aspect;

  AuthServiceAopProxy(this._target, this._aspect);

  @override
  Future<UserEntity?> registerWithEmail(String email, String password, PackageTier tier) async {
    const String operation = "CREATE_ACCOUNT";
    _aspect.beforeAdvice(operation);
    PerformanceAspect().beforeAdvice("AUTH_$operation"); // 🟢 Start Perf Stopwatch
    try {
      final result = await _target.registerWithEmail(email, password, tier);
      _aspect.afterReturningAdvice(email, operation, result);
      PerformanceAspect().afterReturningAdvice("AUTH_$operation"); // 🟢 Log Success Perf
      return result;
    } catch (error) {
      _aspect.afterThrowingAdvice(email, operation, error);
      PerformanceAspect().afterThrowingAdvice("AUTH_$operation", error); // 🟢 Log Error Perf
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signInWithEmail(String email, String password) async {
    const String operation = "USER_LOGIN_EMAIL";
    _aspect.beforeAdvice(operation);
    PerformanceAspect().beforeAdvice("AUTH_$operation"); // 🟢 Start Perf Stopwatch
    try {
      final result = await _target.signInWithEmail(email, password);
      _aspect.afterReturningAdvice(email, operation, result);
      PerformanceAspect().afterReturningAdvice("AUTH_$operation"); // 🟢 Log Success Perf
      return result;
    } catch (error) {
      _aspect.afterThrowingAdvice(email, operation, error);
      PerformanceAspect().afterThrowingAdvice("AUTH_$operation", error); // 🟢 Log Error Perf
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signInWithGoogle() async {
    const String operation = "USER_LOGIN_GOOGLE";
    _aspect.beforeAdvice(operation);
    PerformanceAspect().beforeAdvice("AUTH_$operation"); // 🟢 Start Perf Stopwatch
    try {
      final result = await _target.signInWithGoogle();
      _aspect.afterReturningAdvice(result?.email ?? "GoogleUser", operation, result);
      PerformanceAspect().afterReturningAdvice("AUTH_$operation"); // 🟢 Log Success Perf
      return result;
    } catch (error) {
      _aspect.afterThrowingAdvice("Unknown", operation, error);
      PerformanceAspect().afterThrowingAdvice("AUTH_$operation", error); // 🟢 Log Error Perf
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signInWithGithub() async {
    const String operation = "USER_LOGIN_GITHUB";
    _aspect.beforeAdvice(operation);
    PerformanceAspect().beforeAdvice("AUTH_$operation");
    try {
      final result = await _target.signInWithGithub();
      _aspect.afterReturningAdvice(result?.email ?? "GithubUser", operation, result);
      PerformanceAspect().afterReturningAdvice("AUTH_$operation");
      return result;
    } catch (error) {
      _aspect.afterThrowingAdvice("Unknown", operation, error);
      PerformanceAspect().afterThrowingAdvice("AUTH_$operation", error);
      rethrow;
    }
  }

  @override
  Future<UserEntity?> signInAnonymously() async {
    const String operation = "USER_LOGIN_ANONYMOUS";
    _aspect.beforeAdvice(operation);
    PerformanceAspect().beforeAdvice("AUTH_$operation"); // 🟢 Start Perf Stopwatch
    try {
      final result = await _target.signInAnonymously();
      _aspect.afterReturningAdvice("guest@app.com", operation, result);
      PerformanceAspect().afterReturningAdvice("AUTH_$operation"); // 🟢 Log Success Perf
      return result;
    } catch (error) {
      _aspect.afterThrowingAdvice("Guest", operation, error);
      PerformanceAspect().afterThrowingAdvice("AUTH_$operation", error); // 🟢 Log Error Perf
      rethrow;
    }
  }

  @override
  Future<void> signOut(String fallbackEmail) async {
    const String operation = "USER_SIGN_OUT";
    _aspect.beforeAdvice(operation);
    PerformanceAspect().beforeAdvice("AUTH_$operation"); // 🟢 Start Perf Stopwatch
    try {
      await _target.signOut(fallbackEmail);
      _aspect.afterReturningAdvice(fallbackEmail, operation, null);
      PerformanceAspect().afterReturningAdvice("AUTH_$operation"); // 🟢 Log Success Perf
    } catch (error) {
      _aspect.afterThrowingAdvice(fallbackEmail, operation, error);
      PerformanceAspect().afterThrowingAdvice("AUTH_$operation", error); // 🟢 Log Error Perf
      rethrow;
    }
  }
}

abstract interface class IPackageService {
  Future<void> changePackage(String email, String tierName);
}

class PackageService implements IPackageService {
  @override
  Future<void> changePackage(String email, String tierName) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(email)
        .update({'package': tierName});
  }
}

class PackageServiceAopProxy implements IPackageService {
  final IPackageService _target;
  final AuditAspect _aspect;

  PackageServiceAopProxy(this._target, this._aspect);

  @override
  Future<void> changePackage(String email, String tierName) async {
    final String operation = "CHANGE_PACKAGE_TO_${tierName.toUpperCase()}";
    _aspect.beforeAdvice(operation);
    try {
      await _target.changePackage(email, tierName);
      _aspect.afterReturningAdvice(email, operation, null);
    } catch (error) {
      _aspect.afterThrowingAdvice(email, operation, error);
      rethrow;
    }
  }
}

abstract interface class IUserService {
  Future<void> deleteUserAccount(String userId, String email);
}

class UserService implements IUserService {
  @override
  Future<void> deleteUserAccount(String userId, String email) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
  }
}

class UserServiceAopProxy implements IUserService {
  final IUserService _target;
  final AuditAspect _aspect;

  UserServiceAopProxy(this._target, this._aspect);

  @override
  Future<void> deleteUserAccount(String userId, String email) async {
    const String operation = "DELETE_USER_ACCOUNT";
    _aspect.beforeAdvice(operation);
    try {
      await _target.deleteUserAccount(userId, email);
      _aspect.afterReturningAdvice(email, operation, null);
    } catch (error) {
      _aspect.afterThrowingAdvice(email, operation, error);
      rethrow;
    }
  }
}

class LoggerService {
  LoggerService._internal();
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;

  void logAction({
    required String userId,
    required String operation,
    String? details,
  }) {
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