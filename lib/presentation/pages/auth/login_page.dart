import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import '../../../domain/models/user_entity.dart';
import '../../core/app_theme.dart';
import '../gallery/gallery_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  PackageTier _selectedTier = PackageTier.free; // Default selection

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("PHOTOVAULT",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4)),
            const Text("SELECT YOUR TIER", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 40),

            // Tier Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTierOption("FREE", PackageTier.free),
                _buildTierOption("PRO", PackageTier.pro),
                _buildTierOption("GOLD", PackageTier.gold, isGold: true),
              ],
            ),
            const SizedBox(height: 40),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "EMAIL"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "PASSWORD"),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final user = await ref.read(authServiceProvider).registerWithEmail(
                      _emailController.text,
                      _passwordController.text,
                      _selectedTier
                  );
                  if (user != null) {
                    ref.read(currentUserProvider.notifier).state = user;
                    // Navigate to Gallery
                  }
                },
                child: const Text("CREATE ACCOUNT"),
              ),
            ),

            Center(
              child: TextButton(
                onPressed: () {
                  // This tells the app to move to the Gallery
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GalleryPage()),
                  );
                },
                child: const Text("Continue as Guest"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierOption(String label, PackageTier tier, {bool isGold = false}) {
    bool isSelected = _selectedTier == tier;
    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(
              color: isSelected ? (isGold ? AppTheme.gold : AppTheme.black) : Colors.grey[300]!,
              width: 2
          ),
          color: isSelected && !isGold ? AppTheme.black : AppTheme.white,
        ),
        child: Text(
          label,
          style: TextStyle(
              color: isSelected && !isGold ? AppTheme.white : (isGold && isSelected ? AppTheme.gold : AppTheme.black),
              fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }
}