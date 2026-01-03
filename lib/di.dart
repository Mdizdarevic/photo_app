import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'data/services/tier_service.dart';



// *************** DATA SOURCES *************** //
final localDbProvider = Provider((ref) => LocalDatabase());

final cloudProvider = Provider((ref) => CloudProvider());

final tierServiceProvider = Provider((ref) => TierService());

// *************** SERVICES (Singletons) *************** //
// Pattern: Singleton & Strategy Context
final loggerProvider = Provider((ref) => LoggerService());

final authServiceProvider = Provider((ref) => AuthService());

// *************** STORAGE STRATEGY *************** //
// LO3 Desired: Logic to switch between Local and Cloud
// Ensure it looks like this
final storageServiceProvider = Provider<IStorageService>((ref) {
  // Rename variables so they don't clash with the provider names
  final db = ref.watch(localDbProvider);
  final cloud = ref.watch(cloudProvider);

  return StorageService(
    localDb: db,
    cloudProvider: cloud,
    useCloud: true,
  );
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

// In your providers file (likely di.dart or photo_provider.dart)
// REMOVE the old StateNotifierProvider and replace it with this:
final photoListProvider = StreamProvider.autoDispose<List<PhotoEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection('photos')
      .orderBy('uploadDate', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return PhotoEntity(
        id: doc.id,
        thumbnailUrl: data['thumbnailUrl'] ?? '',
        uploadDate: (data['uploadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        authorName: data['authorName'] ?? 'Anonymous',
        description: data['description'] ?? '',
        hashtags: List<String>.from(data['hashtags'] ?? []),
      );
    }).toList();
  });
});

final galleryStreamProvider = StreamProvider.autoDispose<List<PhotoEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection('photos')
      .orderBy('uploadDate', descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data();

      return PhotoEntity(
        id: doc.id,
        // Using 'url' from Firestore as the thumbnailUrl
        thumbnailUrl: data['thumbnailUrl'] ?? data['url'] ?? '',
        // Convert Firebase Timestamp to DateTime
        uploadDate: (data['uploadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        authorName: data['authorName'] ?? 'Anonymous',
        description: data['description'] ?? '',
        // Assumes hashtags are stored as a List<String> in Firestore
        hashtags: List<String>.from(data['hashtags'] ?? []),
      );
    }).toList();
  });
});