import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:photo_app/presentation/state/photo_notifier.dart';
import 'data/datasources/local_db.dart';
import 'package:intl/intl.dart';
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

  return PhotoRepository(storage);
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

// di.dart

// This fetches the live list of photos from Firestore
final photosStreamProvider = StreamProvider<List<PhotoEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection('photos')
      .orderBy('uploadDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => PhotoEntity.fromFirestore(doc))
      .toList());
});

// 1. Controls the visibility of the bottom search bar
final isSearchVisibleProvider = StateProvider<bool>((ref) => false);

// 2. The provider to hold the current search text
final searchProvider = StateProvider<String>((ref) => "");

// 3. The filtered list logic
final filteredPhotosProvider = Provider<List<PhotoEntity>>((ref) {
  // Watch your existing stream provider
  final allPhotos = ref.watch(photosStreamProvider).value ?? [];
  final query = ref.watch(searchProvider).toLowerCase();

  // Get the current user and logger instance
  final currentUser = ref.watch(currentUserProvider);
  final logger = ref.watch(loggerProvider);

  if (query.isEmpty) return allPhotos;

  // LOGGING ACTION: Search Operation
  // Requirement: By who, when, and what operation

  return allPhotos.where((photo) {
    // Search by Author Name (fixes the 'moreno.dizdarevic' mismatch)
    final matchesAuthor = photo.authorName.toLowerCase().contains(query);

    // Search by Hashtags
    final matchesTag = photo.hashtags.any((tag) => tag.toLowerCase().contains(query));

    // Search by Date (Formatted for searchability)
    final dateString = DateFormat('yyyy-MM-dd').format(photo.uploadDate).toLowerCase();
    final matchesDate = dateString.contains(query);

    return matchesAuthor || matchesTag || matchesDate;
  }).toList();
});

// 1. Define the possible tiers
enum UserPackage { free, pro, gold }

// 2. Identify the user's current package (Defaulting to Free for now)
// In a real app, you would fetch this from a 'role' or 'package' field in Firestore
final userPackageProvider = StateProvider<UserPackage>((ref) => UserPackage.free);

// 3. Define the limit based on the selected package
// di.dart
final packageLimitProvider = Provider<int?>((ref) {
  final userAsync = ref.watch(userStreamProvider);
  final logger = ref.watch(loggerProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return 20;

      switch (user.package) {
        case PackageTier.free: return 20;
        case PackageTier.pro:  return 100;
        case PackageTier.gold: return null;
        default: return 20;
      }
    },
    loading: () => 20,
    error: (_, __) => 20,
  );
});

// 4. Calculate current usage
final userPostCountProvider = Provider<int>((ref) {
  final allPhotos = ref.watch(photosStreamProvider).value ?? [];
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) return 0;

  // Use the .contains() fix for your email/username mismatch
  return allPhotos.where((photo) =>
      currentUser.email!.toLowerCase().contains(photo.authorName.toLowerCase())
  ).length;
});

// di.dart

// This listens to the user's document in real-time
final userStreamProvider = StreamProvider<UserEntity?>((ref) {
  final authUser = FirebaseAuth.instance.currentUser;
  if (authUser == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(authUser.uid)
      .snapshots()
      .map((snapshot) => snapshot.exists ? UserEntity.fromFirestore(snapshot) : null);
});
