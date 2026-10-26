import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

class ClassScheduleScreen extends ConsumerStatefulWidget {
  final String spaceId;
  const ClassScheduleScreen({super.key, required this.spaceId});

  @override
  ConsumerState<ClassScheduleScreen> createState() => _ClassScheduleScreenState();
}

class _ClassScheduleScreenState extends ConsumerState<ClassScheduleScreen> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();
  final _roomController = TextEditingController();

  int _selectedWeekday = 1;

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final repo = ref.watch(classSlotRepositoryProvider);
    final weekdays = [
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
      l10n.sunday,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.classScheduleTitle)),
      body: FutureBuilder<List<ClassSlot>>(
        future: repo.getClassSlots(widget.spaceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final slots = snapshot.data ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    DropdownButton<int>(
                      value: _selectedWeekday,
                      items: weekdays.asMap().entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key + 1,
                          child: Text(e.value),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _selectedWeekday = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _startController,
                      decoration: InputDecoration(labelText: l10n.startTimeLabel),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _endController,
                      decoration: InputDecoration(labelText: l10n.endTimeLabel),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _roomController,
                      decoration: InputDecoration(labelText: l10n.roomLabel),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(l10n.cancel),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            final startParts = _startController.text.split(':');
                            final endParts = _endController.text.split(':');
                            await repo.insertClassSlot(ClassSlot(
                              id: const Uuid().v4(),
                              spaceId: widget.spaceId,
                              weekday: _selectedWeekday,
                              startMin: int.parse(startParts[0]) * 60 + int.parse(startParts[1]),
                              endMin: int.parse(endParts[0]) * 60 + int.parse(endParts[1]),
                              kind: 'lecture',
                              room: _roomController.text.isEmpty ? null : _roomController.text,
                              updatedAt: DateTime.now().millisecondsSinceEpoch,
                            ));
                            if (mounted) setState(() {});
                          },
                          child: Text(l10n.addLabel),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: slots.isEmpty
                    ? Center(child: Text(l10n.emptyClassSchedule))
                    : ListView.builder(
                        itemCount: slots.length,
                        itemBuilder: (context, index) {
                          final slot = slots[index];
                          final start = DateUtil.formatTime(
                            DateTime(2026, 1, 1, slot.startMin ~/ 60, slot.startMin % 60),
                            locale);
                          final end = DateUtil.formatTime(
                            DateTime(2026, 1, 1, slot.endMin ~/ 60, slot.endMin % 60),
                            locale);
                          return ListTile(
                            title: Text('${weekdays[slot.weekday - 1]}: $start - $end'),
                            subtitle: Text(slot.room ?? '-'),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
