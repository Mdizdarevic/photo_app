import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/logger_service.dart';
import '../../../domain/models/photo_entity.dart';
import '../../../di.dart';
import '../../../domain/models/user_entity.dart';

class PhotoDetailsPage extends ConsumerStatefulWidget {
  final PhotoEntity photo;
  const PhotoDetailsPage({super.key, required this.photo});

  @override
  ConsumerState<PhotoDetailsPage> createState() => _PhotoDetailsPageState();
}

class _PhotoDetailsPageState extends ConsumerState<PhotoDetailsPage> {
  bool _isEditing = false;
  late TextEditingController _descriptionController;
  late TextEditingController _hashtagController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.photo.description);
    _hashtagController = TextEditingController(text: widget.photo.hashtags.join(' '));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _hashtagController.dispose();
    super.dispose();
  }

  // --- EDITING LOGIC ---
  Future<void> _saveChanges() async {
    try {

      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) return;

      final List<String> updatedTags = _hashtagController.text
          .split(' ')
          .where((t) => t.isNotEmpty)
          .map((t) => t.replaceAll('#', '')) // Clean up if user typed '#'
          .toList();

      await FirebaseFirestore.instance
          .collection('photos')
          .doc(widget.photo.id)
          .update({
        'description': _descriptionController.text,
        'hashtags': updatedTags,
      });

      setState(() => _isEditing = false);

      LoggerService().logAction(
        userId: currentUser.email,
        operation: "EDIT_POST",
        details: "Updated description: ${_descriptionController.text} | hashtags: ${_hashtagController.text}",
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Changes saved successfully!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Save failed: $e")),
        );
      }
    }
  }

  // --- DOWNLOAD & FILTER LOGIC ---
  Future<void> _showDownloadOptions(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text("Download Format"),
        children: [
          _filterOption(context, "Original", null),
          _filterOption(context, "Sepia Filter", "sepia"),
          _filterOption(context, "Blur Filter", "blur"),
        ],
      ),
    );
  }

  Widget _filterOption(BuildContext context, String label, String? type) {
    return SimpleDialogOption(
      onPressed: () {
        Navigator.pop(context);
        _processAndDownload(context, type);
      },
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  Future<void> _processAndDownload(BuildContext context, String? filterType) async {
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) await Gal.requestAccess();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image downloaded as ${filterType ?? 'Original'}...")),
      );
    }

    try {
      final response = await Dio().get(
        widget.photo.thumbnailUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (filterType == null) {
        await File(path).writeAsBytes(response.data);
      } else {
        img.Image? image = img.decodeImage(Uint8List.fromList(response.data));
        if (image != null) {
          if (filterType == "sepia") image = img.sepia(image);
          if (filterType == "blur") image = img.gaussianBlur(image, radius: 10);
          await File(path).writeAsBytes(img.encodeJpg(image));
        }
      }

      await Gal.putImage(path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        final label = filterType ?? 'Original';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$label image downloaded"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(widget.photo.uploadDate);
    final currentUser = ref.watch(currentUserProvider);

    // 1. Registered users can download.
    final bool isRegisteredUser = currentUser != null && currentUser.role != UserRole.anonymous;

    // 2. Ownership check using EMAIL.
    // Ensure widget.photo.authorName contains the creator's email.
    final bool isAdmin = currentUser?.role == UserRole.admin;
    final bool isOwner = isRegisteredUser &&
        (currentUser.email?.toLowerCase().contains(widget.photo.authorName.toLowerCase()) ?? false);

    final bool canManage = isAdmin || isOwner;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(_isEditing ? "Edit Details" : widget.photo.authorName),
        actions: [
          // The Edit pencil ONLY shows if you are the owner (matching email)
          if (canManage)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
          // Download button shows for all registered users when not editing
          if (isRegisteredUser && !_isEditing)
            IconButton(
              icon: const Icon(Icons.download_for_offline_rounded, size: 28),
              onPressed: () => _showDownloadOptions(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: widget.photo.id,
              child: Image.network(widget.photo.thumbnailUrl, fit: BoxFit.cover, width: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isEditing) ...[
                    // --- VIEW MODE ---
                    _buildInfoSection("Description", widget.photo.description),
                    const SizedBox(height: 20),
                    const Text("Tags", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.photo.hashtags.map((tag) => Chip(label: Text("#$tag"))).toList(),
                    ),
                  ] else ...[
                    // --- EDIT MODE ---
                    const Text("Edit Description", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(controller: _descriptionController, maxLines: 3),
                    const SizedBox(height: 20),
                    const Text("Edit Tags (space separated)", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(controller: _hashtagController),
                    const SizedBox(height: 30),

                    // Action Buttons: Save and Delete
                    // Inside the 'Row' under the '--- EDIT MODE ---' section
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15)),
                            onPressed: _saveChanges,
                            child: const Text("SAVE CHANGES", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // DELETE BUTTON
                        IconButton(
                          onPressed: () => _deletePhoto(context),
                          icon: const Icon(Icons.delete_forever, color: Colors.red, size: 30),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Text("Posted by ${widget.photo.authorName} on $formattedDate",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deletePhoto(BuildContext context) async {
    final currentUser = ref.read(currentUserProvider);

    try {
      await FirebaseFirestore.instance.collection('photos').doc(widget.photo.id).delete();

      // LOG THE ACTION
      LoggerService().logAction(
        userId: currentUser?.email ?? "Unknown",
        operation: "DELETE_POST",
        details: "Deleted Photo ID: ${widget.photo.id} (Author: ${widget.photo.authorName})",
      );

      if (mounted) {
        Navigator.pop(context); // Go back to gallery
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post deleted successfully")),
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}