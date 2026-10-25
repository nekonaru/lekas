import 'package:flutter/material.dart';

class SpacesScreen extends StatelessWidget {
  const SpacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wadah')),
      body: const Center(child: Text('Belum ada wadah (matkul).')),
    );
  }
}