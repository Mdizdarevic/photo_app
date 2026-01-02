import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../di.dart';
import 'gallery/gallery_page.dart';
// Import your providers here

class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({super.key});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();

  final List<Widget> _pages = [
    const GalleryPage(),
    const Center(child: Text("Search Page")),
    const Center(child: Text("Profile Page")),
  ];

  // The actual Upload Logic
  Future<void> _onUploadPressed() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = 'pothole_${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        // USE 'ref' DIRECTLY HERE.
        // Do not use (ref as WidgetRef) or context.
        final service = ref.read(storageServiceProvider);

        final String downloadUrl = await service.uploadPhoto(
          imageFile,
          fileName,
        );

        await FirebaseFirestore.instance.collection('photos').add({
          'thumbnailUrl': downloadUrl,
          'uploadDate': FieldValue.serverTimestamp(),
          'authorName': 'User', // You can pull this from your Auth state later
          'description': 'Pothole report',
          'hashtags': ['#pothole', '#infrastructure'],
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload Successful!")),
        );

      } catch (e) {
        debugPrint("UPLOAD ERROR: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_getMappedIndex(_selectedIndex)],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            _onUploadPressed(); // Opens Gallery
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        // ... keep your existing BottomNavigationBar styling ...
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined, size: 30), label: 'Post'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  int _getMappedIndex(int navIndex) => navIndex == 3 ? 2 : navIndex;
}