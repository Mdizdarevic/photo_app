import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import '../../../di.dart';
import '../../../domain/models/user_entity.dart';

// inside widgets/consumption_tracker.dart

// inside widgets/consumption_tracker.dart

class ConsumptionTracker extends ConsumerWidget {
  const ConsumptionTracker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the LIVE data from our providers
    final postCount = ref.watch(userPostCountProvider);
    final limit = ref.watch(packageLimitProvider); // This returns 10, 50, or null
    final userAsync = ref.watch(userStreamProvider);

    final currentTier = userAsync.value?.package ?? PackageTier.free;
    final bool isUnlimited = limit == null;

    // 2. Determine the limit text (10, 50, or ∞)
    String limitText;
    if (isUnlimited) {
      limitText = "∞";
    } else {
      limitText = limit.toString();
    }

    // 3. Calculate progress bar percentage
    double progress = isUnlimited ? 0.0 : (postCount / limit).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                "${currentTier.name.toUpperCase()} PLAN",
                style: const TextStyle(fontWeight: FontWeight.bold)
            ),
            // THIS IS THE FIX: It now uses the dynamic limitText
            Text("$postCount / $limitText"),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: isUnlimited ? 1.0 : progress, // Gold shows full/infinite bar
          backgroundColor: Colors.grey[200],
          color: isUnlimited ? Colors.amber : (progress >= 1.0 ? Colors.red : Colors.black),
          minHeight: 8,
        ),
      ],
    );
  }
}