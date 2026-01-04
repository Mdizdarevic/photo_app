import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

// When downloading, the user can choose to download the original photo (6 points
// for LO4 Minimum) or the photo with applied selected filters - e.g., resize + sepia + blur +
// format (4 points for LO4 Desired)

// 1. STRATEGY INTERFACE
abstract class ImageProcessingStrategy {
  Future<File> process(File imageFile);
}

// 2. Concrete Strategy
class SepiaStrategy implements ImageProcessingStrategy {
  @override
  Future<File> process(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

    if (image != null) {
      image = img.sepia(image);
      final encoded = img.encodeJpg(image);
      await imageFile.writeAsBytes(encoded);
    }

    return imageFile;
  }
}
// 3. Concrete Strategy
class BlurStrategy implements ImageProcessingStrategy {
  @override
  Future<File> process(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(Uint8List.fromList(bytes));

    if (image != null) {
      image = img.gaussianBlur(image, radius: 10);
      final encoded = img.encodeJpg(image);
      await imageFile.writeAsBytes(encoded);
    }

    return imageFile;
  }
}

// 4. Context Class
// This is the class that the client interacts with.
class ImageProcessor {
  ImageProcessingStrategy strategy;
  ImageProcessor({required this.strategy});

  // This method executes the algorithm without the Context knowing
  // which specific filter (Sepia or Blur) is actually being used.
  Future<File> execute(File imageFile) async {
    return strategy.process(imageFile);
  }
}