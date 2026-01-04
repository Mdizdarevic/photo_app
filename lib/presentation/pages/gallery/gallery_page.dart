import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../data/datasources/image_proxy.dart';
import '../../../di.dart';
import '../../widgets/photo_component.dart';
import 'photo_details_page.dart';

// User can browse all uploaded photos – LO2

// Provider to track selection for the Decorator Pattern
final selectedPhotoProvider = StateProvider<String?>((ref) => null);

class GalleryPage extends ConsumerWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosStreamProvider);
    final filteredPhotos = ref.watch(filteredPhotosProvider);

    // Watch the selection state to update the Decorator
    final selectedId = ref.watch(selectedPhotoProvider);


    // By default, thumbnails of 10 last uploaded photos are displayed with a
    // description, author, upload DateTime, and hashtags (4 points for LO2 Desired)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Community Gallery",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: photosAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
        error: (err, stack) => Center(
          child: Text("Error: $err"),
        ),
        data: (_) {
          if (filteredPhotos.isEmpty) {
            return const Center(
              child: Text(
                "NO PHOTOS MATCHING SEARCH",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: filteredPhotos.length,
            itemBuilder: (context, index) {
              final photo = filteredPhotos[index];

              // ---- PROXY + DECORATOR PATTERN ----
              PhotoComponent basePhoto = ImageProxy(
                imageUrl: photo.thumbnailUrl,
                onTap: () {
                  ref.read(selectedPhotoProvider.notifier).state = photo.id;

                  // Click on the photo thumbnail displays the whole photo (1 point for LO2 Desired)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoDetailsPage(photo: photo),
                    ),
                  );
                },
              );

              // 2. Apply decorators
              PhotoComponent decoratedPhoto = BorderDecorator(
                CheckmarkDecorator(basePhoto, isSelected: selectedId == photo.id),
                isSelected: selectedId == photo.id,
              );


              // 3. Render
              return Hero(
                tag: photo.id,
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: decoratedPhoto.render(),
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