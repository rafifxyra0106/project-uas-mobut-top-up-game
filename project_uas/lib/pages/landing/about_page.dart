import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Aplikasi')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Aplikasi TopUp Game berbasis Flutter + API PHP (cPanel).\n\n'
              'Fitur:\n'
              '• Login & Register\n'
              '• List game dari database\n'
              '• Top up (buat transaksi)\n'
              '• Riwayat transaksi\n'
              '• Admin bisa tambah/edit/hapus game + upload gambar',
        ),
      ),
    );
  }
}
