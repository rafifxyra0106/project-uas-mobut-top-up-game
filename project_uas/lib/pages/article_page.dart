import 'package:flutter/material.dart';

/// ArticlePage: dummy artikel
class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    final articles = const [
      'Tips Aman Top Up: cek nominal, akun resmi, simpan bukti.',
      'Promo Mingguan: pantau promo untuk diskon/bonus.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Artikel')),
      body: ListView.builder(
        itemCount: articles.length,
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.article),
          title: Text(articles[i]),
        ),
      ),
    );
  }
}
