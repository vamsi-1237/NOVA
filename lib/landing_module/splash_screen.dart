import "package:flutter/material.dart";
import 'package:nova_app/routes/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    _navigateToLanding();
  }

  Future<void> _navigateToLanding() async {

    await Future.delayed(
      const Duration(seconds: 5),
    );

    if (!mounted) return;


    Navigator.pushReplacementNamed(
      context,
      Routes.landing,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 90,
            ),

            const SizedBox(height: 30),

            const Text(
              "NOVA",
              style: TextStyle(
                color: Colors.white,
                fontSize: 52,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              width: 180,

              child: const LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: Colors.white12,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}