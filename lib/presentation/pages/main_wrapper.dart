import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_app/presentation/pages/profile/profile_page.dart';
import 'package:photo_app/presentation/pages/upload/upload_page.dart';
import '../../../di.dart';
import '../../data/services/logger_service.dart';
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
    final user = ref.watch(currentUserProvider);
    final isSearchVisible = ref.watch(isSearchVisibleProvider);

    final List<Widget> _pages = [
      const GalleryPage(),
      const GalleryPage(),
      user == null ? const LoginPage() : ProfilePage(user: user),
    ];

    return Scaffold(
      body: Stack(
        children: [
          _pages[_getMappedIndex(_selectedIndex)],

          // User can search photos based on given filter – 8 points for LO3 Minimum
          if (isSearchVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0, // Sits exactly above the BottomNavigationBar
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: TextField(
                  autofocus: true,
                  onChanged: (val) {
                    // 1. Update the search state for the UI
                    ref.read(searchProvider.notifier).state = val;

                    // 2. Log the action
                    if (val.isNotEmpty) {
                      final currentUser = ref.read(currentUserProvider);

                      LoggerService().logAction(
                        userId: currentUser?.email ?? "Guest",
                        operation: "SEARCH_GALLERY",
                        details: "Query: $val",
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "Search tags, dates, or authors...",
                    prefixIcon: const Icon(Icons.search, color: Colors.black),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        ref.read(isSearchVisibleProvider.notifier).state = false;
                        ref.read(searchProvider.notifier).state = ""; // Clear search on close
                      },
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            // 1. Toggle Search Bar
            final isSearchVisible = ref.read(isSearchVisibleProvider);
            ref.read(isSearchVisibleProvider.notifier).state = !isSearchVisible;
            setState(() => _selectedIndex = index);
          } else if (index == 2) {
            // Check if user is anonymous/guest
            if (user == null || user.role.toString().contains('anonymous')) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Guests cannot upload photos. Please sign in!"),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              return;
            }

            // 2. Consumption Check for the "Post" button
            final postCount = ref.read(userPostCountProvider);
            final limit = ref.read(packageLimitProvider);

            // If limit is null (Gold), it always allows the upload.
            // If limit exists and count is >= limit, block the upload.
            if (limit != null && postCount >= limit) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Package limit reached ($postCount/$limit). Upgrade to Pro or Gold!"),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UploadPage()),
              );
            }
          } else {
            // 3. Close search bar if navigating to Home or Profile
            ref.read(isSearchVisibleProvider.notifier).state = false;
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

  int _getMappedIndex(int navIndex) {
    if (navIndex == 3) return 2;
    return navIndex;
  }
}