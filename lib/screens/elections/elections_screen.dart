import 'package:flutter/material.dart';

class ElectionsScreen extends StatelessWidget {
  const ElectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elections'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            ElectionCard(
              title: 'Student Council Election',
              date: '15 Oct 2026',
            ),
            ElectionCard(
              title: 'Department Representative Election',
              date: '22 Oct 2026',
            ),
            ElectionCard(
              title: 'University Senate Election',
              date: '30 Oct 2026',
            ),
          ],
        ),
      ),
    );
  }
}

class ElectionCard extends StatelessWidget {
  final String title;
  final String date;

  const ElectionCard({
    super.key,
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Date: $date',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Vote'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
