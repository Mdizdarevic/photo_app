import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/user_entity.dart';
import '../../../di.dart';

// When registering a user, you have to choose one of the packages for use: FREE,
// PRO, or GOLD - limit the price of the package yourself (e.g., upload size, daily upload limit,
// maximum spend of uploaded photos, etc.)

class TierService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> changeTierInstant(UserEntity user, PackageTier newTier, WidgetRef ref) async {
    try {
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