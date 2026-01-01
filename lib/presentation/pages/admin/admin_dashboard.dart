import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import '../../core/app_theme.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Accessing the logger and photo repository
    final logger = ref.watch(loggerProvider);
    final photoRepo = ref.watch(photoRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("ADMIN COMMAND", style: TextStyle(color: AppTheme.gold)),
        backgroundColor: AppTheme.black,
        iconTheme: const IconThemeData(color: AppTheme.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatHeader(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("SYSTEM LOGS", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ),

            // LO3 Minimum: Viewing the logs recorded by LoggerService
            Container(
              height: 300,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                border: Border.all(color: AppTheme.black),
              ),
              child: ListView.builder(
                itemCount: 10, // Replace with actual log stream
                itemBuilder: (context, index) {
                  return const ListTile(
                    leading: Icon(Icons.history, size: 16),
                    title: Text("User_01 uploaded photo_99.jpg", style: TextStyle(fontSize: 12)),
                    subtitle: Text("2026-01-01 14:30:05", style: TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("MANAGE CONTENT", style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            // LO2 Desired: Admin can delete ANY photo
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.image, color: AppTheme.black),
                  title: const Text("Photo_ID: 9823"),
                  subtitle: const Text("Uploaded by: User_44"),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () {
                      // Logic to call photoRepo.deletePhoto(id)
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppTheme.black,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: "TOTAL USERS", value: "142"),
          _StatItem(label: "UPLOADS TODAY", value: "28"),
          _StatItem(label: "SERVERS", value: "ONLINE", isGold: true),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final bool isGold;
  const _StatItem({required this.label, required this.value, this.isGold = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(value, style: TextStyle(
            color: isGold ? AppTheme.gold : AppTheme.white,
            fontWeight: FontWeight.bold,
            fontSize: 18)
        ),
      ],
    );
  }
}