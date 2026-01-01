import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class LocalDatabase {
  /// LO3: Saves a file to the app's internal documents directory
  Future<String> saveToInternalStorage(File file, String fileName) async {
    try {
      // Get the local directory for the app
      final directory = await getApplicationDocumentsDirectory();
      final String path = directory.path;

      // Create a local copy of the photo
      final File localImage = await file.copy('$path/$fileName');

      return localImage.path; // Return the local path for database reference
    } catch (e) {
      throw Exception("Local Storage Failed: $e");
    }
  }

  /// LO3: Retrieves a file from the local path
  Future<File> getFromInternalStorage(String path) async {
    final file = File(p.join(path));
    if (await file.exists()) {
      return file;
    } else {
      throw Exception("File not found at $path");
    }
  }
}