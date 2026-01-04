import 'package:flutter/material.dart';

import '../../presentation/widgets/photo_component.dart';

// Proxy Pattern
// Controls access to the real image and shows a placeholder while loading
class ImageProxy implements PhotoComponent {
  final String imageUrl;
  final VoidCallback onTap;

  ImageProxy({
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget render() {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,

          loadingBuilder: (context, child, loadingProgress) {
            // If loading is complete -> render the real image
            if (loadingProgress == null) {
              return child;
            }

            // Otherwise -> placeholder
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },

          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}
