import 'package:flutter/material.dart';

class SubjectStatistics extends StatelessWidget {
  final String subjectName;
  final int presentClasses;
  final int totalClasses;

  const SubjectStatistics({
    super.key,
    required this.subjectName,
    required this.presentClasses,
    required this.totalClasses,
  });

  double _calculatePercentage() {
    if (totalClasses == 0) return 0.0;
    return (presentClasses / totalClasses) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = _calculatePercentage();

    return Scaffold(
      appBar: AppBar(
        title: Text(subjectName),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Performance Overview',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildStatRow('Classes Present:', '$presentClasses'),
            const SizedBox(height: 16),
            _buildStatRow('Classes Conducted:', '$totalClasses'),
            const SizedBox(height: 24),
            const Divider(thickness: 1),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Attendance Percentage:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: percentage >= 75 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}