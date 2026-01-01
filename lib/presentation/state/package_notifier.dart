import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/patterns/package_state.dart';
import '../../domain/models/user_entity.dart';

class PackageNotifier extends StateNotifier<UserPackageState> {
  PackageNotifier(PackageTier initialTier) : super(ActivePackageState(initialTier));

  void requestPackageChange(PackageTier newTier) {
    state = state.changePackage(newTier);
    // Logic: Save this pending change to Firebase so it persists
  }

  // Check if we need to refresh the state (call this on app start/resume)
  void refreshPackageStatus() {
    if (state is PendingPackageState) {
      final pending = state as PendingPackageState;
      if (DateTime.now().isAfter(pending.effectiveDate)) {
        state = ActivePackageState(pending.nextTier);
      }
    }
  }
}