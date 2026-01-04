import 'dart:io';

import 'image_strategy.dart';

class ImageProcessor {
  ImageProcessingStrategy? _strategy;

  // Set the strategy at runtime
  void setStrategy(ImageProcessingStrategy strategy) {
    _strategy = strategy;
  }

  Future<File> executeProcessing(File file) async {
    if (_strategy == null) return file;
    return await _strategy!.process(file);
  }
}