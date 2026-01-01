import 'package:firebase_auth/firebase_auth.dart';
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

        // Use Factory Pattern to create the domain entity
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
    // Logic for GoogleAuthProvider.signInWithPopup() or signInWithRedirect()
    // Returns UserFactory.createUser(...)
    _logger.logAction(userId: "PENDING", operation: "LOGIN_GOOGLE");
    return null;
  }

  // --- LO1 Desired: GitHub Sign-In ---
  Future<UserEntity?> signInWithGithub() async {
    // Logic for GithubAuthProvider()
    // Returns UserFactory.createUser(...)
    _logger.logAction(userId: "PENDING", operation: "LOGIN_GITHUB");
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
    await _auth.signOut();
  }
}