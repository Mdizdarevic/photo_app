import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:photo_app/presentation/state/photo_notifier.dart';
import 'data/datasources/local_db.dart';
import 'data/datasources/cloud_provider.dart';
import 'data/repositories/photo_repository.dart';
import 'data/services/logger_service.dart';
import 'data/services/storage_service.dart';
import 'data/services/auth_service.dart';
import 'domain/models/photo_entity.dart';
import 'domain/models/user_entity.dart';
import 'domain/patterns/image_processor.dart';



// *************** DATA SOURCES *************** //
final localDbProvider = Provider((ref) => LocalDatabase());
final cloudProvider = Provider((ref) => CloudProvider());

// *************** SERVICES (Singletons) *************** //
// Pattern: Singleton & Strategy Context
final loggerProvider = Provider((ref) => LoggerService());

final authServiceProvider = Provider((ref) => AuthService());

// *************** STORAGE STRATEGY *************** //
// LO3 Desired: Logic to switch between Local and Cloud
final storageServiceProvider = Provider<IStorageService>((ref) {
  final local = ref.watch(localDbProvider);
  final cloud = ref.watch(cloudProvider);

  return StorageService(localDb: local, cloudProvider: cloud,);
});

// The currently logged in UserEntity
final currentUserProvider = StateProvider<UserEntity?>((ref) => null);


// StreamProvider to listen to Firebase's internal auth state
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// Provider for the Image Processor context
final imageProcessorProvider = Provider((ref) => ImageProcessor());

// lib/di.dart

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  // ref.watch ensures that if storage or logger changes, the repo updates
  final storage = ref.watch(storageServiceProvider);
  final logger = ref.watch(loggerProvider);

  return PhotoRepository(storage, logger);
});

// A StateNotifierProvider to manage the list of photos in the UI (Observer Pattern)
final photoListProvider = StateNotifierProvider<PhotoNotifier, List<PhotoEntity>>((ref) {
  return PhotoNotifier(ref.watch(photoRepositoryProvider));
});