import 'package:flutter/material.dart';
import '../services/session_service.dart';
import '../pages/landing/landing_page.dart';

import 'home_page.dart';
import 'history_page.dart';
import 'profile_page.dart';
import 'help_page.dart';

final GlobalKey<_UserShellState> userShellKey = GlobalKey<_UserShellState>();

class UserShell extends StatefulWidget {
  const UserShell({super.key});

  @override
  State<UserShell> createState() => _UserShellState();
}

class _UserShellState extends State<UserShell> {
  int index = 0;

  void goToHistory() => setState(() => index = 2);

  final pages = const [
    HomePage(),
    _ArticleInline(),
    HistoryPage(),
    ProfilePage(),
    HelpPage(),
  ];

  // ✅ tambahan: session check + welcome (muncul sekali)
  bool _checkedSession = false;
  bool _welcomed = false;

  @override
  void initState() {
    super.initState();
    _checkSessionAndWelcome();
  }

  Future<void> _checkSessionAndWelcome() async {
    final logged = await SessionService.isLoggedIn();

    if (!mounted) return;

    if (!logged) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LandingPage()),
            (r) => false,
      );
      return;
    }

    setState(() => _checkedSession = true);

    // tampilkan welcome hanya sekali
    if (_welcomed) return;
    _welcomed = true;

    final name = await SessionService.getName();
    final role = await SessionService.getRole();

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
          title: Text('Welcome ${role.toUpperCase()}'),
          content: Text('Halo, $name 👋\nSelamat datang di TopUp Game.'),
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

  @override
  Widget build(BuildContext context) {
    // ✅ tambahan: tunggu session check dulu
    if (!_checkedSession) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: 'Artikel'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Bantuan'),
        ],
      ),
    );
  }
}

class _ArticleInline extends StatelessWidget {
  const _ArticleInline();

  @override
  Widget build(BuildContext context) {
    final items = const [
      {'t': 'Tips Aman Top Up', 'd': 'Cek nominal & simpan bukti transaksi.'},
      {'t': 'Cara Cek Status', 'd': 'Menu Transaksi menampilkan PENDING/PAID.'},
      {'t': 'Gambar Game', 'd': 'Game pakai image.network dari URL uploads hosting.'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Artikel')),
      body: ListView.separated(
        padding: const EdgeInsets.all(14),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final a = items[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x11000000)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a['t']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(a['d']!, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          );
        },
      ),
    );
  }
}
