import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/election_provider.dart';
import 'vote_success_screen.dart';

class CandidateListScreen extends StatelessWidget {
  final String electionId;
  final String electionTitle;
  final bool isVotingActive;
  final bool isCreator;
  
  const CandidateListScreen({
    super.key, 
    required this.electionId,
    required this.electionTitle,
    this.isVotingActive = true,
    this.isCreator = false,
  });

  final List<Color> _chartColors = const [
    Colors.blue, Colors.red, Colors.orange, Colors.green, Colors.purple, 
    Colors.teal, Colors.amber, Colors.pink, Colors.cyan, Colors.indigo
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(electionTitle),
        actions: [
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              tooltip: "Delete Election",
              onPressed: () => _confirmDelete(context),
            ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('elections')
            .doc(electionId)
            .collection('candidates')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final candidates = snapshot.data!.docs;

          if (candidates.isEmpty) {
             return Center(
               child: Column(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
                   const SizedBox(height: 16),
                   const Text(
                     "No Voting Options Found",
                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                   ),
                   const SizedBox(height: 8),
                   const Text(
                     "This election might have been interrupted\nduring creation.",
                     textAlign: TextAlign.center,
                     style: TextStyle(color: Colors.grey),
                   ),
                 ],
               ),
             );
          }

          return Column(
            children: [
              if (!isVotingActive) _buildPieChart(candidates),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: candidates.length,
                  itemBuilder: (context, index) {
              final cand = candidates[index].data() as Map<String, dynamic>;
              final candId = candidates[index].id;
              final Color itemColor = isVotingActive ? Theme.of(context).primaryColor : _chartColors[index % _chartColors.length];
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: isVotingActive ? () => _confirmVote(context, candId, cand['name'] ?? 'This Option') : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Generic Option Icon
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: itemColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_circle_outline, color: itemColor),
                        ),
                        const SizedBox(width: 16),
                        
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Text(
                                cand['name'] ?? 'Untitled Option',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D3436),
                                ),
                               ),
                               if (cand['description'] != null && cand['description'].toString().isNotEmpty)
                                 Padding(
                                   padding: const EdgeInsets.only(top: 4),
                                   child: Text(
                                     cand['description'],
                                     style: const TextStyle(color: Colors.grey, fontSize: 13),
                                     maxLines: 2,
                                     overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                            ],
                          ),
                        ),
                        
                        if (isVotingActive)
                          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
                        else
                          // Show vote count for non-active (completed) elections
                          Column(
                            children: [
                              Text(
                                "${cand['voteCount'] ?? 0}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF00C853),
                                ),
                              ),
                              const Text("votes", style: TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPieChart(List<QueryDocumentSnapshot> candidates) {
    int totalVotes = 0;
    for (var doc in candidates) {
      final cand = doc.data() as Map<String, dynamic>;
      totalVotes += (cand['voteCount'] as int?) ?? 0;
    }

    if (totalVotes == 0) {
      return const Padding(
        padding: EdgeInsets.all(24.0),
        child: Text("No votes recorded yet.", style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: candidates.asMap().entries.map((entry) {
            final cand = entry.value.data() as Map<String, dynamic>;
            final votes = (cand['voteCount'] as int?) ?? 0;
            final percentage = (votes / totalVotes) * 100;
            
            return PieChartSectionData(
              value: votes.toDouble(),
              title: '${percentage.toStringAsFixed(1)}%',
              color: _chartColors[entry.key % _chartColors.length],
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold, 
                color: Colors.white,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext parentContext) {
    // Grab provider before showing dialog to avoid stale context
    final electionProvider = parentContext.read<ElectionProvider>();

    showDialog(
      context: parentContext,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Delete Election?"),
        content: const Text("Are you sure? This will delete the election, all candidates, and all votes. This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(dialogCtx); // close dialog
              try {
                await electionProvider.deleteElection(electionId);
                if (parentContext.mounted) {
                  Navigator.pop(parentContext); // go back to list
                  ScaffoldMessenger.of(parentContext).showSnackBar(const SnackBar(content: Text("Election deleted.")));
                }
              } catch (e) {
                if (parentContext.mounted) {
                  ScaffoldMessenger.of(parentContext).showSnackBar(SnackBar(content: Text("Error: $e")));
                }
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmVote(BuildContext parentContext, String candidateId, String candidateName) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Confirm Vote"),
        content: Text("Are you sure you want to vote for $candidateName?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              _submitVote(parentContext, candidateId, candidateName);
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVote(BuildContext context, String candidateId, String candidateName) async {
    final electionProvider = context.read<ElectionProvider>();

    final result = await electionProvider.castVote(
      electionId: electionId,
      candidateId: candidateId,
    );

    if (!context.mounted) return;

    if (result == 'already_voted') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You have already voted! Showing receipt...")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VoteSuccessScreen(
            electionTitle: electionTitle,
            candidateName: candidateName,
          ),
        ),
      );
    } else if (result != null) {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    } else {
      // Success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VoteSuccessScreen(
            electionTitle: electionTitle,
            candidateName: candidateName,
          ),
        ),
      );
    }
  }
}
