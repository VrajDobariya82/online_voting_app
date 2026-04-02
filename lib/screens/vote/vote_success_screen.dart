import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VoteSuccessScreen extends StatelessWidget {
  final String electionTitle;
  final String? candidateName;

  const VoteSuccessScreen({
    super.key,
    required this.electionTitle,
    this.candidateName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00C853), size: 100),
            const SizedBox(height: 24),
            const Text(
              "Vote Recorded!",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Your vote has been successfully recorded.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6FA),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    electionTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  if (candidateName != null && candidateName!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.how_to_vote, size: 16, color: Color(0xFF00C853)),
                        const SizedBox(width: 6),
                        Text(
                          "Voted for: $candidateName",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF00C853),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    "Time: ${DateFormat('MMM d, y • h:mm a').format(DateTime.now())}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "You cannot vote again in this election.",
              style: TextStyle(color: Colors.redAccent, fontSize: 14),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Back to Home"),
            ),
          ],
        ),
      ),
    );
  }
}
