import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import 'photo_details_page.dart'; // We will create this next

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photoListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Community Gallery",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: photosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (photos) {
          if (photos.isEmpty) {
            return const Center(child: Text("NO PHOTOS UPLOADED", style: TextStyle(color: Colors.grey)));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(2), // Thin margin around the grid
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Exactly 2 rows/columns
              crossAxisSpacing: 2, // Space between columns
              mainAxisSpacing: 2,    // Space between rows
              childAspectRatio: 1,  // Makes them perfect squares
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
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
                  tag: photo.id, // Smooth animation transition
                  child: Image.network(
                    photo.thumbnailUrl,
                    fit: BoxFit.cover,
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