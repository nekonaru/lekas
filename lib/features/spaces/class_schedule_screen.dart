import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/providers.dart';
import '../../data/models.dart';
import '../../core/date_util.dart';
import '../../l10n/app_localizations.dart';

/// Minutes since midnight of a typed "HH:mm", or null when the text is not
/// a real time of day. Anything outside 00:00 to 23:59 is refused instead
/// of being parsed into a wild hour that shifts the class window.
int? parseHourMinute(String text) {
  final parts = text.trim().split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0].trim());
  final minute = int.tryParse(parts[1].trim());
  if (hour == null || minute == null) return null;
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return hour * 60 + minute;
}

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

  /// Removes a slot after an explicit confirmation (design section 3.4).
  Future<void> _confirmDelete(ClassSlot slot) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.classScheduleTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.deleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(classSlotRepositoryProvider).deleteClassSlot(slot.id);
    if (mounted) setState(() {});
  }

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
                          onPressed: () {
                            // Clears the slot form without saving.
                            _startController.clear();
                            _endController.clear();
                            _roomController.clear();
                          },
                          child: Text(l10n.cancel),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () async {
                            final startMin =
                                parseHourMinute(_startController.text);
                            final endMin =
                                parseHourMinute(_endController.text);
                            // A half typed "7.30" or "99:99" used to throw
                            // inside int.parse and the slot simply vanished;
                            // a slot is now only saved when both ends are
                            // real minutes of a day and the hour is not
                            // upside down (design section 5.23).
                            if (startMin == null ||
                                endMin == null ||
                                startMin >= endMin) {
                              return;
                            }
                            await repo.insertClassSlot(ClassSlot(
                              id: const Uuid().v4(),
                              spaceId: widget.spaceId,
                              weekday: _selectedWeekday,
                              startMin: startMin,
                              endMin: endMin,
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
                            onTap: () => _confirmDelete(slot),
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
