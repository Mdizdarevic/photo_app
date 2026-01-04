import '../../domain/models/photo_entity.dart';
import '../services/storage_service.dart';

class PhotoRepository {
  final IStorageService _storageService;

  PhotoRepository(this._storageService);

  Future<List<PhotoEntity>> getLatestPhotos() async {
    try {

      final allPhotos = await _storageService.getAllPhotos();

      allPhotos.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
      return allPhotos.take(10).toList();

    } catch (e) {
      return [];
    }
  }

  Future<List<PhotoEntity>> searchPhotos({List<String>? hashtags}) async {

    final allPhotos = await _storageService.getAllPhotos();

    if (hashtags == null || hashtags.isEmpty) return allPhotos;

    return allPhotos.where((photo) {
      return photo.hashtags.any((tag) => hashtags.contains(tag));
    }).toList();
  }

  Future<void> updatePhotoMetadata(PhotoEntity photo) async {
    await _storageService.updateMetadata(photo);
  }
}