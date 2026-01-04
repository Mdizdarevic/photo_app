import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/models/photo_entity.dart';
import '../../data/repositories/photo_repository.dart';

class PhotoNotifier extends StateNotifier<List<PhotoEntity>> {
  final PhotoRepository _repository;

  PhotoNotifier(this._repository) : super([]) {
    loadPhotos();
  }

  Future<void> loadPhotos() async {
    try {
      final photos = await _repository.getLatestPhotos();
      state = photos;
    } catch (e) {
      state = [];
    }
  }

  void setFilteredPhotos(List<PhotoEntity> filteredList) {
    state = filteredList;
  }
}