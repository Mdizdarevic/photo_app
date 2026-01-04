import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../domain/patterns/package_state.dart';
import '../../domain/models/user_entity.dart';

class PackageNotifier extends StateNotifier<UserPackageState> {
  PackageNotifier(PackageTier initialTier) : super(ActivePackageState(initialTier));

  void requestPackageChange(PackageTier newTier) {
    state = state.changePackage(newTier);
  }

  void refreshPackageStatus() {
    if (state is PendingPackageState) {
      final pending = state as PendingPackageState;
      if (DateTime.now().isAfter(pending.effectiveDate)) {
        state = ActivePackageState(pending.nextTier);
      }
    }
  }
}