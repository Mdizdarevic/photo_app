import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class CloudProvider {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadToFirebase(File file, String fileName) async {
    try {
      final ref = _storage.ref().child('photos/$fileName');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception("Cloud upload failed: $e");
    }
  }
}