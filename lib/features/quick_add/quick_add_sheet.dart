import 'package:flutter/material.dart';

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Tambah tugas cepat...'),
        onSubmitted: (_) => Navigator.pop(context),
      ),
    );
  }
}