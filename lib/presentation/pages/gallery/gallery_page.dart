import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import '../../../domain/models/photo_entity.dart';
import '../../core/app_theme.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This watches the real-time stream from Firestore
    final photosAsync = ref.watch(photoListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(child: Text("NO PHOTOS UPLOADED", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: photos.length,
            itemBuilder: (context, index) => _PhotoThumbnailTile(photo: photos[index]),
          );
        },
      ),
    );
  }
}

// MAKE SURE THIS IS HERE AT THE BOTTOM OF THE FILE
class _PhotoThumbnailTile extends StatelessWidget {
  final PhotoEntity photo;
  const _PhotoThumbnailTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(photo.thumbnailUrl, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(photo.authorName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(photo.description),
        ],
      ),
    );
  }
}