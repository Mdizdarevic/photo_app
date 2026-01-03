import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_app/presentation/pages/profile/profile_page.dart';
import 'package:photo_app/presentation/pages/upload/upload_page.dart';
import '../../../di.dart'; // Ensure this points to where your providers are
import 'auth/login_page.dart';
import 'gallery/gallery_page.dart';

class MainWrapper extends ConsumerStatefulWidget {
  const MainWrapper({super.key});

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Watch the current user state
    final user = ref.watch(currentUserProvider);

    // Dynamic pages list
    final List<Widget> _pages = [
      const GalleryPage(),
      const Center(child: Text("Search Page")),
      // If user is null, the "Profile" tab shows the Login/Signup screen
      user == null ? const LoginPage() : ProfilePage(user: user),
    ];

    return Scaffold(
      // Maps bottom nav indices to the _pages list
      body: _pages[_getMappedIndex(_selectedIndex)],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 2) {
            // "Post" button - Navigate to the dedicated Upload page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UploadPage()),
            );
          } else {
            // Switch tabs normally
            setState(() => _selectedIndex = index);
          }
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black45,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_rounded),
              label: 'Gallery'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined, size: 30),
              label: 'Post'
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profile'
          ),
        ],
      ),
    );
  }

  /// Maps the 4 BottomNav items to the 3 available widgets in _pages
  /// Nav Index 0 (Gallery) -> _pages[0]
  /// Nav Index 1 (Search)  -> _pages[1]
  /// Nav Index 2 (Post)    -> Handled by Navigator
  /// Nav Index 3 (Profile) -> _pages[2]
  int _getMappedIndex(int navIndex) {
    if (navIndex == 3) return 2;
    return navIndex;
  }
}