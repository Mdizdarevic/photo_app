import '../models/user_entity.dart';

abstract class UserFactory {
  static UserEntity createUser({
    required String id,
    required String email,
    required UserRole role,
    PackageTier package = PackageTier.free,
  }) {

    // 1. HARDCODED ADMIN OVERRIDE
    // This ensures that even if Firestore is empty/wrong, this email gets Admin powers.
    UserRole effectiveRole = role;

    if (email.toLowerCase().trim() == "admin@pothole.com") {
      effectiveRole = UserRole.admin;
    }

    switch (effectiveRole) {
      case UserRole.admin:
        return UserEntity(
          id: id,
          email: email,
          role: UserRole.admin,
          package: PackageTier.gold, // Admins always get Gold features
          photosUploadedToday: 0,
        );

      case UserRole.registered:
        return UserEntity(
          id: id,
          email: email,
          role: UserRole.registered,
          package: package,
          photosUploadedToday: 0,
        );

      case UserRole.anonymous:
      default:
        return UserEntity(
          id: id.isNotEmpty ? id : "anon_01",
          email: email.isNotEmpty ? email : "guest@app.com",
          role: UserRole.anonymous,
          package: PackageTier.free,
          photosUploadedToday: 0,
        );
    }
  }
}