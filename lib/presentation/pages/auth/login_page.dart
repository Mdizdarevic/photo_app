import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import '../../../domain/models/user_entity.dart';
import '../../core/app_theme.dart';
import '../gallery/gallery_page.dart';
import '../main_wrapper.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  PackageTier _selectedTier = PackageTier.free;
  bool _isSigningUp = false;

  // 1. Helper to provide the text details
  String _getTierDescription() {
    switch (_selectedTier) {
      case PackageTier.free:
        return "Free: 3 posts/day, JPG format, and standard resizing.";
      case PackageTier.pro:
        return "Pro: 20 posts/day, PNG/JPG support, and custom photo filters.";
      case PackageTier.gold:
        return "Gold: Unlimited posts, max resolution, and full creative control.";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Text(
                _isSigningUp ? "Create Account." : "Please Sign In.",
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              Text(
                _isSigningUp
                    ? "Choose a tier and enter your details."
                    : "Enter your login information",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              if (_isSigningUp) ...[
                const Text("SELECT YOUR TIER",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTierOption("FREE", PackageTier.free),
                    _buildTierOption("PRO", PackageTier.pro),
                    _buildTierOption("GOLD", PackageTier.gold, isGold: true),
                  ],
                ),

                // 2. THE DYNAMIC INFO TEXT
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getTierDescription(),
                          style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _buildTextField("Email Address", _emailController),
              const SizedBox(height: 16),
              _buildTextField("Password", _passwordController, isObscure: true),
              const SizedBox(height: 32),

              // MAIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    UserEntity? user;

                    if (_isSigningUp) {
                      // SIGN UP MODE
                      user = await ref.read(authServiceProvider).registerWithEmail(
                          _emailController.text.trim(),
                          _passwordController.text,
                          _selectedTier
                      );
                    } else {
                      // SIGN IN MODE - ADDED THIS
                      user = await ref.read(authServiceProvider).signInWithEmail(
                        _emailController.text.trim(),
                        _passwordController.text,
                      );
                    }

                    if (user != null) {
                      ref.read(currentUserProvider.notifier).state = user;
                      if (context.mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
                      }
                    } else {
                      // Optional: Show error message if login fails
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Authentication Failed. Check credentials.")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(_isSigningUp ? "Sign Up" : "Sign In"),
                ),
              ),

              const SizedBox(height: 24),

              // SOCIAL BUTTONS (Only if signing up/signing in)
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final user = await ref.read(authServiceProvider).signInWithGoogle();
                        if (user != null) {
                          ref.read(currentUserProvider.notifier).state = user;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Image.asset('assets/images/google_logo.png', height: 24),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final user = await ref.read(authServiceProvider).signInWithGithub();
                        if (user != null) {
                          ref.read(currentUserProvider.notifier).state = user;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
                        }
                      },
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Image.asset('assets/images/github_logo.png', height: 24),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_isSigningUp ? "Already have an Account?" : "Don't have an account?"),
                  TextButton(
                    onPressed: () => setState(() => _isSigningUp = !_isSigningUp),
                    child: Text(
                      _isSigningUp ? "Sign In" : "Sign Up",
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const MainWrapper()),
                  ),
                  child: const Text("Continue as Guest", style: TextStyle(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierOption(String label, PackageTier tier, {bool isGold = false}) {
    bool isSelected = _selectedTier == tier;
    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isSelected ? (isGold ? const Color(0xFFFFD700) : Colors.black) : Colors.grey[300]!,
              width: 2
          ),
          color: isSelected && !isGold ? Colors.black : Colors.white,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
                color: isSelected && !isGold ? Colors.white : (isGold && isSelected ? const Color(0xFFB8860B) : Colors.black),
                fontWeight: FontWeight.bold,
                fontSize: 12
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}