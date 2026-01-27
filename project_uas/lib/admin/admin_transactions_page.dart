import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../services/session_service.dart';

class AdminTransactionsPage extends StatefulWidget {
  const AdminTransactionsPage({super.key});

  @override
  State<AdminTransactionsPage> createState() => _AdminTransactionsPageState();
}

class _AdminTransactionsPageState extends State<AdminTransactionsPage> {
  final api = ApiService();
  bool loading = true;
  List<dynamic> rows = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      // ✅ ambil userId admin dari session
      final userId = await SessionService.getUserId();
      if (userId <= 0) throw Exception('User ID invalid, login ulang');

      // ✅ FIX: kirim userId (named param)
      final data = await api.listAllTransactions(userId: userId);

      if (!mounted) return;
      setState(() => rows = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Semua Transaksi'),
        actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
          ? const Center(child: Text('Belum ada transaksi.'))
          : ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: rows.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final t = (rows[i] as Map).cast<String, dynamic>();
          final game = t['game']?.toString() ?? '-';
          final nominal = t['nominal']?.toString() ?? '0';
          final userName = t['user_name']?.toString() ?? '-';
          final status = t['status']?.toString() ?? '-';
          final createdAt = t['created_at']?.toString() ?? '-';

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x11000000)),
            ),
            child: ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text('$game • Rp $nominal'),
              subtitle: Text('User: $userName • $status • $createdAt'),
            ),
          );
        },
      ),
    );
  }
}
