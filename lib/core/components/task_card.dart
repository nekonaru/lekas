import 'package:flutter/material.dart';

class TaskCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  const TaskCard({super.key, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}