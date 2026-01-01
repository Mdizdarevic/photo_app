import '../models/user_entity.dart';

abstract class UserFactory {
  // The Factory Method
  static UserEntity createUser({
    required String id,
    required String email,
    required UserRole role,
    PackageTier package = PackageTier.free,
  }) {
    switch (role) {
      case UserRole.admin:
        return UserEntity(
          id: id,
          email: email,
          role: UserRole.admin,
          package: PackageTier.gold, // Admins get top-tier access
        );
      case UserRole.registered:
        return UserEntity(
          id: id,
          email: email,
          role: UserRole.registered,
          package: package,
        );
      case UserRole.anonymous:
      default:
        return UserEntity(
          id: "anon_01",
          email: "guest@app.com",
          role: UserRole.anonymous,
          package: PackageTier.free,
        );
    }
  }
}