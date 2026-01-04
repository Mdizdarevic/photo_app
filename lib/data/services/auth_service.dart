import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_entity.dart';
import '../../domain/patterns/user_factory.dart';
import 'logger_service.dart';

// User registration must be enabled using a local account (4 points for LO1 Minimum),
// Google, and Github (4 points for LO1 Desired) – LO1

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
    }
    return PackageTier.free;
  }

  //  Local Account Registration
  Future<UserEntity?> registerWithEmail(String email, String password, PackageTier tier) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      User? user = result.user;
      if (user != null) {
        final String roleToSave = (email.toLowerCase().trim() == "admin@pothole.com")
            ? UserRole.admin.name
            : UserRole.registered.name;

        await _db.collection('users').doc(user.uid).set({
          'email': email,
          'package': tier.name,
          'role': roleToSave,
          'lastTierChangeRequest': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        LoggerService().logAction(
          userId: email,
          operation: "USER_SIGN_UP",
          details: "Account registered as $roleToSave with ${tier.name} tier",
        );

        return UserFactory.createUser(
          id: user.uid,
          email: email,
          role: (roleToSave == "admin") ? UserRole.admin : UserRole.registered,
          package: tier,
        );
      }
    } catch (e) {
      debugPrint("SIGN UP FAILED: $e");
    }
    return null;
  }

  Future<UserEntity?> signInWithEmail(String email, String password) async {
    try {
      // 1. Tell Firebase to check existing credentials
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        // 2. Get their data from Firestore
        final doc = await _db.collection('users').doc(result.user!.uid).get();

        final data = doc.data() ?? {};

        return UserFactory.createUser(
          id: result.user!.uid,
          email: result.user!.email!,
          role: _parseRole(data['role']),
          package: _parsePackage(data['package']),
        );
      }
    } catch (e) {
      debugPrint("SIGN IN ERROR: $e");
      rethrow;
    }
    return null;
  }

  UserRole _parseRole(String? r) => UserRole.values.firstWhere((e) => e.name == r, orElse: () => UserRole.registered);
  PackageTier _parsePackage(String? p) => PackageTier.values.firstWhere((e) => e.name == p, orElse: () => PackageTier.free);

  // --- Google Sign-In  ---
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

        LoggerService().logAction(
          userId: result.user!.email ?? "Social User",
          operation: "USER_SIGN_IN",
          details: "Social login via ${result.credential?.providerId ?? 'Provider'}",
        );

        return UserFactory.createUser(
          id: result.user!.uid,
          email: result.user!.email ?? "",
          role: UserRole.registered,
          package: savedTier,
        );
      }
    } catch (e) {
    }
    return null;
  }

  // --- GitHub Sign-In  ---
  Future<UserEntity?> signInWithGithub() async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      UserCredential result = await _auth.signInWithProvider(githubProvider);
      if (result.user != null) {
        final savedTier = await _fetchUserTier(result.user!.uid);

        LoggerService().logAction(
          userId: result.user!.email ?? "Social User",
          operation: "USER_SIGN_IN",
          details: "Social login via ${result.credential?.providerId ?? 'Provider'}",
        );

        return UserFactory.createUser(
          id: result.user!.uid,
          email: result.user!.email ?? "github_user@app.com",
          role: UserRole.registered,
          package: savedTier,
        );
      }
    } catch (e) {
    }
    return null;
  }

  Future<UserEntity?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();

      LoggerService().logAction(
        userId: result.user!.uid, // Use UID as they have no email
        operation: "USER_SIGN_IN_ANON",
        details: "Guest access granted",
      );

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
    final String? userEmail = _auth.currentUser?.email;

    await _auth.signOut();
    await GoogleSignIn().signOut();

    LoggerService().logAction(
      userId: userEmail ?? "Unknown User",
      operation: "USER_SIGN_OUT",
      details: "User manually signed out",
    );
  }
}