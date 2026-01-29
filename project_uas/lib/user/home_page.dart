import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../services/session_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final api = ApiService();
  bool loading = true;
  List<dynamic> games = [];

  // ✅ tambahan: data session untuk header
  String _name = 'User';
  String _role = 'user';

  // optional search (kalau kamu mau)
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
    final name = await SessionService.getName();
    final role = await SessionService.getRole();
    if (!mounted) return;
    setState(() {
      _name = name;
      _role = role;
    });
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
    setState(() {
      _filtered = games.where((x) {
        final g = (x as Map).cast<String, dynamic>();
        final name = (g['name'] ?? '').toString().toLowerCase();
        return name.contains(query);
      }).toList();
    });
  }

  Future<void> doTopUp(int gameId, String gameName) async {
    final userId = await SessionService.getUserId();
    if (userId <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID tidak valid, login ulang')),
      );
      return;
    }

    final nominal = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pilih nominal ($gameName)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('10.000'),
              onTap: () => Navigator.pop(context, 10000),
            ),
            ListTile(
              title: const Text('20.000'),
              onTap: () => Navigator.pop(context, 20000),
            ),
            ListTile(
              title: const Text('50.000'),
              onTap: () => Navigator.pop(context, 50000),
            ),
          ],
        ),
      ),
    );

    if (nominal == null) return;

    try {
      await api.createTransaction(userId: userId, gameId: gameId, nominal: nominal);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Transaksi dibuat: $gameName - Rp $nominal')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal topup: $e')),
      );
    }
  }

  // ✅ tambahan: header “Selamat datang, Zidan”
  Widget _header() {
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
          Text(
            'TopUp Game',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            'Selamat datang, $_name',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 2),
          Text(
            'Role: ${_role.toUpperCase()}',
            style: const TextStyle(color: Colors.black45, fontSize: 12),
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
        title: const Text('Games'),
        actions: [
          IconButton(onPressed: loadGames, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: loadGames,
        child: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _filtered.length + 1, // +1 header
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            if (i == 0) return _header();

            final g = (_filtered[i - 1] as Map).cast<String, dynamic>();
            final id = (g['id'] as num).toInt();
            final name = g['name']?.toString() ?? '-';
            final imageUrl = g['image_url']?.toString() ?? '';

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x11000000)),
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
                          const Text(
                            'Klik TOPUP untuk buat transaksi',
                            style: TextStyle(fontSize: 12, color: Colors.black54),
                          ),
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
