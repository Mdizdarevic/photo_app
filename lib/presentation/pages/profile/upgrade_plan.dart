import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import '../../../domain/models/user_entity.dart';

class UpgradePlan extends ConsumerWidget {
  final UserEntity user;

  const UpgradePlan({super.key, required this.user});

  // Helper to show the sheet
  static void show(BuildContext context, UserEntity user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => UpgradePlan(user: user),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Select a New Plan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("You can change your plan once per day.",
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          // List of plans
          _planTile(context, ref, PackageTier.free, "Free", Colors.black),
          _planTile(context, ref, PackageTier.pro, "Pro", Colors.blueAccent),
          _planTile(context, ref, PackageTier.gold, "Gold", const Color(0xFFFFD700)),
        ],
      ),
    );
  }

  Widget _planTile(BuildContext context, WidgetRef ref, PackageTier tier, String name, Color color) {
    final isCurrent = user.package == tier;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(backgroundColor: color, radius: 12),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(isCurrent ? "Current Plan" : "Switch to $name instantly"),
      trailing: isCurrent ? const Icon(Icons.check_circle, color: Colors.green) : null,
      enabled: !isCurrent, // Disable the tile for the current plan
        onTap: () async {
          // 1. Grab the messenger while the context is still valid (before the await)
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);

          final error = await ref.read(tierServiceProvider).changeTierInstant(user, tier, ref);

          // 2. Close the sheet AFTER the work is done
          navigator.pop();

          // 3. Use the 'messenger' variable we saved earlier
          if (error != null) {
            messenger.showSnackBar(SnackBar(content: Text("Error: $error")));
          } else {
            messenger.showSnackBar(
              SnackBar(content: Text("Success! Plan changed to ${tier.name}")),
            );
          }
        },
    );
  }
}