import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../services/session_service.dart';
import 'admin_add_game_page.dart';
import 'admin_edit_game_page.dart';

class AdminGamesPage extends StatefulWidget {
  const AdminGamesPage({super.key});

  @override
  State<AdminGamesPage> createState() => _AdminGamesPageState();
}

class _AdminGamesPageState extends State<AdminGamesPage> {
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load games: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> goAdd() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminAddGamePage()),
    );
    if (created == true) loadGames();
  }

  Future<void> goEdit(Map<String, dynamic> g) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEditGamePage(
          id: (g['id'] as num).toInt(),
          initialName: (g['name'] ?? '').toString(),
          initialImageUrl: (g['image_url'] ?? '').toString(),
        ),
      ),
    );
    if (updated == true) loadGames();
  }

  Future<void> deleteGame(int id, String name) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus game?'),
        content: Text('Yakin hapus "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final userId = await SessionService.getUserId(); // ✅ ambil userId admin
      await api.deleteGame(userId: userId, id: id);    // ✅ kirim ke API
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game berhasil dihapus')),
      );
      loadGames();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus game: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Kelola Game'),
        actions: [
          IconButton(onPressed: loadGames, icon: const Icon(Icons.refresh)),
          IconButton(onPressed: goAdd, icon: const Icon(Icons.add)),
        ],
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
              ),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 60,
                    height: 50,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.image_not_supported)
                        : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('ID: $id'),
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => goEdit(g),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => deleteGame(id, name),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
