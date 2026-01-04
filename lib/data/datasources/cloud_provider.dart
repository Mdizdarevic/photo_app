import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';


// Depending on the chosen configuration, photos have to be saved on local or cloud (e.g.,
// Amazon S3 bucket) storage – 5 points for LO3 Desired

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