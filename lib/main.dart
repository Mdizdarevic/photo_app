import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:photo_app/presentation/pages/splash_screen.dart';
import 'firebase_options.dart'; // The file you just generated
import 'presentation/pages/auth/login_page.dart'; // Ensure this path is correct
import 'presentation/core/app_theme.dart'; // Your custom theme

void main() async {
  // Required for Firebase initialization
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // This connects your code to the Firebase Project (photo-app-72886)
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(
    // ProviderScope is required for Riverpod (Dependency Injection)
    const ProviderScope(
      child: PhotoVaultApp(),
    ),
  );
}

class PhotoVaultApp extends StatelessWidget {
  const PhotoVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoVault',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme, // Use your defined theme
      // Starting with LoginPage fixes the red "title" lookup error
      home: const SplashScreen(),
    );
  }
}