import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy Data
    final notifications = [
      {
        "title": "Election Started!",
        "msg": "Voting for President has begun. Cast your vote now.",
        "time": "1 hour ago",
        "isRead": false,
      },
      {
        "title": "Reminder: Voter Verification",
        "msg": "Please verify your voter ID at the admin office.",
        "time": "Yesterday",
        "isRead": true,
      },
      {
        "title": "Results Announced: Sports Sec",
        "msg": "Rahul M has been elected as the new Sports Secretary.",
        "time": "2 days ago",
        "isRead": true,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        automaticallyImplyLeading: false, 
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];
          final bool isRead = notif['isRead'] as bool;

          return Card(
            color: isRead ? Colors.white : const Color(0xFFE8F5E9), // Light green for unread
            elevation: isRead ? 1 : 2,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(
                Icons.notifications,
                color: isRead ? Colors.grey : const Color(0xFF00C853),
              ),
              title: Text(
                notif['title'] as String,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif['msg'] as String),
                    const SizedBox(height: 6),
                    Text(
                      notif['time'] as String,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
