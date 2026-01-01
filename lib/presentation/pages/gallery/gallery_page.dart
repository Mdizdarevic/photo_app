import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import '../../../domain/models/photo_entity.dart';
import '../../core/app_theme.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // LO2 Desired: Getting the last 10 photos
    final photos = ref.watch(photoListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("GALLERY", style: TextStyle(letterSpacing: 2)),
        actions: [
          // Search Icon to trigger LO3 Search Filters
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchFilters(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined),
            onPressed: () => Navigator.pushNamed(context, '/upload'),
          ),
        ],
      ),
      body: photos.isEmpty
          ? const Center(child: Text("NO PHOTOS UPLOADED"))
          : ListView.builder(
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return _PhotoThumbnailTile(photo: photos[index]);
        },
      ),
    );
  }

  void _showSearchFilters(BuildContext context) {
    // This will open a bottom sheet for LO3 search requirements:
    // Hashtags, Size, Date Range, Author
  }
}

class _PhotoThumbnailTile extends StatelessWidget {
  final PhotoEntity photo;
  const _PhotoThumbnailTile({required this.photo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The Image (Thumbnail)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: AppTheme.lightGrey,
              child: Image.network(photo.thumbnailUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 10),

          // LO2 Minimum: Displaying Metadata by default
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(photo.authorName.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text("${photo.uploadDate.day}/${photo.uploadDate.month}/${photo.uploadDate.year}",
                  style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),

          const SizedBox(height: 5),
          Text(photo.description, style: const TextStyle(fontSize: 14)),

          const SizedBox(height: 5),
          // LO2 Minimum: Hashtags
          Wrap(
            spacing: 8,
            children: photo.hashtags.map((tag) => Text(
                "#$tag",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)
            )).toList(),
          ),
          const Divider(color: Colors.black12, height: 30),
        ],
      ),
    );
  }
}