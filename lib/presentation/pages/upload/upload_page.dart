import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import '../../../domain/patterns/image_strategy.dart';
import '../../core/app_theme.dart';

class UploadPage extends ConsumerStatefulWidget {
  const UploadPage({super.key});

  @override
  ConsumerState<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends ConsumerState<UploadPage> {
  File? _selectedImage;
  String _activeFilter = "None";

  // Logic to pick image and apply Strategy Pattern
  void _applyFilter(ImageProcessingStrategy strategy, String name) async {
    if (_selectedImage == null) return;

    final processor = ref.read(imageProcessorProvider);
    processor.setStrategy(strategy);

    final processedFile = await processor.executeProcessing(_selectedImage!);
    setState(() {
      _selectedImage = processedFile;
      _activeFilter = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    // LO1: Access user's package limits
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("NEW POST")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Preview Area
            Container(
              height: 300,
              width: double.infinity,
              color: AppTheme.lightGrey,
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.contain)
                  : const Center(child: Text("SELECT A PHOTO")),
            ),

            // LO4: Filter Selection (Strategy Pattern UI)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("SELECT FILTER", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _filterButton("None", () => setState(() => _activeFilter = "None")),
                _filterButton("Sepia", () => _applyFilter(SepiaStrategy(), "Sepia")),
                _filterButton("Blur", () => _applyFilter(BlurStrategy(), "Blur")),
              ],
            ),

            // Metadata Inputs (LO2)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const TextField(decoration: InputDecoration(labelText: "DESCRIPTION")),
                  const SizedBox(height: 15),
                  const TextField(decoration: InputDecoration(labelText: "HASHTAGS (comma separated)")),
                  const SizedBox(height: 30),

                  // Upload Button with Package Check
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // LO1: Enforce daily limit check here
                        if (user!.photosUploadedToday >= 5) { // Example limit
                          _showLimitReached();
                        } else {
                          // Proceed with Firebase Upload
                        }
                      },
                      child: const Text("PUBLISH"),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterButton(String label, VoidCallback onTap) {
    bool isActive = _activeFilter == label;
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? AppTheme.black : AppTheme.white,
        foregroundColor: isActive ? AppTheme.white : AppTheme.black,
      ),
      child: Text(label),
    );
  }

  void _showLimitReached() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Daily limit reached! Upgrade to PRO for more."))
    );
  }
}