import 'package:flutter/material.dart';
import 'package:nova_app/attendance_module/attendance_page.dart';
import 'package:nova_app/attendance_module/information.dart';
import 'package:nova_app/attendance_module/subjects.dart';
import 'package:nova_app/attendance_module/subject_stat.dart';
import 'package:nova_app/tasks_module/screens/add_task_screen.dart';
import 'package:nova_app/tasks_module/screens/task_detail_screen.dart';
import 'package:nova_app/tasks_module/screens/task_screen.dart';
import 'package:nova_app/tasks_module/models/task.dart';
import 'package:nova_app/events_module/add_event.dart';
import 'package:nova_app/events_module/event_details.dart';
import 'package:nova_app/events_module/events_page.dart';
import 'package:nova_app/landing_module/landing_page.dart';
import 'package:nova_app/landing_module/google_callback_page.dart';
import 'package:nova_app/landing_module/splash_screen.dart';
import 'package:nova_app/landing_module/login_page.dart';
import 'package:nova_app/landing_module/signup_page.dart';
import 'package:nova_app/landing_module/home_page.dart';
import 'package:nova_app/events_module/event_model.dart';
import 'package:nova_app/scheduler/scheduler_test_page.dart';
import 'package:nova_app/scheduler/schedule_results_page.dart';




class Routes {
  static const splash = '/splash';
  static const landing = '/landing';
  static const home = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const oauthGoogleCallback = '/oauth/google/callback';
  static const tasks = '/tasks';
  static const addTask = '/tasks/add';
  static const taskDetail = '/tasks/detail';
  static const events = '/events';
  static const addEvent = '/events/add';
  static const eventDetail = '/events/detail';
  static const schedulerTest = '/scheduler/test';
  static const scheduleResults = '/scheduler/results';

  static const attendance = '/attendance'; // subjects / onboarding
  static const information = '/attendance/information'; // takes subjectsJson (String)
  static const attendancePage = '/attendance/page'; // takes timetableJson (String)
  static const subjectStat = '/attendance/stat'; // takes Map args
}

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case Routes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case Routes.landing:
        return MaterialPageRoute(builder: (_) => const LandingPage());
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case Routes.login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case Routes.signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case Routes.oauthGoogleCallback:
        return MaterialPageRoute(builder: (_) => const GoogleCallbackPage());
      case Routes.tasks:
        return MaterialPageRoute(builder: (_) => const TaskScreen());
      case Routes.addTask:
        return MaterialPageRoute(builder: (_) => const AddTaskScreen());
      case Routes.taskDetail:
        if (args is Task) {
          return MaterialPageRoute(builder: (_) => TaskDetailScreen(task: args));
        }
        return _errorRoute('Invalid arguments for TaskDetail');
      case Routes.events:
        return MaterialPageRoute(builder: (_) => const EventsPage());
      case Routes.addEvent:
        if (args is Event) {
          return MaterialPageRoute(builder: (_) => AddEventScreen(event: args));
        }
        return MaterialPageRoute(builder: (_) => const AddEventScreen());
      case Routes.eventDetail:
        if (args is Event) {
          return MaterialPageRoute(builder: (_) => EventDetailsScreen(event: args));
        }
        return _errorRoute('Invalid arguments for EventDetails');
      case Routes.schedulerTest:
        return MaterialPageRoute(builder: (_) => const SchedulerTestPage());
      case Routes.scheduleResults:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(builder: (_) => ScheduleResultsPage(results: args));
        }
        return _errorRoute('Invalid arguments for ScheduleResults');
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
