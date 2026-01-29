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

  // ✅ Session (untuk "Selamat datang")
  String _name = 'Admin';

  final TextEditingController _searchC = TextEditingController();
  List<dynamic> _filtered = [];

  @override
  void initState() {
    super.initState();
    _loadSession();
    loadGames();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    final n = await SessionService.getName();
    if (!mounted) return;
    setState(() => _name = n);
  }

  Future<void> loadGames() async {
    setState(() => loading = true);
    try {
      final data = await api.fetchGames();
      if (!mounted) return;
      setState(() {
        games = data;
        _filtered = data; 
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load games: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _applySearch(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filtered = games);
      return;
    }

    final out = games.where((x) {
      final g = (x as Map).cast<String, dynamic>();
      final name = (g['name'] ?? '').toString().toLowerCase();
      return name.contains(query);
    }).toList();

    setState(() => _filtered = out);
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
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final userId = await SessionService.getUserId(); // ✅ ambil userId admin
      await api.deleteGame(userId: userId, id: id); // ✅ kirim ke API
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
  
  Widget _sessionCard() {
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
          const Text(
            'Admin Panel',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Selamat datang, $_name',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _searchC,
            onChanged: _applySearch,
            decoration: InputDecoration(
              hintText: 'Cari game...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
            ),
          ),
        ],
      ),
    );
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
          itemCount: _filtered.length + 1, 
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            if (i == 0) return _sessionCard();

            final g = (_filtered[i - 1] as Map).cast<String, dynamic>();
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
                      errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image),
                    ),
                  ),
                ),
                title: Text(name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
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
