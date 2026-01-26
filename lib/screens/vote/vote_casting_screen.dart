// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';

class VoteCastingScreen extends StatefulWidget {
  const VoteCastingScreen({super.key});

  @override
  State<VoteCastingScreen> createState() => _VoteCastingScreenState();
}

class _VoteCastingScreenState extends State<VoteCastingScreen> {
  String? selectedCandidate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cast Your Vote'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Council Election',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            RadioListTile<String>(
              title: const Text('Candidate A'),
              value: 'A',
              groupValue: selectedCandidate,
              onChanged: (value) {
                setState(() {
                  selectedCandidate = value;
                });
              },
            ),

            RadioListTile<String>(
              title: const Text('Candidate B'),
              value: 'B',
              groupValue: selectedCandidate,
              onChanged: (value) {
                setState(() {
                  selectedCandidate = value;
                });
              },
            ),

            RadioListTile<String>(
              title: const Text('Candidate C'),
              value: 'C',
              groupValue: selectedCandidate,
              onChanged: (value) {
                setState(() {
                  selectedCandidate = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedCandidate == null ? null : () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Submit Vote'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Note: Once submitted, the vote cannot be changed.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
