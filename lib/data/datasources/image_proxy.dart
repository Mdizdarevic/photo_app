import 'package:flutter/material.dart';
import '../../presentation/widgets/photo_component.dart';

class ImageProxy implements PhotoComponent {
  final String imageUrl;
  final VoidCallback onTap;

  ImageProxy({
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget render() {

    final uri = Uri.parse(imageUrl);
    final cleanUrl = Uri(
      scheme: uri.scheme,
      host: uri.host,
      path: uri.path,
      queryParameters: {'alt': 'media'},
    ).toString();

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          cleanUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
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