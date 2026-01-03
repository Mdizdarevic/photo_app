import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import 'photo_details_page.dart';

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the stream for connection status (loading/error)
    final photosAsync = ref.watch(photosStreamProvider);

    // 2. Watch the filtered provider for the actual list to display
    final filteredPhotos = ref.watch(filteredPhotosProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Community Gallery",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: photosAsync.when(
        // Handle the initial loading state from Firebase
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
        // Handle Firebase connection errors
        error: (err, stack) => Center(
          child: Text("Error: $err"),
        ),
        data: (_) {
          // 3. Check if the SEARCH result is empty
          if (filteredPhotos.isEmpty) {
            return const Center(
              child: Text(
                "NO PHOTOS MATCHING SEARCH",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            );
          }

          // 4. Build the Grid using filtered results
          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: filteredPhotos.length,
            itemBuilder: (context, index) {
              final photo = filteredPhotos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoDetailsPage(photo: photo),
                    ),
                  );
                },
                child: Hero(
                  tag: photo.id, // Animation transition fixed earlier
                  child: Image.network(
                    photo.thumbnailUrl,
                    fit: BoxFit.cover,
                    // Loading placeholder for smoother UI
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}