import '../../domain/models/photo_entity.dart';
import '../services/storage_service.dart';
import '../services/logger_service.dart';

class PhotoRepository {
  final IStorageService _storageService;

  PhotoRepository(this._storageService);

  /// LO2: Fetch the 10 last uploaded photos
  Future<List<PhotoEntity>> getLatestPhotos() async {
    try {

      // Get all photos from your storage service
      final allPhotos = await _storageService.getAllPhotos();

      // Sort by date (newest first) and take the top 10
      allPhotos.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
      return allPhotos.take(10).toList();

    } catch (e) {
      return [];
    }
  }

  /// LO3: Logic to search photos by hashtags
  Future<List<PhotoEntity>> searchPhotos({List<String>? hashtags}) async {

    final allPhotos = await _storageService.getAllPhotos();

    if (hashtags == null || hashtags.isEmpty) return allPhotos;

    // Return photos that contain ANY of the searched hashtags
    return allPhotos.where((photo) {
      return photo.hashtags.any((tag) => hashtags.contains(tag));
    }).toList();
  }

  /// LO3: Update photo metadata
  Future<void> updatePhotoMetadata(PhotoEntity photo) async {
    await _storageService.updateMetadata(photo);
  }
}