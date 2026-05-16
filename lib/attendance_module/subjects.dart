import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nova_app/attendance_module/information.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final List<TextEditingController> _controllers = [];

  void _addTextField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeTextField(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  void _handleConfirm() {
    List<String> subjects = _controllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one subject')),
      );
      return;
    }

    // 1. Encode the JSON locally inside the action method
    String jsonSubjects = jsonEncode({'subjects': subjects});

    // 2. Navigate immediately and pass the freshly generated JSON string directly
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InformationPage(subjectsJson: jsonSubjects),
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Subjects'),
        centerTitle: true,
      ),
      body: _controllers.isEmpty
          ? Center(
              child: Text(
                'No subjects added yet.\nTap the + button to start.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _controllers.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  key: UniqueKey(),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          decoration: InputDecoration(
                            labelText: 'Subject ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _removeTextField(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'add_btn',
            onPressed: _addTextField,
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          if (_controllers.isNotEmpty)
            FloatingActionButton.extended(
              heroTag: 'confirm_btn',
              onPressed: _handleConfirm, // Fixed: Point directly to the handling method
              label: const Text('Confirm'),
              icon: const Icon(Icons.check),
              backgroundColor: Colors.green,
            ),
        ],
      ),
    );
  }
}