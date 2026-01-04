import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import '../../../domain/models/photo_entity.dart';
import '../../../domain/models/user_entity.dart';
import '../../../domain/patterns/hashtag_processor.dart';
import '../../../domain/patterns/image_strategy.dart';
import '../../../domain/patterns/photo_facade.dart';

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

  final PhotoFacade _facade = PhotoFacade(); // --- FACADE INSTANCE

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

  Future<void> _saveChanges() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final rawInput = RawUserInput(_hashtagController.text);
    final IHashtagProcessor adapter = HashtagAdapter(rawInput);
    final updatedTags = adapter.getFormattedTags();

    try {
      await _facade.saveChanges(
        photo: widget.photo,
        description: _descriptionController.text,
        hashtags: updatedTags,
        currentUser: currentUser,
      );

      setState(() => _isEditing = false);

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

  Future<void> _deletePhoto(BuildContext context) async {
    final currentUser = ref.read(currentUserProvider);

    try {
      await _facade.deletePhoto(photo: widget.photo, currentUser: currentUser);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post deleted")),
        );
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

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
    ImageProcessingStrategy? strategy;
    if (filterType == "sepia") strategy = SepiaStrategy(); // calling strategy
    if (filterType == "blur") strategy = BlurStrategy(); // calling strategy

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image downloaded as ${filterType ?? 'Original'}...")),
      );
    }

    try {
      final file = await _facade.downloadPhoto(
        url: widget.photo.thumbnailUrl,
        strategy: strategy,
      );

      if (mounted) {
        final label = filterType ?? 'Original';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$label image downloaded"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Download failed: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().format(widget.photo.uploadDate);
    final currentUser = ref.watch(currentUserProvider);

    final bool isRegisteredUser = currentUser != null && currentUser.role != UserRole.anonymous;
    final bool isAdmin = currentUser?.role == UserRole.admin;
    final bool isOwner = isRegisteredUser &&
        (currentUser.email?.toLowerCase().split('@')[0] == widget.photo.authorName.toLowerCase());
    final bool canManage = isAdmin || isOwner;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text(_isEditing ? "Edit Details" : widget.photo.authorName),
        actions: [
          if (canManage)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
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
              child: Image.network(
                  widget.photo.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isEditing) ...[
                    _buildInfoSection("Description", widget.photo.description),
                    const SizedBox(height: 20),
                    const Text("Tags", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: widget.photo.hashtags.map((tag) => Chip(label: Text("#$tag"))).toList(),
                    ),
                  ] else ...[
                    const Text("Edit Description", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(controller: _descriptionController, maxLines: 3),
                    const SizedBox(height: 20),
                    const Text("Edit Tags (space separated)", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextField(controller: _hashtagController),
                    const SizedBox(height: 30),
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
