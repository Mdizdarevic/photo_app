import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import '../../data/services/logger_service.dart';
import '../models/photo_entity.dart';
import '../models/user_entity.dart';
import 'image_strategy.dart';

// Facade to simplify photo operations
class PhotoFacade {
  final LoggerService _logger = LoggerService();

  // Save changes to photo description & hashtags
  Future<void> saveChanges({
    required PhotoEntity photo,
    required String description,
    required List<String> hashtags,
    required UserEntity? currentUser,
  }) async {
    // Registered users can modify the description and hashtags of their photos while
    // the anonymous user can only browse uploaded photos (8 points for LO2 Minimum)
      if (currentUser == null) return;

    await FirebaseFirestore.instance
        .collection('photos')
        .doc(photo.id)
        .update({
      'description': description,
      'hashtags': hashtags,
    });

    _logger.logAction(
      userId: currentUser.email,
      operation: "EDIT_POST",
      details: "Updated description: $description | hashtags: ${hashtags.join(' ')}",
    );
  }

  // Delete photo
  Future<void> deletePhoto({
    required PhotoEntity photo,
    required UserEntity? currentUser,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('photos').doc(photo.id).delete();

      _logger.logAction(
        userId: currentUser?.email ?? "Unknown",
        operation: "DELETE_POST",
        details: "Deleted Photo ID: ${photo.id} (Author: ${photo.authorName})",
      );
    } catch (e) {
      rethrow;
    }
  }

  // User can download the photo – LO4
  Future<File> downloadPhoto({
    required String url,
    ImageProcessingStrategy? strategy,
  }) async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) await Gal.requestAccess();

    final response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

    File file;

    if (strategy == null) {
      // Original
      file = await File(path).writeAsBytes(response.data);
    } else {
      // Processed via Strategy
      file = await _applyStrategy(response.data, path, strategy);
    }

    await Gal.putImage(file.path);
    return file;
  }

  // Internal helper to apply strategy
  Future<File> _applyStrategy(Uint8List data, String path, ImageProcessingStrategy strategy) async {
    final tempFile = await File(path).writeAsBytes(data);
    return strategy.process(tempFile);
  }
}
