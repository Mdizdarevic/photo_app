import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added for direct UID access
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../di.dart';
import '../../../domain/models/user_entity.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  File? _imageFile;
  bool _isUploading = false;
  final _descriptionController = TextEditingController();
  final _hashtagController = TextEditingController();

  // Utility to turn text like "#pothole, #city" into a clean list ['pothole', 'city']
  List<String> _parseHashtags(String input) {
    if (input.isEmpty) return [];
    return input
        .split(RegExp(r'[\s,]+'))
        .where((tag) => tag.isNotEmpty)
        .map((tag) => tag.replaceAll('#', '').toLowerCase().trim())
        .toList();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _handlePost() async {
    if (_imageFile == null) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please sign in to post.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final storageService = ref.read(storageServiceProvider);

      // 1. Unique filename for Storage
      String fileName = 'pothole_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 2. Upload the file to Storage and get the download URL
      final String downloadUrl = await storageService.uploadPhoto(
        _imageFile!,
        fileName,
      );

      // 3. Parse hashtags
      List<String> tags = _parseHashtags(_hashtagController.text);

      // 4. CREATE FIRESTORE RECORD (The 'Receipt' for the Gallery)
      await FirebaseFirestore.instance.collection('photos').add({
        'thumbnailUrl': downloadUrl,
        'uploadDate': FieldValue.serverTimestamp(),
        'authorName': user.email.split('@')[0], // Uses email prefix as name
        'authorId': user.id,
        'description': _descriptionController.text,
        'hashtags': tags,
        'tier': user.package.toString().split('.').last,
      });

      if (!mounted) return;

      // Navigate back and show success
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Post Successful!")),
      );

    } catch (e) {
      debugPrint("UPLOAD ERROR: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload failed: $e")),
        );
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("New Post",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image Preview Area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                )
                    : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
                    SizedBox(height: 8),
                    Text("Tap to select pothole photo",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            _buildInputLabel("Description"),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration("Write about the pothole..."),
            ),

            const SizedBox(height: 20),

            _buildInputLabel("Hashtags"),
            TextField(
              controller: _hashtagController,
              decoration: _inputDecoration("#pothole #broken #citylife"),
            ),
            const SizedBox(height: 8),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Separate tags with spaces or commas",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 40),

            // POST BUTTON
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_imageFile == null || _isUploading) ? null : _handlePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _isUploading
                    ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                )
                    : const Text("Post",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.all(16),
    );
  }
}