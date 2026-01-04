import 'package:cloud_firestore/cloud_firestore.dart';

// The application supports work with a registered, anonymous, and administrator type of
// user – 8 points for LO1 Minimum

enum UserRole { anonymous, registered, admin }

enum PackageTier { free, pro, gold }

class UserEntity {
  final String id;
  final String email;
  final UserRole role;
  final PackageTier package;

  final int photosUploadedToday;
  final DateTime? lastUploadDate;
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

  factory UserEntity.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserEntity(
      id: doc.id,
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      package: _parsePackage(data['package']),
      photosUploadedToday: data['photosUploadedToday'] ?? 0,
      lastUploadDate: (data['lastUploadDate'] as Timestamp?)?.toDate(),
      lastTierChangeRequest: (data['lastTierChangeRequest'] as Timestamp?)?.toDate(),
    );
  }

  // Helper to convert "admin" string to UserRole.admin
  static UserRole _parseRole(String? roleStr) {
    return UserRole.values.firstWhere(
          (e) => e.name == (roleStr ?? 'registered').toLowerCase(),
      orElse: () => UserRole.registered,
    );
  }

  // Helper to convert "pro" string to PackageTier.pro
  static PackageTier _parsePackage(String? packageStr) {
    return PackageTier.values.firstWhere(
          (e) => e.name == (packageStr ?? 'free').toLowerCase(),
      orElse: () => PackageTier.free,
    );
  }

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