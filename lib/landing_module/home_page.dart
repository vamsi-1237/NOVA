import 'package:flutter/material.dart';
import 'package:nova_app/routes/routes.dart';
import 'package:nova_app/utils/auth_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final token = await AuthStorage.getAccessToken();
    setState(() => _authenticated = token != null && token.isNotEmpty);
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

  const _ModuleCard({required this.icon, required this.label, required this.onTap});

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
