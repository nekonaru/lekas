import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

class QuickAddBanyakBarisScreen extends ConsumerStatefulWidget {
  const QuickAddBanyakBarisScreen({super.key});

  @override
  ConsumerState<QuickAddBanyakBarisScreen> createState() => _QuickAddBanyakBarisScreenState();
}

class _QuickAddBanyakBarisScreenState extends ConsumerState<QuickAddBanyakBarisScreen> {
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.multiLineQuickAddTitle)),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _textController,
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  labelText: l10n.pasteMultipleLinesLabel,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                if (_textController.text.isEmpty) return;
                final lines = _textController.text.split('\n');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.tasksWillBeCreated(lines.length))),
                );
              },
              child: Text(l10n.createTasks),
            ),
          ),
        ],
      ),
    );
  }
}
