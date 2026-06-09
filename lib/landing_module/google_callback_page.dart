import 'package:flutter/material.dart';
import 'package:nova_app/routes/routes.dart';

class GoogleCallbackPage extends StatelessWidget {
  const GoogleCallbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Callback'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 72),
              const SizedBox(height: 16),
              const Text(
                'Google verification completed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'You can return to Nova after the authorization flow finishes.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.home,
                  (route) => false,
                ),
                child: const Text('Continue to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}