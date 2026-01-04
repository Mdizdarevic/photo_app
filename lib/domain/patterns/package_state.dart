import '../models/user_entity.dart';

abstract class UserPackageState {
  bool canUpload(int currentUploads, int limit);
  UserPackageState changePackage(PackageTier newTier);
}

class ActivePackageState implements UserPackageState {
  final PackageTier tier;
  ActivePackageState(this.tier);

  @override
  bool canUpload(int currentUploads, int limit) {
    return currentUploads < limit;
  }

  @override
  UserPackageState changePackage(PackageTier newTier) {
    return PendingPackageState(currentTier: tier, nextTier: newTier, effectiveDate: _getNextMidnight());
  }

  DateTime _getNextMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }
}

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
    return currentUploads < limit;
  }

  @override
  UserPackageState changePackage(PackageTier newTier) {
    print("Change already pending for tomorrow.");
    return this;
  }
}