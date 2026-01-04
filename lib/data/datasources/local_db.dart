import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// Depending on the chosen configuration, photos have to be saved on local or cloud (e.g.,
// Amazon S3 bucket) storage – 5 points for LO3 Desired

class LocalDatabase {
  Future<String> saveToInternalStorage(File file, String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String path = directory.path;

      final File localImage = await file.copy('$path/$fileName');

      return localImage.path;
    } catch (e) {
      throw Exception("Local Storage Failed: $e");
    }
  }

  Future<File> getFromInternalStorage(String path) async {
    final file = File(p.join(path));
    if (await file.exists()) {
      return file;
    } else {
      throw Exception("File not found at $path");
    }
  }
}