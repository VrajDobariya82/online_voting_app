import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        automaticallyImplyLeading: false, 
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('elections')
            .orderBy('createdAt', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Error loading notifications"));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final elections = snapshot.data!.docs;

          if (elections.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No notifications yet",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // Generate notifications from election events
          final now = DateTime.now();
          final List<Map<String, dynamic>> notifications = [];

          for (var doc in elections) {
            final data = doc.data() as Map<String, dynamic>;
            final title = data['title'] ?? 'Untitled Election';

            Timestamp? startTs = data['startTime'] as Timestamp?;
            Timestamp? endTs = data['endTime'] as Timestamp?;
            Timestamp? createdTs = data['createdAt'] as Timestamp?;

            if (startTs == null || endTs == null) continue;

            final start = startTs.toDate();
            final end = endTs.toDate();

            // Ongoing election notification
            if (now.isAfter(start) && now.isBefore(end)) {
              notifications.add({
                'title': 'Election Active!',
                'msg': 'Voting for "$title" is ongoing. Cast your vote now.',
                'time': _formatTime(start),
                'isRead': false,
                'icon': Icons.how_to_vote,
                'color': const Color(0xFF00C853),
              });
            }
            // Completed election notification
            else if (now.isAfter(end)) {
              notifications.add({
                'title': 'Election Completed',
                'msg': '"$title" has ended. Results are available.',
                'time': _formatTime(end),
                'isRead': true,
                'icon': Icons.check_circle,
                'color': Colors.grey,
              });
            }
            // Upcoming election notification
            else if (now.isBefore(start)) {
              notifications.add({
                'title': 'Upcoming Election',
                'msg': '"$title" starts on ${DateFormat('MMM d, y').format(start)}. Get ready to vote!',
                'time': _formatTime(createdTs?.toDate() ?? start),
                'isRead': true,
                'icon': Icons.schedule,
                'color': Colors.blue,
              });
            }
          }

          if (notifications.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("No notifications yet", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];
              final bool isRead = notif['isRead'] as bool;

              return Card(
                color: isRead ? Colors.white : const Color(0xFFE8F5E9),
                elevation: isRead ? 1 : 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    notif['icon'] as IconData,
                    color: notif['color'] as Color,
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
          );
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return DateFormat('MMM d, y').format(dateTime);
    }
  }
}
