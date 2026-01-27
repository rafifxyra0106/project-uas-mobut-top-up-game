import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../../services/session_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
      final userId = await SessionService.getUserId();
      if (userId <= 0) throw Exception('User ID tidak valid');

      final data = await api.listTransactions(userId: userId);
      if (!mounted) return;
      setState(() => rows = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal load transaksi: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaksi'),
        actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
          ? const Center(child: Text('Belum ada transaksi'))
          : ListView.builder(
        itemCount: rows.length,
        itemBuilder: (_, i) {
          final t = (rows[i] as Map).cast<String, dynamic>();
          final game = t['game']?.toString() ?? '-';
          final nominal = t['nominal']?.toString() ?? '0';
          final status = t['status']?.toString() ?? '-';
          final created = t['created_at']?.toString() ?? '-';

          return ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text('$game - $nominal'),
            subtitle: Text('$status • $created'),
          );
        },
      ),
    );
  }
}
