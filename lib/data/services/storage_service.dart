import 'dart:io';
import '../../domain/models/photo_entity.dart';
import '../datasources/local_db.dart';
import '../datasources/cloud_provider.dart';

abstract class IStorageService {
  Future<String> uploadPhoto(File file, String fileName);
  Future<List<PhotoEntity>> getAllPhotos();
  Future<void> updateMetadata(PhotoEntity photo);
}

class StorageService implements IStorageService {
  final LocalDatabase localDb;
  final CloudProvider cloudProvider;
  final bool useCloud;

  StorageService({
    required this.localDb,
    required this.cloudProvider,
    this.useCloud = true,
  });

  @override
  Future<String> uploadPhoto(File file, String fileName) async {
    if (useCloud) {
      return await cloudProvider.uploadToFirebase(file, fileName);
    } else {
      return await localDb.saveToInternalStorage(file, fileName);
    }
  }

  @override
  Future<List<PhotoEntity>> getAllPhotos() async {
    return [];
  }

  @override
  Future<void> updateMetadata(PhotoEntity photo) async {
    print("Updating metadata for ${photo.id}");
  }
}