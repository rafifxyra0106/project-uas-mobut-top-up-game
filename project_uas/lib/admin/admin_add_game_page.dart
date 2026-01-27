import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_service.dart';
import '../services/session_service.dart';

class AdminAddGamePage extends StatefulWidget {
  const AdminAddGamePage({super.key});

  @override
  State<AdminAddGamePage> createState() => _AdminAddGamePageState();
}

class _AdminAddGamePageState extends State<AdminAddGamePage> {
  final api = ApiService();
  final nameC = TextEditingController();

  File? pickedImage;
  bool saving = false;

  @override
  void dispose() {
    nameC.dispose();
    super.dispose();
  }

  Future<void> pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? xf = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (xf == null) return;

      setState(() => pickedImage = File(xf.path));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal pilih gambar: $e')),
      );
    }
  }

  Future<void> save() async {
    final name = nameC.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama game wajib diisi')),
      );
      return;
    }
    if (pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar wajib dipilih')),
      );
      return;
    }

    setState(() => saving = true);

    try {
      final userId = await SessionService.getUserId(); // ✅ ambil userId admin
      await api.createGame(
        userId: userId,
        name: name,
        imageFile: pickedImage!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game berhasil ditambahkan')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal tambah game: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Tambah Game')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: nameC,
            decoration: const InputDecoration(
              labelText: 'Nama Game',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: pickFromGallery,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
                color: const Color(0xFFF5F5F5),
              ),
              child: pickedImage == null
                  ? const Center(child: Text('Klik untuk pilih gambar'))
                  : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(pickedImage!, fit: BoxFit.cover),
              ),
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: const Text('SIMPAN'),
            ),
          ),
        ],
      ),
    );
  }
}
