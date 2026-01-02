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

  PackageTier _selectedTier = PackageTier.free; // Keeps track of selection
  bool _isSigningUp = false; // Toggles Sign In vs Sign Up

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
                _isSigningUp ? "Create Account" : "Welcome Back!",
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

              // TIER SELECTION (Only shows for Sign Up)
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
                const SizedBox(height: 24),
              ],

              // EMAIL FIELD
              _buildTextField("Email Address", _emailController),
              const SizedBox(height: 16),

              // PASSWORD FIELD
              _buildTextField("Password", _passwordController, isObscure: true),

              const SizedBox(height: 32),

              // MAIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_isSigningUp) {
                      final user = await ref.read(authServiceProvider).registerWithEmail(
                          _emailController.text,
                          _passwordController.text,
                          _selectedTier
                      );
                      if (user != null) {
                        ref.read(currentUserProvider.notifier).state = user;
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainWrapper()));
                      }
                    } else {
                      // Login logic for existing account
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

              if (_isSigningUp) ...[// --- GOOGLE & GITHUB BUTTONS ---
                Row(
                  children: [
                    // Google
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
                    // GitHub
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
              ],
              const SizedBox(height: 16),

              // TOGGLE BETWEEN SIGN IN / SIGN UP
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

              // GUEST BYPASS
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

  // Tier selection helper
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

  // Rounded Text Field helper
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