import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../services/session_service.dart';
import 'user_shell.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ApiService();
  bool loading = true;
  List<dynamic> games = [];

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  Future<void> loadGames() async {
    setState(() => loading = true);
    try {
      final data = await api.fetchGames();
      if (!mounted) return;
      setState(() => games = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal load games: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<int?> pickNominal(String gameName) async {
    return showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pilih nominal ($gameName)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: const Text('10.000'), onTap: () => Navigator.pop(context, 10000)),
            ListTile(title: const Text('20.000'), onTap: () => Navigator.pop(context, 20000)),
            ListTile(title: const Text('50.000'), onTap: () => Navigator.pop(context, 50000)),
            ListTile(title: const Text('100.000'), onTap: () => Navigator.pop(context, 100000)),
          ],
        ),
      ),
    );
  }

  Future<void> doTopUp(int gameId, String gameName) async {
    final userId = await SessionService.getUserId();
    if (userId <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User ID tidak valid, login ulang')));
      return;
    }

    final nominal = await pickNominal(gameName);
    if (nominal == null) return;

    try {
      await api.createTransaction(userId: userId, gameId: gameId, nominal: nominal);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi dibuat: $gameName - Rp $nominal')));
      userShellKey.currentState?.goToHistory();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal top up: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Game'),
        actions: [IconButton(onPressed: loadGames, icon: const Icon(Icons.refresh))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadGames,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: games.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final g = (games[i] as Map).cast<String, dynamic>();
            final id = (g['id'] as num).toInt();
            final name = (g['name'] ?? '-').toString();
            final imageUrl = (g['image_url'] ?? '').toString();

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x11000000)),
                boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x14000000), offset: Offset(0, 6))],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
                    child: SizedBox(
                      width: 140,
                      height: 90,
                      child: imageUrl.isEmpty
                          ? const Center(child: Icon(Icons.image_not_supported))
                          : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (c, child, p) => p == null
                            ? child
                            : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          const Text('Klik TOPUP untuk membuat transaksi', style: TextStyle(fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton(
                              onPressed: () => doTopUp(id, name),
                              child: const Text('TOPUP'),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
