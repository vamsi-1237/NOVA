import "package:flutter/material.dart";
// Note: we intentionally avoid importing `routes.dart` here to prevent a
// circular import: `routes.dart` imports this splash screen. We use the
// literal route name string when navigating below.

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

    // Schedule navigation after the current frame to ensure a Navigator
    // is available and then replace the splash with the landing page.
    // We navigate using the literal route name '/landing' (defined in
    // lib/routes/routes.dart) to avoid importing that file here and
    // creating a circular import.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/landing');
    });
  }

  @override
  Widget build(BuildContext context) {

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
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
    )
    );
    }
}