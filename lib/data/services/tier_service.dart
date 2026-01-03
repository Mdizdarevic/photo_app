import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/user_entity.dart';
import '../../../di.dart';

class TierService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Changes the package immediately.
  /// Requirement: Only allowed once per day.
  // data/services/tier_service.dart

  // data/services/tier_service.dart
  Future<String?> changeTierInstant(UserEntity user, PackageTier newTier, WidgetRef ref) async {
    try {
      // This creates or updates the document permanently
      await _db.collection('users').doc(user.id).set({
        'package': newTier.name, // Saves as "pro" or "gold"
        'lastTierChangeRequest': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Update local state so the UI reflects it immediately
      ref.read(currentUserProvider.notifier).state = user.copyWith(package: newTier);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

final tierServiceProvider = Provider((ref) => TierService());