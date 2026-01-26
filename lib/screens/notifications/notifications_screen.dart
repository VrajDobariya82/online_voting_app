import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          NotificationTile(
            title: 'Vote Submitted Successfully',
            time: '2 minutes ago',
          ),
          NotificationTile(
            title: 'New Election Announced',
            time: '1 day ago',
          ),
          NotificationTile(
            title: 'Election Results Published',
            time: '3 days ago',
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends StatelessWidget {
  final String title;
  final String time;

  const NotificationTile({
    super.key,
    required this.title,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const Icon(Icons.notifications),
        title: Text(title),
        subtitle: Text(time),
      ),
    );
  }
}
