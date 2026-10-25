import 'package:flutter/material.dart';
class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Tugas')), body: const Center(child: Text('Daftar tugas.')));
}