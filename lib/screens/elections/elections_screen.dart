import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/election_provider.dart';
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
           final elections = snapshot.data!.docs.map((doc) => {...(doc.data() as Map<String, dynamic>), 'id': doc.id}).toList();

           // Group by status
           final ongoing = <Map<String, dynamic>>[];
           final upcoming = <Map<String, dynamic>>[];
           final completed = <Map<String, dynamic>>[];

           for (var e in elections) {
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
              if (election['imageUrl'] != null && election['imageUrl'].toString().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    election['imageUrl'],
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
                ),
              if (election['imageUrl'] != null && election['imageUrl'].toString().isNotEmpty)
                const SizedBox(height: 12),
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
                        _confirmDelete(context, election['id']);
                      },
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
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

  void _confirmDelete(BuildContext parentContext, String electionId) {
    // Grab provider reference from the parent (screen) context BEFORE showing dialog
    final electionProvider = parentContext.read<ElectionProvider>();

    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Delete Election?"),
        content: const Text("This will delete the election, all candidates, and all votes. This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // close dialog first
              try {
                await electionProvider.deleteElection(electionId);
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text("Election deleted.")));
                }
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
