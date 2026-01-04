import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_app/presentation/pages/profile/consumption_tracker.dart';
import '../../../domain/models/user_entity.dart';
import '../../../domain/patterns/command_actions.dart';


class ProfilePage extends ConsumerWidget {
  final UserEntity user;

  const ProfilePage({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        actions: [
          AppBarCommandButton(
            command: SignOutCommand(ref),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Admin Control Center button (only for admins)
              if (user.role == UserRole.admin) ...[
                GestureDetector(
                  onTap: () => OpenAdminDashboardCommand(context).execute(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 32),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Icon(Icons.shield, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "ADMIN CONTROL CENTER",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "Manage users and view global stats",
                                style: TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.amber),
                      ],
                    ),
                  ),
                ),
              ],

              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black,
                child: Icon(Icons.person, size: 45, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                "EMAIL",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),
              const Text(
                "CURRENT PLAN",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              _buildTierBadge(user.package),
              const SizedBox(height: 32),
              const ConsumptionTracker(),
              const SizedBox(height: 32),
              BodyCommandButton(
                command: UpgradePlanCommand(context, user),
                backgroundColor: Colors.white,
                child: const Text(
                  "Change My Plan",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierBadge(PackageTier tier) {
    Color badgeColor;
    Color textColor = Colors.white;
    String label = tier.toString().split('.').last.toUpperCase();

    switch (tier) {
      case PackageTier.gold:
        badgeColor = const Color(0xFFFFD700);
        textColor = Colors.black;
        break;
      case PackageTier.pro:
        badgeColor = Colors.blueAccent;
        break;
      case PackageTier.free:
      default:
        badgeColor = Colors.black;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}