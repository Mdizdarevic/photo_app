import 'dart:io';

/// The Strategy Interface
abstract class ImageProcessingStrategy {
  Future<File> process(File imageFile);
}

/// Concrete Strategy: Resize
class ResizeStrategy implements ImageProcessingStrategy {
  final int width;
  final int height;

  ResizeStrategy({required this.width, required this.height});

  @override
  Future<File> process(File imageFile) async {
    // Logic using 'package:image/image.dart' to resize
    print("Processing: Resizing to ${width}x$height");
    return imageFile;
  }
}

/// Concrete Strategy: Sepia Filter (LO4 Desired)
class SepiaStrategy implements ImageProcessingStrategy {
  @override
  Future<File> process(File imageFile) async {
    print("Processing: Applying Sepia filter");
    return imageFile;
  }
}

/// Concrete Strategy: Blur Filter (LO4 Desired)
class BlurStrategy implements ImageProcessingStrategy {
  @override
  Future<File> process(File imageFile) async {
    print("Processing: Applying Blur filter");
    return imageFile;
  }
}