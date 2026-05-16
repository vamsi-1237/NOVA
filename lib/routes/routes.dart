import 'package:flutter/material.dart';
import 'package:nova_app/attendance_module/attendance_page.dart';
import 'package:nova_app/attendance_module/information.dart';
import 'package:nova_app/attendance_module/subjects.dart';
import 'package:nova_app/attendance_module/subject_stat.dart';
import 'package:nova_app/landing_page.dart';
import 'package:nova_app/tasks_module/screens/add_task_screen.dart';
import 'package:nova_app/tasks_module/screens/task_detail_screen.dart';
import 'package:nova_app/tasks_module/screens/task_screen.dart';
import 'package:nova_app/tasks_module/models/task.dart';

class Routes {
  static const landing = '/';
  static const tasks = '/tasks';
  static const addTask = '/tasks/add';
  static const taskDetail = '/tasks/detail';

  static const attendance = '/attendance'; // subjects / onboarding
  static const information = '/attendance/information'; // takes subjectsJson (String)
  static const attendancePage = '/attendance/page'; // takes timetableJson (String)
  static const subjectStat = '/attendance/stat'; // takes Map args
}

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.landing:
        return MaterialPageRoute(builder: (_) => const LandingPage());
      case Routes.tasks:
        return MaterialPageRoute(builder: (_) => const TaskScreen());
      case Routes.addTask:
        return MaterialPageRoute(builder: (_) => const AddTaskScreen());
      case Routes.taskDetail:
        if (args is Task) {
          return MaterialPageRoute(builder: (_) => TaskDetailScreen(task: args));
        }
        return _errorRoute('Invalid arguments for TaskDetail');
      case Routes.attendance:
        return MaterialPageRoute(builder: (_) => const SubjectsPage());
      case Routes.information:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => InformationPage(subjectsJson: args));
        }
        return _errorRoute('Invalid arguments for InformationPage');
      case Routes.attendancePage:
        if (args is String) {
          return MaterialPageRoute(builder: (_) => AttendancePage(timetableJson: args));
        }
        return _errorRoute('Invalid arguments for AttendancePage');
      case Routes.subjectStat:
        if (args is Map<String, dynamic>) {
          final name = args['subjectName'] as String? ?? '';
          final present = args['presentClasses'] as int? ?? 0;
          final total = args['totalClasses'] as int? ?? 0;
          return MaterialPageRoute(builder: (_) => SubjectStatistics(subjectName: name, presentClasses: present, totalClasses: total));
        }
        return _errorRoute('Invalid arguments for SubjectStatistics');
      default:
        return null;
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      );
    });
  }
}
