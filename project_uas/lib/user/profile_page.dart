import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../pages/landing/landing_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '-';
  String role = '-';

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    name = await SessionService.getName();
    role = await SessionService.getRole();
    if (mounted) setState(() {});
  }

  Future<void> logout() async {
    await SessionService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
          (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 52, child: Icon(Icons.person, size: 52)),
            const SizedBox(height: 12),
            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Role: $role', style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('LOGOUT', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
