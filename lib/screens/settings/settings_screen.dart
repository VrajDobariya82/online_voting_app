import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showChangePasswordDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Notification Preferences'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notification preferences coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showHelpDialog(context),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SmartVote',
                applicationVersion: '1.0.0',
                children: [
                  const Text('SmartVote is a secure digital voting platform.'),
                ],
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Logout", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<AppAuthProvider>().signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Change Password"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                obscureText: true,
                validator: (val) => (val == null || val.isEmpty) ? 'Enter current password' : null,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter new password';
                  if (val.length < 6) return 'Password must be at least 6 chars';
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                validator: (val) => val != newPasswordController.text ? 'Passwords do not match' : null,
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              final error = await context.read<AppAuthProvider>().changePassword(
                currentPassword: currentPasswordController.text,
                newPassword: newPasswordController.text,
              );

              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                if (error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error), backgroundColor: Colors.red),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password changed successfully!")),
                  );
                }
              }
            },
            child: const Text("Change"),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Help & Support"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Need help with SmartVote?", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text("• For voting issues, ensure the election is active."),
            SizedBox(height: 6),
            Text("• Voter ID verification is handled by admin."),
            SizedBox(height: 6),
            Text("• Each voter can only vote once per election."),
            SizedBox(height: 12),
            Text("Contact: support@smartvote.app", style: TextStyle(color: Colors.blue)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
      ),
    );
  }
}
