import 'package:flutter/material.dart';

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
        children: const [
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Change Password'),
          ),
          ListTile(
            leading: Icon(Icons.notifications_active),
            title: Text('Notification Preferences'),
          ),
          ListTile(
            leading: Icon(Icons.help_outline),
            title: Text('Help & Support'),
          ),
        ],
      ),
    );
  }
}
