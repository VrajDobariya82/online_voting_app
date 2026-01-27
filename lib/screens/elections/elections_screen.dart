import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../vote/candidate_list_screen.dart';

class ElectionsScreen extends StatelessWidget {
  const ElectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Elections"),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('elections').orderBy('startTime', descending: true).snapshots(),
        builder: (context, snapshot) {
           if (snapshot.hasError) return const Center(child: Text("Error loading elections"));
           if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

           final today = DateTime.now();
           final elections = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>..['id'] = doc.id).toList();

           // Group by status
           // Note: Status field might be manual or calculated. Let's calculate based on time.
           final ongoing = <Map<String, dynamic>>[];
           final upcoming = <Map<String, dynamic>>[];
           final completed = <Map<String, dynamic>>[];

           for (var e in elections) {
             // Defensive Parsing
             if (e['startTime'] == null || e['endTime'] == null) continue;
             
             Timestamp? startTs = e['startTime'] as Timestamp?;
             Timestamp? endTs = e['endTime'] as Timestamp?;
             
             if (startTs == null || endTs == null) continue;

             final start = startTs.toDate();
             final end = endTs.toDate();
             
             String status;
             if (today.isBefore(start)) {
               status = 'Upcoming';
               upcoming.add(e);
             } else if (today.isAfter(end)) {
               status = 'Completed';
               completed.add(e);
             } else {
               status = 'Ongoing';
               ongoing.add(e);
             }
             e['computedStatus'] = status;
           }

           return ListView(
             padding: const EdgeInsets.all(16),
             children: [
               if (ongoing.isNotEmpty) ...[
                 _buildSectionHeader("Active Elections"),
                 ...ongoing.map((e) => _buildElectionCard(context, e, user?.uid)),
               ],
               if (upcoming.isNotEmpty) ...[
                 _buildSectionHeader("Upcoming Elections"),
                 ...upcoming.map((e) => _buildElectionCard(context, e, user?.uid)),
               ],
               if (completed.isNotEmpty) ...[
                 _buildSectionHeader("Completed Elections"),
                 ...completed.map((e) => _buildElectionCard(context, e, user?.uid)),
               ],
               if (elections.isEmpty)
                 const Center(child: Padding(padding: EdgeInsets.all(32), child: Text("No elections found."))),
             ],
           );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
      ),
    );
  }

  Widget _buildElectionCard(BuildContext context, Map<String, dynamic> election, String? currentUserId) {
    final status = election['computedStatus'];
    final isCreator = election['createdBy'] == currentUserId;
    Color statusColor;
    
    switch (status) {
      case 'Ongoing': statusColor = const Color(0xFF00C853); break;
      case 'Upcoming': statusColor = Colors.blue; break;
      default: statusColor = Colors.grey;
    }
    
    final dateStr = DateFormat('MMM d, y • h:mm a').format((election['startTime'] as Timestamp).toDate());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (_) => CandidateListScreen(
                   electionId: election['id'],
                   electionTitle: election['title'] ?? 'Election',
                   isVotingActive: status == 'Ongoing',
                   isCreator: isCreator,
                 ),
               ),
             );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   Expanded(
                     child: Text(
                      election['title'] ?? 'Untitled',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                     ),
                   ),
                  if (isCreator)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Delete Election?"),
                            content: const Text("This action cannot be undone."),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  FirebaseFirestore.instance.collection('elections').doc(election['id']).delete();
                                },
                                child: const Text("Delete", style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              if (isCreator)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text("Created by You", style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontStyle: FontStyle.italic)),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
