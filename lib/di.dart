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



final localDbProvider = Provider((ref) => LocalDatabase());

final cloudProvider = Provider((ref) => CloudProvider());

final tierServiceProvider = Provider((ref) => TierService());

final loggerProvider = Provider((ref) => LoggerService());

final authServiceProvider = Provider((ref) => AuthService());

final storageServiceProvider = Provider<IStorageService>((ref) {
  final db = ref.watch(localDbProvider);
  final cloud = ref.watch(cloudProvider);

  return StorageService(
    localDb: db,
    cloudProvider: cloud,
    useCloud: true,
  );
});

final currentUserProvider = StateProvider<UserEntity?>((ref) => null);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final imageProcessorProvider = Provider((ref) => ImageProcessor());

final photoRepositoryProvider = Provider<PhotoRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return PhotoRepository(storage);
});

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
        thumbnailUrl: data['thumbnailUrl'] ?? data['url'] ?? '',
        uploadDate: (data['uploadDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        authorName: data['authorName'] ?? 'Anonymous',
        description: data['description'] ?? '',
        hashtags: List<String>.from(data['hashtags'] ?? []),
      );
    }).toList();
  });
});

final photosStreamProvider = StreamProvider<List<PhotoEntity>>((ref) {
  return FirebaseFirestore.instance
      .collection('photos')
      .orderBy('uploadDate', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => PhotoEntity.fromFirestore(doc))
      .toList());
});

final isSearchVisibleProvider = StateProvider<bool>((ref) => false);

final searchProvider = StateProvider<String>((ref) => "");

final filteredPhotosProvider = Provider<List<PhotoEntity>>((ref) {
  final allPhotos = ref.watch(photosStreamProvider).value ?? [];
  final query = ref.watch(searchProvider).toLowerCase();
  final currentUser = ref.watch(currentUserProvider);
  final logger = ref.watch(loggerProvider);

  if (query.isEmpty) return allPhotos;
  return allPhotos.where((photo) {
    final matchesAuthor = photo.authorName.toLowerCase().contains(query);
    final matchesTag = photo.hashtags.any((tag) => tag.toLowerCase().contains(query));
    final dateString = DateFormat('yyyy-MM-dd').format(photo.uploadDate).toLowerCase();
    final matchesDate = dateString.contains(query);

    return matchesAuthor || matchesTag || matchesDate;
  }).toList();
});

enum UserPackage { free, pro, gold }

final userPackageProvider = StateProvider<UserPackage>((ref) => UserPackage.free);

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

final userPostCountProvider = Provider<int>((ref) {
  final allPhotos = ref.watch(photosStreamProvider).value ?? [];
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) return 0;

  return allPhotos.where((photo) =>
      currentUser.email!.toLowerCase().contains(photo.authorName.toLowerCase())
  ).length;
});

final userStreamProvider = StreamProvider<UserEntity?>((ref) {
  final authUser = FirebaseAuth.instance.currentUser;
  if (authUser == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(authUser.uid)
      .snapshots()
      .map((snapshot) => snapshot.exists ? UserEntity.fromFirestore(snapshot) : null);
});
