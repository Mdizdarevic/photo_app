enum UserRole { anonymous, registered, admin }

enum PackageTier { free, pro, gold }

class UserEntity {
  final String id;
  final String email;
  final UserRole role;
  final PackageTier package; // This will update instantly now

  final int photosUploadedToday;
  final DateTime? lastUploadDate;

  // Requirement: "Users can change the packet once a day"
  final DateTime? lastTierChangeRequest;

  UserEntity({
    required this.id,
    required this.email,
    required this.role,
    this.package = PackageTier.free,
    this.photosUploadedToday = 0,
    this.lastUploadDate,
    this.lastTierChangeRequest,
  });

  UserEntity copyWith({
    PackageTier? package,
    int? photosUploadedToday,
    DateTime? lastUploadDate,
    DateTime? lastTierChangeRequest,
  }) {
    return UserEntity(
      id: id,
      email: email,
      role: role,
      package: package ?? this.package,
      photosUploadedToday: photosUploadedToday ?? this.photosUploadedToday,
      lastUploadDate: lastUploadDate ?? this.lastUploadDate,
      lastTierChangeRequest: lastTierChangeRequest ?? this.lastTierChangeRequest,
    );
  }
}