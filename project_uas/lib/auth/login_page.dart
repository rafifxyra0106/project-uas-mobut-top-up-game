import 'package:flutter/material.dart';
import '../api/api_service.dart';
import '../services/session_service.dart';
import '../pages/landing/landing_page.dart';
import '../admin/admin_shell.dart';
import '../user/user_shell.dart';

import 'register_page.dart';

const String LOGIN_BG_URL = 'https://rapip.tif-lbj.my.id/uploads/login_bgML.jpg';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final api = ApiService();

  final loginC = TextEditingController(); // username/email
  final passC = TextEditingController();

  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    loginC.dispose();
    passC.dispose();
    super.dispose();
  }

  Future<void> doLogin() async {
    final login = loginC.text.trim();
    final pass = passC.text;

    if (login.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username/Email & Password wajib diisi')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      final res = await api.login(login: login, password: pass);

      final user = (res['user'] as Map).cast<String, dynamic>();
      final token = (res['token'] ?? '').toString();

      final userId = (user['id'] as num).toInt();
      final name = (user['name'] ?? 'User').toString();
      final role = (user['role'] ?? 'user').toString();
      
      await SessionService.saveSession(
        userId: userId,
        name: name,
        role: role,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login berhasil: $name (${role.toUpperCase()})')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => role == 'admin' ? const AdminShell() : const UserShell()),
            (r) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> goBackLanding() async {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LandingPage()),
          (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            LOGIN_BG_URL,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: Colors.black),
          ),
          Container(color: Colors.black.withOpacity(0.62)),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.20)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              onPressed: goBackLanding,
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                'LOGIN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        TextField(
                          controller: loginC,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.person, color: Colors.white70),
                            labelText: 'Username atau Email',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.55)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: passC,
                          obscureText: obscure,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock, color: Colors.white70),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => obscure = !obscure),
                              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
                            ),
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: Colors.white.withOpacity(0.55)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: loading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                            onPressed: doLogin,
                            child: const Text('LOGIN'),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterPage()),
                            );
                          },
                          child: const Text(
                            'Belum punya akun? Daftar di sini',
                            style: TextStyle(color: Colors.white),
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
