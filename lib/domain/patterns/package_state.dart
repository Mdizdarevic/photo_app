import '../models/user_entity.dart';

abstract class UserPackageState {
  bool canUpload(int currentUploads, int limit);
  // This logic handles the "valid from following day" requirement
  UserPackageState changePackage(PackageTier newTier);
}

/// Active State: The user is currently using their assigned package.
class ActivePackageState implements UserPackageState {
  final PackageTier tier;
  ActivePackageState(this.tier);

  @override
  bool canUpload(int currentUploads, int limit) {
    return currentUploads < limit;
  }

  @override
  UserPackageState changePackage(PackageTier newTier) {
    // Transition to Pending State because change is only valid tomorrow
    return PendingPackageState(currentTier: tier, nextTier: newTier, effectiveDate: _getNextMidnight());
  }

  DateTime _getNextMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }
}

/// Pending State: User requested a change, but they still have old limits until tomorrow.
class PendingPackageState implements UserPackageState {
  final PackageTier currentTier;
  final PackageTier nextTier;
  final DateTime effectiveDate;

  PendingPackageState({
    required this.currentTier,
    required this.nextTier,
    required this.effectiveDate
  });

  @override
  bool canUpload(int currentUploads, int limit) {
    // If we have passed the effective date, we should have transitioned,
    // but as a safety check, we enforce currentTier limits here.
    return currentUploads < limit;
  }

  @override
  UserPackageState changePackage(PackageTier newTier) {
    // Requirement: "Users can change the packet once a day"
    // We can block changes if one is already pending for today.
    print("Change already pending for tomorrow.");
    return this;
  }
}