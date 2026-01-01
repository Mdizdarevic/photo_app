import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/models/photo_entity.dart';
import '../../data/repositories/photo_repository.dart';

class PhotoNotifier extends StateNotifier<List<PhotoEntity>> {
  final PhotoRepository _repository;

  // Initialize with an empty list
  PhotoNotifier(this._repository) : super([]) {
    loadPhotos(); // Load photos immediately when the app starts
  }

  // LO2 Desired: Fetch the 10 last uploaded photos
  Future<void> loadPhotos() async {
    try {
      final photos = await _repository.getLatestPhotos();
      state = photos; // This update triggers the UI to rebuild (Observer Pattern)
    } catch (e) {
      // Handle error
      state = [];
    }
  }

  // LO3: Logic to update state after a search
  void setFilteredPhotos(List<PhotoEntity> filteredList) {
    state = filteredList;
  }
}