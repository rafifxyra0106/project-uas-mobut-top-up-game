import 'package:flutter/material.dart';
import '../../services/session_service.dart';
import '../../auth/login_page.dart';
import '../../admin/admin_shell.dart';
import '../../user/user_shell.dart';
import 'about_page.dart';
import '../../user/user_shell.dart' show userShellKey;

const String LANDING_BG_URL = 'https://rapip.tif-lbj.my.id/uploads/landing_bg.jpg';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            LANDING_BG_URL,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.black),
          ),
          Container(color: Colors.black.withOpacity(0.58)),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOPUP GAME',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Top up cepat, mudah, dan aman.\nPilih game, isi nominal, dan cek transaksi.',
                          style: TextStyle(color: Colors.white70, height: 1.4),
                        ),
                        const SizedBox(height: 18),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () async {
                              final loggedIn = await SessionService.isLoggedIn();
                              if (!context.mounted) return;

                              if (!loggedIn) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginPage()),
                                );
                                return;
                              }

                              final role = await SessionService.getRole();
                              if (!context.mounted) return;

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => role == 'admin'
                                      ? const AdminShell()
                                      : UserShell(key: userShellKey),
                                ),
                              );
                            },
                            child: const Text('MULAI SEKARANG'),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AboutPage()),
                              );
                            },
                            icon: const Icon(Icons.info_outline, color: Colors.white),
                            label: const Text(
                              'TENTANG APLIKASI',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withOpacity(0.35)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
