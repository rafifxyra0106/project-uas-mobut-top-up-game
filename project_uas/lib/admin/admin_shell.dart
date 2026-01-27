import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../pages/landing/landing_page.dart';

import 'admin_games_page.dart';
import 'admin_transactions_page.dart';
import 'admin_profile_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int index = 0;

  bool checking = true;
  bool allowed = false;

  // ✅ tambahan: welcome hanya sekali
  bool _welcomed = false;

  @override
  void initState() {
    super.initState();
    _checkRole();
  }

  Future<void> _checkRole() async {
    final role = await SessionService.getRole();
    setState(() {
      allowed = role == 'admin';
      checking = false;
    });

    // ✅ tambahan: kalau admin valid, tampilkan welcome dialog sekali
    if (allowed && !_welcomed) {
      _welcomed = true;

      final name = await SessionService.getName();
      final r = await SessionService.getRole();

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (_) => AlertDialog(
            title: Text('Welcome ${r.toUpperCase()}'),
            content: Text('Halo, $name 👋\nKamu masuk sebagai ADMIN.'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (checking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!allowed) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await SessionService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LandingPage()),
                    (r) => false,
              );
            },
            child: const Text('Admin only - kembali'),
          ),
        ),
      );
    }

    final pages = const [
      AdminGamesPage(),
      AdminTransactionsPage(),
      AdminProfilePage(),
    ];

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Games'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Profil'),
        ],
      ),
    );
  }
}
