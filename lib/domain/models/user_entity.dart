enum UserRole { anonymous, registered, admin }

enum PackageTier { free, pro, gold }

class UserEntity {
  final String id;
  final String email;
  final UserRole role;
  final PackageTier package;

  // Track consumption for the daily limit requirement
  final int photosUploadedToday;
  final DateTime? lastUploadDate;

  // Track if a package change is pending for tomorrow
  final PackageTier? pendingPackage;
  final DateTime? packageChangeDate;

  UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.package = PackageTier.free,
    this.photosUploadedToday = 0,
    this.lastUploadDate,
    this.pendingPackage,
    this.packageChangeDate,
  });

  // Helper to check if user is Admin (for LO2 Minimum)
  bool get isAdmin => role == UserRole.admin;

  // Helper to check if user is Anonymous (for LO2 Minimum)
  bool get isAnonymous => role == UserRole.anonymous;
}