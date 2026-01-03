import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_entity.dart';
import '../../domain/patterns/user_factory.dart';
import 'logger_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final LoggerService _logger = LoggerService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Helper to fetch persistent data from Firestore
  Future<PackageTier> _fetchUserTier(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final tierString = data['package'] as String?;
        return PackageTier.values.firstWhere(
              (e) => e.name == tierString,
          orElse: () => PackageTier.free,
        );
      }
    } catch (e) {
      _logger.logAction(userId: uid, operation: "FETCH_TIER_ERROR", details: e.toString());
    }
    return PackageTier.free;
  }

  // --- RE-ADDED: Local Account Registration ---
  Future<UserEntity?> registerWithEmail(String email, String password, PackageTier tier) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      User? user = result.user;
      if (user != null) {
        // IMPORTANT: Save the initial tier to Firestore so it persists!
        await _db.collection('users').doc(user.uid).set({
          'email': email,
          'package': tier.name,
          'lastTierChangeRequest': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

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

  // --- Google Sign-In with Persistence ---
  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      if (result.user != null) {
        final savedTier = await _fetchUserTier(result.user!.uid);
        return UserFactory.createUser(
          id: result.user!.uid,
          email: result.user!.email ?? "",
          role: UserRole.registered,
          package: savedTier,
        );
      }
    } catch (e) {
      _logger.logAction(userId: "SYSTEM", operation: "GOOGLE_ERROR", details: e.toString());
    }
    return null;
  }

  // --- GitHub Sign-In with Persistence ---
  Future<UserEntity?> signInWithGithub() async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      UserCredential result = await _auth.signInWithProvider(githubProvider);
      if (result.user != null) {
        final savedTier = await _fetchUserTier(result.user!.uid);
        return UserFactory.createUser(
          id: result.user!.uid,
          email: result.user!.email ?? "github_user@app.com",
          role: UserRole.registered,
          package: savedTier,
        );
      }
    } catch (e) {
      _logger.logAction(userId: "SYSTEM", operation: "GITHUB_ERROR", details: e.toString());
    }
    return null;
  }

  Future<UserEntity?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
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
    await GoogleSignIn().signOut();
  }
}