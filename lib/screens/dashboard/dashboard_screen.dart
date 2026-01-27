import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../elections/create_election_screen.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onSwitchToElections;

  const DashboardScreen({super.key, this.onSwitchToElections});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome Header
              StreamBuilder<DocumentSnapshot>(
                stream: user != null 
                  ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots()
                  : null,
                builder: (context, snapshot) {
                  final data = snapshot.data?.data() as Map<String, dynamic>?;
                  final name = data?['name'] ?? user?.displayName ?? 'Voter';
                  final voterId = data?['voterId'] ?? 'Loading...';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Welcome, $name",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: Colors.grey.shade300),
                         ),
                         child: Text(
                           "Voter ID: $voterId",
                           style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                         )
                      ),
                    ],
                  );
                },
              ),
              
              const SizedBox(height: 30),

              // Header
              // ... Header Code is fine ...

              // Real-time Election Stats
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('elections').snapshots(),
                builder: (context, snapshot) {
                   int activeCount = 0;
                   Map<String, dynamic>? nextElection;
                   DateTime? nextDate;
                   
                   // Voting Status (Checking if user voted in *Active* elections is expensive here without complex queries)
                   // Simplified: Just show "Check Elections" or keep dummy "Not Voted" until we query specific election.
                   // Or query 'votes' collectionGroup (requires index) or just check local logic.
                   // For now, let's just show Active Count and Next Election accurately.
                   
                   if (snapshot.hasData) {
                     final now = DateTime.now();
                     for (var doc in snapshot.data!.docs) {
                       final data = doc.data() as Map<String, dynamic>;
                       
                       // Defensive Parsing
                       if (data['startTime'] == null || data['endTime'] == null) continue;
                       Timestamp? startTs = data['startTime'] as Timestamp?;
                       Timestamp? endTs = data['endTime'] as Timestamp?;
                       
                       if (startTs == null || endTs == null) continue;

                       final start = startTs.toDate();
                       final end = endTs.toDate();
                       
                       if (now.isAfter(start) && now.isBefore(end)) {
                         activeCount++;
                       }
                       
                       // Find next upcoming
                       if (now.isBefore(start)) {
                         if (nextDate == null || start.isBefore(nextDate)) {
                           nextDate = start;
                           nextElection = data;
                         }
                       }
                     }
                   }

                   return Column(
                     children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                label: "Active Elections",
                                value: "$activeCount Ongoing",
                                icon: Icons.how_to_vote,
                                color: const Color(0xFF00C853),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildSummaryCard(
                                label: "Next Election",
                                value: nextDate != null 
                                  ? "${nextDate.day}/${nextDate.month}" 
                                  : "None",
                                icon: Icons.calendar_today,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSummaryCard(
                          label: "Voting Status",
                          value: "Tap to Check", 
                          icon: Icons.check_circle_outline,
                          color: Colors.blueAccent,
                          isFullWidth: true,
                        ),
                     ],
                   );
                }
              ),

              const SizedBox(height: 30),

              // Go To Elections Button
              ElevatedButton.icon(
                onPressed: () {
                  if (onSwitchToElections != null) {
                    onSwitchToElections!();
                  } else {
                     // Fallback if not passed (though MainScreen will pass it)
                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Use bottom nav to view elections")));
                  }
                },
                icon: const Icon(Icons.arrow_forward),
                label: const Text("Go to Elections"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),

              const SizedBox(height: 30),

              // Create Election Button
              ElevatedButton.icon(
                onPressed: () {
                    // Navigate to Create Election Flow
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateElectionScreen()),
                    );
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text("Create Election"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF00C853),
                  side: const BorderSide(color: Color(0xFF00C853)),
                ),
              ),

              const SizedBox(height: 30),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                  ]
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Voting Guidelines", style: TextStyle(fontWeight: FontWeight.bold)),
                          Text("Ensure you are in a private area while voting.", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label, 
    required String value, 
    required IconData icon, 
    required Color color,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              if (isFullWidth) ...[
                const SizedBox(width: 12),
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ]
            ],
          ),
          const SizedBox(height: 12),
          if (!isFullWidth)
             Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (!isFullWidth) const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
          ),
        ],
      ),
    );
  }
}
