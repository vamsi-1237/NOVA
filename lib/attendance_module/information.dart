import 'dart:convert';
import 'package:flutter/material.dart';
// Make sure to update this import path based on your project structure
import 'package:nova_app/attendance_module/attendance_page.dart'; 
import 'package:nova_app/routes/routes.dart';

class InformationPage extends StatefulWidget {
  final String subjectsJson;

  const InformationPage({super.key, required this.subjectsJson});

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  List<String> _subjects = [];
  final List<String> _days = ['Day 1', 'Day 2', 'Day 3', 'Day 4', 'Day 5'];
  final Map<String, List<String>> _timetable = {};

  @override
  void initState() {
    super.initState();
    _parseSubjects();
    for (var day in _days) {
      _timetable[day] = [];
    }
  }

  void _parseSubjects() {
    try {
      final Map<String, dynamic> data = jsonDecode(widget.subjectsJson);
      if (data['subjects'] != null) {
        setState(() {
          _subjects = List<String>.from(data['subjects']);
        });
      }
    } catch (e) {
      setState(() {
        _subjects = [];
      });
    }
  }

  void _toggleSubjectForDay(String day, String subject) {
    setState(() {
      if (_timetable[day]!.contains(subject)) {
        _timetable[day]!.remove(subject);
      } else {
        _timetable[day]!.add(subject);
      }
    });
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Timetable'),
          content: const Text('Are you sure you want to save this timetable configuration?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                _submitTimetable();     // Process data and handle routing
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

  void _submitTimetable() {
    String finalTimetableJson = jsonEncode(_timetable);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Timetable saved successfully!')),
    );

    // Navigates to AttendancePage and flushes onboarding screens out of the backstack
    Navigator.pushNamedAndRemoveUntil(context, Routes.attendancePage, (route) => false, arguments: finalTimetableJson);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Timetable'),
        centerTitle: true,
      ),
      body: _subjects.isEmpty
          ? const Center(child: Text('No subjects found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                String day = _days[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          day,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _subjects.map((subject) {
                              bool isSelected = _timetable[day]!.contains(subject);
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(subject),
                                  selected: isSelected,
                                  selectedColor: Colors.blue.withOpacity(0.25),
                                  checkmarkColor: Colors.blue,
                                  onSelected: (_) => _toggleSubjectForDay(day, subject),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _showConfirmationDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            minimumSize: const Size.fromHeight(50),
          ),
          child: const Text(
            'Submit Timetable',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}