import 'package:flutter/material.dart';

class ShareIntakeScreen extends StatelessWidget {
  const ShareIntakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bagikan ke Lekas')),
      body: const Center(child: Text('Calon tugas dari teks/gambar.')),
    );
  }
}