import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../api/api_service.dart';
import '../services/session_service.dart';

class AdminEditGamePage extends StatefulWidget {
  final int id;
  final String initialName;
  final String initialImageUrl;

  const AdminEditGamePage({
    super.key,
    required this.id,
    required this.initialName,
    required this.initialImageUrl,
  });

  @override
  State<AdminEditGamePage> createState() => _AdminEditGamePageState();
}

class _AdminEditGamePageState extends State<AdminEditGamePage> {
  final api = ApiService();
  late final TextEditingController nameC;

  File? newImage;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    nameC = TextEditingController(text: widget.initialName);
  }

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

      setState(() => newImage = File(xf.path));
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

    setState(() => saving = true);

    try {
      final userId = await SessionService.getUserId(); 
      await api.updateGame(
        userId: userId,
        id: widget.id,
        name: name,
        imageFile: newImage, 
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Game berhasil diupdate')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal update game: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Widget previewImage() {
    if (newImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(newImage!, fit: BoxFit.cover),
      );
    }

    if (widget.initialImageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          widget.initialImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
          loadingBuilder: (c, child, p) =>
          p == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    return const Center(child: Text('Tidak ada gambar'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin - Edit Game')),
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
              child: previewImage(),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Klik gambar untuk mengganti (opsional)', style: TextStyle(color: Colors.black54, fontSize: 12)),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: saving
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: const Text('SIMPAN PERUBAHAN'),
            ),
          ),
        ],
      ),
    );
  }
}
