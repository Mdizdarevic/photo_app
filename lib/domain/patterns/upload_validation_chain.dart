import '../../../domain/models/user_entity.dart';
import 'dart:io';

// CHAIN OF RESPONSIBILITY Pattern
class UploadRequest {
  final File? imageFile;
  final UserEntity? user;
  final String description;

  UploadRequest({
    required this.imageFile,
    required this.user,
    required this.description,
  });
}

// Handler interface
abstract class UploadValidator {
  UploadValidator? next;

  UploadValidator setNext(UploadValidator handler) {
    next = handler;
    return handler;
  }

  void handle(UploadRequest request);
}

// First Handler of chain: Image validation
class ImageValidator extends UploadValidator {
  @override
  void handle(UploadRequest request) {
    if (request.imageFile == null) {
      throw Exception("Please select an image.");
    }
    next?.handle(request);
  }
}

// Second Handler of chain: User validation
class UserValidator extends UploadValidator {
  @override
  void handle(UploadRequest request) {
    if (request.user == null) {
      throw Exception("Please sign in to post.");
    }
    next?.handle(request);
  }
}

// First Handler of chain: Text validation
class TextValidator extends UploadValidator {
  @override
  void handle(UploadRequest request) {
    if (request.description.trim().isEmpty) {
      throw Exception("Description cannot be empty.");
    }
    next?.handle(request);
  }
}
