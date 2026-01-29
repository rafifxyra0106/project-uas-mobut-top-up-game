import 'package:flutter/material.dart';
import '../api/api_service.dart';

const String REGISTER_BG_URL = 'https://rapip.tif-lbj.my.id/uploads/register_bg.jpg';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final api = ApiService();

  final nameC = TextEditingController();
  final usernameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  bool loading = false;
  bool obscure = true;

  @override
  void dispose() {
    nameC.dispose();
    usernameC.dispose();
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  Future<void> doRegister() async {
    final name = nameC.text.trim();
    final username = usernameC.text.trim();
    final email = emailC.text.trim();
    final pass = passC.text;

    if (name.isEmpty || username.isEmpty || email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await api.register(
        name: name,
        username: username,
        email: email,
        password: pass,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Register berhasil, silakan login')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Register gagal: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.black.withOpacity(0.3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            REGISTER_BG_URL,
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
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        const Text(
                          'BUAT AKUN',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),

                        TextField(
                          controller: nameC,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Nama',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.25)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.55)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: usernameC,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.25)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.55)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: emailC,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: const TextStyle(color: Colors.white70),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.25)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.55)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: passC,
                          obscureText: obscure,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(color: Colors.white70),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => obscure = !obscure),
                              icon: Icon(obscure ? Icons.visibility : Icons
                                  .visibility_off, color: Colors.white70),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.25)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: Colors.white.withOpacity(0.55)),
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
                            onPressed: doRegister,
                            child: const Text('DAFTAR'),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Sudah punya akun? Login',
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
