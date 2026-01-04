import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../di.dart';
import '../../presentation/pages/admin/admin_dashboard.dart';
import '../../presentation/pages/profile/upgrade_plan.dart';
import '../../../domain/models/user_entity.dart';

// Command interface
abstract class Command {
  void execute();
}

// Concrete Command: Sign Out
class SignOutCommand implements Command {
  final WidgetRef ref;
  SignOutCommand(this.ref);

  @override
  void execute() {
    ref.read(currentUserProvider.notifier).state = null;
  }
}

// Concrete Command: Upgrade Plan
class UpgradePlanCommand implements Command {
  final BuildContext context;
  final UserEntity user;
  UpgradePlanCommand(this.context, this.user);

  @override
  void execute() {
    UpgradePlan.show(context, user);
  }
}

// Concrete Command: Open Admin Dashboard
class OpenAdminDashboardCommand implements Command {
  final BuildContext context;
  OpenAdminDashboardCommand(this.context);

  @override
  void execute() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboard()),
    );
  }
}

// Invokers that call the commands when pressed

// Button for AppBar actions
class AppBarCommandButton extends StatelessWidget {
  final Command command;
  final Widget child;

  const AppBarCommandButton({super.key, required this.command, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => command.execute(),
      child: child,
    );
  }
}

// Full-width button for body content
class BodyCommandButton extends StatelessWidget {
  final Command command;
  final Widget child;
  final Color? backgroundColor;

  const BodyCommandButton({super.key, required this.command, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => command.execute(),
        child: child,
      ),
    );
  }
}
