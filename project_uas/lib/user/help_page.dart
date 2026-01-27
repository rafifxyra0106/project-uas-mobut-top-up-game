import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bantuan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x11000000)),
            ),
            child: const Text(
              'FAQ\n\n'
                  '• Cara top up?\nPilih game → TOPUP → pilih nominal.\n\n'
                  '• Cek transaksi?\nMenu Transaksi.\n\n'
                  '• Gambar game tidak tampil?\nPastikan URL gambar bisa diakses publik (https).',
            ),
          ),
        ],
      ),
    );
  }
}
