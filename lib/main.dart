import 'package:flutter/material.dart';
// import 'package:nova_app/attendance_module/subjects.dart';
// import 'package:nova_app/tasks_module/tasks_module.dart';
// import 'package:nova_app/landing_module/home_page.dart';
import 'package:nova_app/routes/routes.dart';
// import 'package:nova_app/landing_module/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: Routes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
