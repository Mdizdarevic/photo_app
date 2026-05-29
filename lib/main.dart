import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:photo_app/presentation/pages/profile/consumption_tracker.dart';
import 'package:photo_app/presentation/pages/splash_screen.dart';
import 'di.dart';
import 'domain/models/user_entity.dart';
import 'firebase_options.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/core/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }

  runApp(
    const ProviderScope(
      child: PhotoApp(),
    ),
  );
}

class PhotoApp extends StatelessWidget {
  const PhotoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PhotoApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

// void main() {
//   runApp(
//     ProviderScope(
//       overrides: [
//         userPostCountProvider.overrideWith((ref) => 2),
//         userStreamProvider.overrideWith((ref) => Stream.value(
//             UserEntity(id: '1', email: 'test@app.com', role: UserRole.registered, package: PackageTier.free)
//         )),
//       ],
//       child: const MaterialApp(
//         home: Scaffold(
//           body: Center(
//             child: Padding(
//               padding: EdgeInsets.all(24.0),
//               child: ConsumptionTracker(),
//             ),
//           ),
//         ),
//       ),
//     ),
//   );
// }