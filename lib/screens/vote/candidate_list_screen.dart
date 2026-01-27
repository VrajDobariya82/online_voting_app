import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
             print("Error loading candidates: ${snapshot.error}");
             return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final candidates = snapshot.data!.docs;
          print("Loaded ${candidates.length} candidates for election $electionId");

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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final cand = candidates[index].data() as Map<String, dynamic>;
              final candId = candidates[index].id;
              
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
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.check_circle_outline, color: Theme.of(context).primaryColor),
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
                          const Text("Disabled", style: TextStyle(color: Colors.grey, fontSize: 12)),
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

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Election?"),
        content: const Text("Are you sure? This will delete the election and all votes. This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context); // close dialog
              await FirebaseFirestore.instance.collection('elections').doc(electionId).delete();
              if (context.mounted) {
                 Navigator.pop(context); // go back to list
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Election deleted.")));
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
              _submitVote(parentContext, candidateId); // Use STABLE parent context
            },
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _submitVote(BuildContext context, String candidateId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    print("Submitting vote for candidate $candidateId..."); // Debug

    try {
       final electionRef = FirebaseFirestore.instance.collection('elections').doc(electionId);
       
       // Check if already voted
       final voteDoc = await electionRef.collection('votes').doc(user.uid).get();
       if (voteDoc.exists) {
         print("User already voted. Redirecting to receipt..."); // Debug
         if (!context.mounted) return;
         
         // Show a quick message
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("You have already voted! Showing receipt...")),
         );
         
         // Navigate to Success Screen to show receipt
         Navigator.pushReplacement(
           context,
           MaterialPageRoute(
             builder: (_) => VoteSuccessScreen(electionTitle: electionTitle),
           ),
         );
         return;
       }

       print("Starting transaction..."); // Debug

       // Transaction to increment count
       await FirebaseFirestore.instance.runTransaction((transaction) async {
          // 1. Record Vote
          transaction.set(electionRef.collection('votes').doc(user.uid), {
             'votedAt': FieldValue.serverTimestamp(),
             'candidateId': candidateId,
          });

          // 2. Increment Candidate Count
          final candRef = electionRef.collection('candidates').doc(candidateId);
          transaction.update(candRef, {
            'voteCount': FieldValue.increment(1),
          });
       });
       
       print("Transaction success! Navigating..."); // Debug
       
       if (!context.mounted) {
         print("Context not mounted, cannot navigate."); // Debug
         return;
       }
       
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(
           builder: (_) => VoteSuccessScreen(electionTitle: electionTitle),
         ),
       );

    } catch (e) {
      print("Transaction failed: $e"); // Debug
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error voting: $e")));
    }
  }
}
