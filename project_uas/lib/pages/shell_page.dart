import 'package:flutter/material.dart';
import '../user/home_page.dart';
import 'article_page.dart';
import '../user/history_page.dart';
import '../user/profile_page.dart';
import '../user/help_page.dart';

/// GlobalKey supaya halaman lain bisa ganti tab
final GlobalKey<_ShellPageState> shellKey = GlobalKey();

/// ShellPage: halaman utama berisi BottomNavigationBar
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int index = 0;

  /// pindah ke tab Transaksi
  void goToHistory() => setState(() => index = 2);

  final pages = const [
    HomePage(),
    ArticlePage(),
    HistoryPage(),
    ProfilePage(),
    HelpPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sports_esports), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Artikel'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: 'Bantuan'),
        ],
      ),
    );
  }
}
