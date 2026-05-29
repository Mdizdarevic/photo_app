import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class MetricsService {
  MetricsService._internal() {
    _appLaunchTime = DateTime.now();
  }
  static final MetricsService _instance = MetricsService._internal();
  factory MetricsService() => _instance;

  late final DateTime _appLaunchTime;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<int> _authLatenciesMs = [];
  int _successfulDbWrites = 0;
  int _failedDbWrites = 0;
  double _totalProcessedMegabytes = 0.0;
  double _totalProcessingTimeSeconds = 0.0;
  int _quotaExhaustionCount = 0;

  // 1. System Metric: Active Session Duration
  // Measures how long the application has been open and running during current session
  int get activeSessionDurationSeconds => DateTime.now().difference(_appLaunchTime).inSeconds;

  // 2. System Metric: Auth Latency Tracker
  // Measures the network response delay (speed) of authentication events
  void recordAuthLatency(int milliseconds) => _authLatenciesMs.add(milliseconds);

  double get averageAuthLatencyMs {
    if (_authLatenciesMs.isEmpty) return 0.0;
    return _authLatenciesMs.reduce((a, b) => a + b) / _authLatenciesMs.length;
  }

  // 3. System Metric: Database Success Rate
  // Measures what percent of db requests worked
  void recordDbWrite(bool isSuccess) {
    if (isSuccess) _successfulDbWrites++; else _failedDbWrites++;
  }

  double get dbWriteSuccessRate {
    final int total = _successfulDbWrites + _failedDbWrites;
    if (total == 0) return 100.0;
    return (_successfulDbWrites / total) * 100;
  }

  // 4. System Metric: Image Processing Bandwidth Performance
  // Measures how long it took to process images of diff sizes
  void recordImageProcessing(double megabytes, double timeSeconds) {
    if (timeSeconds > 0) {
      _totalProcessedMegabytes += megabytes;
      _totalProcessingTimeSeconds += timeSeconds;
    }
  }

  double get imageThroughputMBs {
    if (_totalProcessingTimeSeconds == 0) return 0.0;
    return _totalProcessedMegabytes / _totalProcessingTimeSeconds;
  }

  // 5. System Metric: Quota Exhaustion Frequency
  // Measures which users reached their package limits
  void incrementQuotaExhaustion() => _quotaExhaustionCount++;
  int get quotaExhaustionCount => _quotaExhaustionCount;

  void printHealthDashboard() {
    final String timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    final String dashboard = '''
=================================================================
APPLICATION HEALTH & PERFORMANCE MONITORING DASHBOARD 
=================================================================
TIMESTAMP:   $timestamp
STATUS:      ONLINE

[SYSTEM CORE HEALTH METRICS]
1. Active Session Time:     ${activeSessionDurationSeconds}s
2. Avg Auth Latency:        ${averageAuthLatencyMs.toStringAsFixed(1)}ms
3. Firestore Write Success: ${dbWriteSuccessRate.toStringAsFixed(1)}% 
4. Image Processing Speed:  ${imageThroughputMBs.toStringAsFixed(2)} MB/s
5. Tier Package Breaches:   $quotaExhaustionCount times encountered
=================================================================
''';

    print(dashboard);
    developer.log(dashboard, name: 'com.uca.project.metrics');

    _firestore.collection('system_health_metrics').add({
      'timestamp': FieldValue.serverTimestamp(),
      'sessionDurationSec': activeSessionDurationSeconds,
      'avgAuthLatencyMs': averageAuthLatencyMs,
      'dbWriteSuccessRate': dbWriteSuccessRate,
      'customImageThroughputMBs': imageThroughputMBs,
      'customQuotaBreaches': quotaExhaustionCount,
    });
  }
}

class PerformanceAspect {

  PerformanceAspect._internal();
  static final PerformanceAspect _instance = PerformanceAspect._internal();
  factory PerformanceAspect() => _instance;

  final MetricsService _metrics = MetricsService();
  final Map<String, Stopwatch> _timers = {};

  // @Before Advice: Start performance tracking clock
  void beforeAdvice(String operation) {
    _timers[operation] = Stopwatch()..start();
  }

  // @AfterReturning Advice: Tracks database successes and image speeds
  void afterReturningAdvice(String operation, {double? imageSizeMb}) {
    if (_timers.containsKey(operation)) {
      final watch = _timers[operation]!..stop();
      final int elapsedMs = watch.elapsedMilliseconds;
      final double totalSeconds = elapsedMs / 1000.0;
      _timers.remove(operation);

      if (operation.contains("AUTH")) {
        _metrics.recordAuthLatency(elapsedMs);
      }

      // Intercept 1: Automate write track updates
      if (operation.contains("FIRESTORE_WRITE")) {
        _metrics.recordDbWrite(true);
      }

      // Intercept 2: Automate Image processing speeds
      if (operation.contains("PROCESS_IMAGE") && imageSizeMb != null) {
        _metrics.recordImageProcessing(imageSizeMb, totalSeconds);
      }
    }
  }

  // @AfterThrowing Advice: Track failures cleanly
  void afterThrowingAdvice(String operation, Object error) {
    if (_timers.containsKey(operation)) {
      final watch = _timers[operation]!..stop();
      final int elapsedMs = watch.elapsedMilliseconds;
      _timers.remove(operation);

      // Intercept Auth failures to calculate true user connection attempt lag
      if (operation.contains("AUTH")) {
        _metrics.recordAuthLatency(elapsedMs);
      }
    }

    // Intercept 3: Automate health reduction
    if (operation.contains("FIRESTORE_WRITE")) {
      _metrics.recordDbWrite(false);
    }
  }
}

// Intercepting Firestore writes for db health
abstract interface class IPerformanceDatabaseService {
  Future<void> saveDocument(String path, String docId, Map<String, dynamic> data);
}

class PerformanceDatabaseService implements IPerformanceDatabaseService {
  @override
  Future<void> saveDocument(String path, String docId, Map<String, dynamic> data) async {
    await FirebaseFirestore.instance.collection(path).doc(docId).set(data, SetOptions(merge: true));
  }
}

class DatabasePerformanceProxy implements IPerformanceDatabaseService {
  final IPerformanceDatabaseService _target;
  final PerformanceAspect _aspect = PerformanceAspect();

  DatabasePerformanceProxy(this._target);

  @override
  Future<void> saveDocument(String path, String docId, Map<String, dynamic> data) async {
    const String operation = "FIRESTORE_WRITE_TX";
    _aspect.beforeAdvice(operation);
    try {
      await _target.saveDocument(path, docId, data);
      _aspect.afterReturningAdvice(operation);
    } catch (e) {
      _aspect.afterThrowingAdvice(operation, e);
      rethrow;
    }
  }
}

// Intercepting image retrieval for speed
abstract interface class IPerformanceImageService {
  Future<void> optimizeAndUploadImage(String photoId, double sizeMb);
}

class PerformanceImageService implements IPerformanceImageService {
  @override
  Future<void> optimizeAndUploadImage(String photoId, double sizeMb) async {
    await Future.delayed(Duration(milliseconds: (sizeMb * 300).toInt()));
  }
}

class ImagePerformanceProxy implements IPerformanceImageService {
  final IPerformanceImageService _target;
  final PerformanceAspect _aspect = PerformanceAspect();

  ImagePerformanceProxy(this._target);

  @override
  Future<void> optimizeAndUploadImage(String photoId, double sizeMb) async {
    final String operation = "PROCESS_IMAGE_ID_$photoId";
    _aspect.beforeAdvice(operation);
    try {
      await _target.optimizeAndUploadImage(photoId, sizeMb);
      _aspect.afterReturningAdvice(operation, imageSizeMb: sizeMb);
    } catch (e) {
      _aspect.afterThrowingAdvice(operation, e);
      rethrow;
    }
  }
}