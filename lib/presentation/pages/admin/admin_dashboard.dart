import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/services/logger_service.dart';
import '../../../di.dart';
import '../../../domain/models/user_entity.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "CONTROL CENTER",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              fontSize: 18,
            ),
          ),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.black,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
            tabs: [
              Tab(text: "USERS"),
              Tab(text: "GLOBAL STATS"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUserListTab(context, ref),
            const AdminStatsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserListTab(BuildContext context, WidgetRef ref) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        final users = snapshot.data!.docs.map((doc) => UserEntity.fromFirestore(doc)).toList();

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          itemCount: users.length,
          itemBuilder: (context, index) => _buildUserCard(context, ref, users[index]),
        );
      },
    );
  }

  Widget _buildUserCard(BuildContext context, WidgetRef ref, UserEntity userItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.black,
              child: Text(
                userItem.email[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userItem.email,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildTag(userItem.role.name.toUpperCase(), Colors.grey[800]!),
                      const SizedBox(width: 6),
                      _buildTag(userItem.package.name.toUpperCase(), _getTierColor(userItem.package)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Real-time post counter for this specific user
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_note_rounded, color: Colors.black, size: 28),
              onPressed: () => _showAdminEditDialog(context, ref, userItem),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getTierColor(PackageTier tier) {
    switch (tier) {
      case PackageTier.gold: return const Color(0xFFD4AF37);
      case PackageTier.pro: return Colors.blueAccent;
      default: return Colors.black;
    }
  }

  void _showAdminEditDialog(BuildContext context, WidgetRef ref, UserEntity targetUser) {
    PackageTier selectedTier = targetUser.package;
    UserRole selectedRole = targetUser.role;
    final adminEmail = ref.read(currentUserProvider)?.email ?? "Admin";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Manage ${targetUser.email}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildDropdown<PackageTier>(
                label: "PACKAGE PLAN",
                value: selectedTier,
                items: PackageTier.values,
                onChanged: (val) => setDialogState(() => selectedTier = val!),
              ),
              const SizedBox(height: 16),
              _buildDropdown<UserRole>(
                label: "ACCOUNT ROLE",
                value: selectedRole,
                items: UserRole.values,
                onChanged: (val) => setDialogState(() => selectedRole = val!),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () async {
                    await _updateUserByAdmin(targetUserId: targetUser.id, newTier: selectedTier, newRole: selectedRole, adminEmail: adminEmail);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text("APPLY CHANGES", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// Global Stats Tab - Refactored for clean UI
class AdminStatsTab extends StatelessWidget {
  const AdminStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getGlobalStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.black));
        final stats = snapshot.data!;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("SYSTEM OVERVIEW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 20),
              _statCard("Total Users", stats['totalUsers'].toString(), Icons.people_outline),
              _statCard("Total Photos", stats['totalPhotos'].toString(), Icons.photo_library_outlined),
              const SizedBox(height: 24),
              const Text("TIER DISTRIBUTION", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _miniStat("Pro", stats['proUsers'].toString(), Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(child: _miniStat("Gold", stats['goldUsers'].toString(), const Color(0xFFD4AF37))),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(icon, size: 20), const SizedBox(width: 12), Text(title, style: const TextStyle(fontWeight: FontWeight.bold))]),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Logic functions
Future<Map<String, dynamic>> _getGlobalStats() async {
  final usersSnap = await FirebaseFirestore.instance.collection('users').get();
  final photosSnap = await FirebaseFirestore.instance.collection('photos').count().get();
  int totalUsers = usersSnap.docs.length;
  int proUsers = usersSnap.docs.where((doc) => doc['package'] == 'pro').length;
  int goldUsers = usersSnap.docs.where((doc) => doc['package'] == 'gold').length;
  return {
    'totalUsers': totalUsers,
    'totalPhotos': photosSnap.count ?? 0,
    'proUsers': proUsers,
    'goldUsers': goldUsers,
  };
}

Future<void> _updateUserByAdmin({required String targetUserId, required PackageTier newTier, required UserRole newRole, required String adminEmail}) async {
  await FirebaseFirestore.instance.collection('users').doc(targetUserId).update({'package': newTier.name, 'role': newRole.name});
  LoggerService().logAction(userId: adminEmail, operation: "ADMIN_UPDATE_USER", details: "Changed User $targetUserId to ${newTier.name} / ${newRole.name}");
}

Widget _buildDropdown<T extends Enum>({required String label, required T value, required List<T> items, required ValueChanged<T?> onChanged}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e.name.toUpperCase(), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    ],
  );
}