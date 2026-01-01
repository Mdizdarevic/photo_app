import '../../domain/models/photo_entity.dart';
import '../services/storage_service.dart';
import '../services/logger_service.dart';

class PhotoRepository {
  final IStorageService _storageService;
  final LoggerService _logger;

  PhotoRepository(this._storageService, this._logger);

  /// LO2: Fetch the 10 last uploaded photos
  Future<List<PhotoEntity>> getLatestPhotos() async {
    try {
      _logger.logAction(userId: "SYSTEM", operation: "FETCH_LATEST_PHOTOS");

      // Get all photos from your storage service
      final allPhotos = await _storageService.getAllPhotos();

      // Sort by date (newest first) and take the top 10
      allPhotos.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
      return allPhotos.take(10).toList();

    } catch (e) {
      _logger.logAction(userId: "SYSTEM", operation: "ERROR", details: e.toString());
      return [];
    }
  }

  /// LO3: Logic to search photos by hashtags
  Future<List<PhotoEntity>> searchPhotos({List<String>? hashtags}) async {
    _logger.logAction(userId: "USER_ID", operation: "SEARCH_PHOTOS", details: "Tags: $hashtags");

    final allPhotos = await _storageService.getAllPhotos();

    if (hashtags == null || hashtags.isEmpty) return allPhotos;

    // Return photos that contain ANY of the searched hashtags
    return allPhotos.where((photo) {
      return photo.hashtags.any((tag) => hashtags.contains(tag));
    }).toList();
  }

  /// LO3: Update photo metadata
  Future<void> updatePhotoMetadata(PhotoEntity photo) async {
    _logger.logAction(userId: "USER_ID", operation: "UPDATE_PHOTO", details: photo.id);
    await _storageService.updateMetadata(photo);
  }
}