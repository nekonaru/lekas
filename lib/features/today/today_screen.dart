import 'package:flutter/material.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hari Ini')),
      body: const Center(child: Text('Belum ada tugas hari ini.')),
    );
  }
}