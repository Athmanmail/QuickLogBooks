import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Activities extends StatefulWidget {
  const Activities({super.key});

  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  final _formKey = GlobalKey<FormState>();
  final _taskController = TextEditingController();
  final _skillsController = TextEditingController();
  final _lessonsController = TextEditingController();
  final _challengesController = TextEditingController();
  DateTime? _selectedDate;
  String _status = 'pending';
  String? _selectedSupervisor; // Store the selected supervisor's name
  bool _isLoading = false;

  // Save logbook entry to Firestore
  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedSupervisor != null) {
      setState(() => _isLoading = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in to save entries.')),
          );
          return;
        }

        final entryData = {
          'date': Timestamp.fromDate(_selectedDate!),
          'task': _taskController.text.trim(),
          'skills_learned': _skillsController.text.trim(),
          'lessons_learned': _lessonsController.text.trim(),
          'challenges_faced': _challengesController.text.trim(),
          'supervisor': _selectedSupervisor!,
          'status': _status,
        };

        await FirebaseFirestore.instance
            .collection('admin')
            .doc(user.uid)
            .collection('log_entry')
            .add(entryData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logbook entry saved successfully!')),
        );

        // Clear form
        _taskController.clear();
        _skillsController.clear();
        _lessonsController.clear();
        _challengesController.clear();
        setState(() {
          _selectedDate = null;
          _status = 'pending';
          _selectedSupervisor = null;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _selectedDate == null
                ? 'Please select a date.'
                : 'Please select a supervisor.',
          ),
        ),
      );
    }
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    _skillsController.dispose();
    _lessonsController.dispose();
    _challengesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Logbook Entry'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date Picker
                ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                // Task Field
                TextFormField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    labelText: 'Tasks Performed',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter tasks performed' : null,
                ),
                const SizedBox(height: 16),
                // Skills Learned Field
                TextFormField(
                  controller: _skillsController,
                  decoration: const InputDecoration(
                    labelText: 'Skills Learned',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter skills learned' : null,
                ),
                const SizedBox(height: 16),
                // Lessons Learned Field
                TextFormField(
                  controller: _lessonsController,
                  decoration: const InputDecoration(
                    labelText: 'Lessons Learned',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter lessons learned' : null,
                ),
                const SizedBox(height: 16),
                // Challenges Faced Field
                TextFormField(
                  controller: _challengesController,
                  decoration: const InputDecoration(
                    labelText: 'Challenges Faced',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  validator: (value) =>
                  value!.isEmpty ? 'Please enter challenges faced' : null,
                ),
                const SizedBox(height: 16),
                // Supervisor Dropdown
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('supervisors')
                      .orderBy('name')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Text('Error loading supervisors');
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No supervisors found');
                    }

                    final supervisors = snapshot.data!.docs
                        .map((doc) => doc['name'] as String)
                        .toList();

                    return DropdownButtonFormField<String>(
                      value: _selectedSupervisor,
                      decoration: const InputDecoration(
                        labelText: 'Supervisor',
                        border: OutlineInputBorder(),
                      ),
                      items: supervisors
                          .map((supervisor) => DropdownMenuItem(
                        value: supervisor,
                        child: Text(supervisor),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedSupervisor = value);
                      },
                      validator: (value) =>
                      value == null ? 'Please select a supervisor' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Status Dropdown
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: ['pending', 'completed']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.capitalize()),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _status = value!);
                  },
                ),
                const SizedBox(height: 20),
                // Submit Button
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _saveEntry,
                    child: const Text('Save Entry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}