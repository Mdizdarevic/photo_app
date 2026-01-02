import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Add this to pubspec.yaml
import '../../domain/models/user_entity.dart';
import '../../domain/patterns/user_factory.dart';
import 'logger_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final LoggerService _logger = LoggerService();

  // Stream to track auth state changes (Observer Pattern via Riverpod)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- LO1: Local Account Registration ---
  Future<UserEntity?> registerWithEmail(String email, String password, PackageTier tier) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      User? user = result.user;
      if (user != null) {
        _logger.logAction(userId: user.uid, operation: "REGISTER_LOCAL", details: "Tier: $tier");

        return UserFactory.createUser(
          id: user.uid,
          email: email,
          role: UserRole.registered,
          package: tier,
        );
      }
    } catch (e) {
      _logger.logAction(userId: "SYSTEM", operation: "REGISTER_ERROR", details: e.toString());
    }
    return null;
  }

  // --- LO1 Desired: Google Sign-In ---
  Future<UserEntity?> signInWithGoogle() async {
    try {
      _logger.logAction(userId: "PENDING", operation: "LOGIN_GOOGLE");

      // 1. Trigger the Google Authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // User cancelled

      // 2. Obtain auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create a new credential for Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase with the Google credential
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      if (user != null) {
        _logger.logAction(userId: user.uid, operation: "SUCCESS_GOOGLE");
        return UserFactory.createUser(
          id: user.uid,
          email: user.email ?? "",
          role: UserRole.registered,
          package: PackageTier.free, // Defaulting to free for social login
        );
      }
    } catch (e) {
      _logger.logAction(userId: "SYSTEM", operation: "GOOGLE_ERROR", details: e.toString());
    }
    return null;
  }

  // --- LO1 Desired: GitHub Sign-In ---
  Future<UserEntity?> signInWithGithub() async {
    try {
      _logger.logAction(userId: "PENDING", operation: "LOGIN_GITHUB");

      // 1. Use the GithubAuthProvider (Firebase handles the OAuth handshake)
      GithubAuthProvider githubProvider = GithubAuthProvider();

      // 2. Trigger the sign-in (Opens a secure web view on mobile)
      UserCredential result = await _auth.signInWithProvider(githubProvider);
      User? user = result.user;

      if (user != null) {
        _logger.logAction(userId: user.uid, operation: "SUCCESS_GITHUB");
        return UserFactory.createUser(
          id: user.uid,
          email: user.email ?? "github_user@app.com",
          role: UserRole.registered,
          package: PackageTier.free,
        );
      }
    } catch (e) {
      _logger.logAction(userId: "SYSTEM", operation: "GITHUB_ERROR", details: e.toString());
    }
    return null;
  }

  // --- LO1 Minimum: Anonymous Login ---
  Future<UserEntity?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      _logger.logAction(userId: result.user!.uid, operation: "LOGIN_ANONYMOUS");

      return UserFactory.createUser(
        id: result.user!.uid,
        email: "guest@app.com",
        role: UserRole.anonymous,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    // Sign out of Firebase
    await _auth.signOut();
    // Also sign out of Google to ensure the account picker shows up next time
    await GoogleSignIn().signOut();
  }
}