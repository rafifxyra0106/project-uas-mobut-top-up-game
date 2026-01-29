import 'package:flutter/material.dart';
import 'pages/landing/landing_page.dart';

void main() {
  runApp(const TopUpGameApp());
}

class TopUpGameApp extends StatelessWidget {
  const TopUpGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TopUp Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const LandingPage(), 
    );
  }
}
