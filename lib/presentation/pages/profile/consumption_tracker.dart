import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../../../di.dart';
import '../../../domain/models/user_entity.dart';
import '../../../domain/models/package_config.dart';

class ConsumptionTracker extends ConsumerWidget {
  const ConsumptionTracker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Get the LIVE data from our providers
    final postCount = ref.watch(userPostCountProvider);
    final userAsync = ref.watch(userStreamProvider);

    final currentTier = userAsync.value?.package ?? PackageTier.free;

    // OPEN/CLOSE PRINCIPLE: Maps below enum objects to their independent strategy object
    // This removes the need for hardcoded switch/if statements inside the UI.
    final Map<PackageTier, PackageStrategy> packageStrategies = {
      PackageTier.free: FreePackageStrategy(),
      PackageTier.pro: ProPackageStrategy(),
      PackageTier.gold: GoldPackageStrategy(),
    };

    final activeStrategy = packageStrategies[currentTier] ?? FreePackageStrategy();
    final config = PackageConfig.fromStrategy(activeStrategy);

    // Figuring out the limit text dynamically using OCP states
    final bool isUnlimited = currentTier == PackageTier.gold;
    final String limitText = isUnlimited ? "∞" : config.dailyUploadLimit.toString();

    double progress = isUnlimited
        ? 0.0
        : (postCount / config.dailyUploadLimit).clamp(0.0, 1.0);

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
            Text("$postCount / $limitText"),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: isUnlimited ? 1.0 : progress, // Gold shows full/infinite bar
          backgroundColor: Colors.grey[200],
          color: isUnlimited
              ? Colors.amber
              : (progress >= 1.0 ? Colors.red : Colors.black),
          minHeight: 8,
        ),
      ],
    );
  }
}