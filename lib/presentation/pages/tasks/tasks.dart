import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Tasks extends StatelessWidget {
  const Tasks({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tasks')),
        body: const Center(child: Text('Please log in to view tasks.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('admin')
            .doc(user.uid)
            .collection('log_entry')
            .orderBy('date', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tasks found.'));
          }

          // Separate pending and completed tasks
          final entries = snapshot.data!.docs;
          final pendingEntries = entries
              .where((doc) =>
          (doc.data() as Map<String, dynamic>)['status'] == 'pending')
              .toList();
          final completedEntries = entries
              .where((doc) =>
          (doc.data() as Map<String, dynamic>)['status'] == 'completed')
              .toList();

          // Group by week
          final groupedPending = _groupEntriesByWeek(pendingEntries);
          final groupedCompleted = _groupEntriesByWeek(completedEntries);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pending Tasks Section
                Container(
                  margin: const EdgeInsets.all(16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PENDING TASKS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      groupedPending.isEmpty
                          ? const Text(
                        'No pending tasks.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      )
                          : Column(
                        children: groupedPending.entries.map((week) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WEEK ${week.key}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...week.value.map((entry) {
                                final data =
                                entry.data() as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.access_time,
                                      color: Colors.blue,
                                      size: 24,
                                    ),
                                    title: Text(
                                      data['task'] ?? 'Untitled Task',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      data['supervisor'] ?? 'Unknown Supervisor',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.more_vert,
                                      color: Colors.black54,
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                // Completed Tasks Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.teal[50],
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'COMPLETED TASKS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      groupedCompleted.isEmpty
                          ? const Text(
                        'No completed tasks.',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      )
                          : Column(
                        children: groupedCompleted.entries.map((week) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WEEK ${week.key}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...week.value.map((entry) {
                                final data =
                                entry.data() as Map<String, dynamic>;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 24,
                                    ),
                                    title: Text(
                                      data['task'] ?? 'Untitled Task',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      data['supervisor'] ?? 'Unknown Supervisor',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    trailing: const Icon(
                                      Icons.more_vert,
                                      color: Colors.black54,
                                    ),
                                  ),
                                );
                              }).toList(),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Group entries by week relative to the earliest date
  Map<int, List<QueryDocumentSnapshot>> _groupEntriesByWeek(
      List<QueryDocumentSnapshot> entries) {
    final grouped = <int, List<QueryDocumentSnapshot>>{};
    if (entries.isEmpty) return grouped;

    // Find the earliest date
    final earliestDate = entries
        .map((e) => (e.data() as Map<String, dynamic>)['date'] as Timestamp)
        .reduce((a, b) => a.toDate().isBefore(b.toDate()) ? a : b)
        .toDate();

    for (var entry in entries) {
      final data = entry.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp).toDate();
      // Calculate week number (difference in days / 7, starting from 1)
      final daysDifference = date.difference(earliestDate).inDays;
      final weekNumber = (daysDifference ~/ 7) + 1;

      grouped.putIfAbsent(weekNumber, () => []).add(entry);
    }

    return grouped;
  }
}