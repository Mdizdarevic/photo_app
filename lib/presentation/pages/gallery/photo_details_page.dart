import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/photo_entity.dart';
import '../../../di.dart';
import '../../../domain/models/user_entity.dart';

class PhotoDetailsPage extends ConsumerWidget {
  final PhotoEntity photo;
  const PhotoDetailsPage({super.key, required this.photo});

  Future<void> _downloadImage(BuildContext context) async {
    // 1. Check/Request Permission
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      await Gal.requestAccess();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Downloading..."), duration: Duration(seconds: 2)),
    );

    try {
      // 2. Get a temporary path on the phone
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/pothole_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 3. Use Dio to download the file directly to that path
      await Dio().download(photo.thumbnailUrl, path);

      // 4. Save that file to the actual Gallery
      await Gal.putImage(path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Saved to Gallery! ✅")),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formattedDate = DateFormat.yMMMd().format(photo.uploadDate);
    final currentUser = ref.watch(currentUserProvider);

    // Check if the user is registered (not anonymous)
    final bool canDownload = currentUser != null &&
        currentUser.role != UserRole.anonymous;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Details", style: TextStyle(color: Colors.black)),
        actions: [
          if (canDownload)
            IconButton(
              icon: const Icon(Icons.download_for_offline_rounded, size: 28),
              onPressed: () => _downloadImage(context),
              tooltip: "Download Image",
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: photo.id,
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(photo.thumbnailUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black,
                        radius: 20,
                        child: Text(photo.authorName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(photo.authorName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(formattedDate,
                              style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Description",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(photo.description,
                      style: const TextStyle(fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  if (photo.hashtags.isNotEmpty) ...[
                    const Text("Tags",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: photo.hashtags.map((tag) => Chip(
                        label: Text("#$tag", style: const TextStyle(color: Colors.blueAccent)),
                        backgroundColor: Colors.blue.withOpacity(0.05),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}