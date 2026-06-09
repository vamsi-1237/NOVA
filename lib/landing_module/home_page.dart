import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nova_app/utils/api_caller.dart';
import 'package:nova_app/routes/routes.dart';
import 'package:nova_app/utils/auth_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _authenticated = false;
  bool _isConnectingGoogle = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthStorage.getAccessToken();
    setState(() => _authenticated = token != null && token.isNotEmpty);
  }

  Future<void> _connectGoogle() async {
    if (_isConnectingGoogle) return;

    setState(() => _isConnectingGoogle = true);

    try {
      final response = await ApiCaller.get('/api/google/connect');
      final connectUrl = _extractConnectUrl(response);

      if (connectUrl == null || connectUrl.isEmpty) {
        _showMessage(_extractErrorMessage(response) ?? 'Google connect URL was not returned by the server.');
        return;
      }

      final uri = Uri.tryParse(connectUrl);
      if (uri == null) {
        _showMessage('Google connect URL is invalid.');
        return;
      }

      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        _showMessage('Could not open the Google authorization page.');
      }
    } catch (_) {
      _showMessage('Unable to start Google connection.');
    } finally {
      if (mounted) {
        setState(() => _isConnectingGoogle = false);
      }
    }
  }

  String? _extractConnectUrl(String responseBody) {
    final decoded = jsonDecode(responseBody);

    if (decoded is Map<String, dynamic>) {
      final url = decoded['url'];
      if (url is String && url.isNotEmpty) {
        return url;
      }
    }

    return null;
  }

  String? _extractErrorMessage(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);

      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'] ?? decoded['message'] ?? decoded['detail'];
        if (error is String && error.isNotEmpty) {
          return error;
        }
      }
    } catch (_) {
      // Ignore parse errors here; the caller will use a generic fallback.
    }

    return null;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NOVA')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Choose an option', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _ModuleCard(
                  icon: Icons.task,
                  label: 'Tasks',
                  onTap: () => Navigator.of(context).pushNamed(Routes.tasks),
                ),
                _ModuleCard(
                  icon: Icons.event_available_outlined,
                  label: 'Events',
                  onTap: () => Navigator.of(context).pushNamed(Routes.events),
                ),
                _ModuleCard(
                  icon: Icons.school,
                  label: 'Attendance',
                  onTap: () => Navigator.of(context).pushNamed(Routes.attendance),
                ),
                if (_authenticated)
                  _ModuleCard(
                    icon: Icons.mail,
                    label: 'Gmail',
                    isLoading: _isConnectingGoogle,
                    onTap: _connectGoogle,
                  ),
                if (_authenticated)
                  _ModuleCard(
                    icon: Icons.schedule,
                    label: 'Scheduler Test',
                    onTap: () => Navigator.of(context).pushNamed(Routes.schedulerTest),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  const _ModuleCard({required this.icon, required this.label, required this.onTap, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                else
                  Icon(icon, size: 44),
                const SizedBox(height: 12),
                Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
