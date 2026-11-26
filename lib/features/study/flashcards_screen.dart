import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../data/flashcard_repository.dart';
import '../../core/components/empty_state.dart';
import '../../l10n/app_localizations.dart';
import '../../reminders/reminder_service.dart';
import 'flashcard_deck_screen.dart';

/// The study flashcards entry point: one row for the general deck and one
/// row per subject that holds cards, with due counts on every row.
class FlashcardsScreen extends ConsumerStatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  ConsumerState<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

/// Sentinel popped by the deck picker for the general deck, so a plain
/// dismiss (null) stays distinguishable.
const _generalDeck = '__general__';

class _FlashcardsScreenState extends ConsumerState<FlashcardsScreen> {
  late Future<List<DeckSummary>> _decks;

  bool _reminderOn = false;
  int _reminderHour = 19;
  int _reminderMinute = 0;

  @override
  void initState() {
    super.initState();
    _reload();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    final settings = ref.read(settingsRepositoryProvider);
    final on = await settings.get('flashcard_reminder_enabled') == '1';
    final hour = int.tryParse(await settings.get('flashcard_reminder_hour') ?? '');
    final minute =
        int.tryParse(await settings.get('flashcard_reminder_minute') ?? '');
    if (!mounted) return;
    setState(() {
      _reminderOn = on;
      _reminderHour = (hour ?? 19).clamp(0, 23);
      _reminderMinute = (minute ?? 0).clamp(0, 59);
    });
  }

  Future<void> _applyReminder({bool? enabled, TimeOfDay? time}) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final on = enabled ?? _reminderOn;
    final hour = time?.hour ?? _reminderHour;
    final minute = time?.minute ?? _reminderMinute;
    setState(() {
      _reminderOn = on;
      _reminderHour = hour;
      _reminderMinute = minute;
    });

    final settings = ref.read(settingsRepositoryProvider);
    await settings.set('flashcard_reminder_enabled', on ? '1' : '0');
    await settings.set('flashcard_reminder_hour', '$hour');
    await settings.set('flashcard_reminder_minute', '$minute');

    try {
      final service = ref.read(reminderServiceProvider);
      if (on && await service.notificationsEnabled() == false) {
        await service.requestNotificationPermission();
      }
      await service.syncFlashcardReminder(
        enabled: on,
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.flashcardReminderFailed)),
      );
    }
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderHour, minute: _reminderMinute),
    );
    if (picked == null || !mounted) return;
    await _applyReminder(time: picked);
  }

  Widget _reminderCard(AppLocalizations l10n) {
    final colors = Theme.of(context).colorScheme;
    final time = '${_reminderHour.toString().padLeft(2, '0')}:'
        '${_reminderMinute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Material(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(Icons.notifications_outlined, color: colors.primary),
          title: Text(
            l10n.flashcardReminderTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            l10n.flashcardReminderBody,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_reminderOn)
                TextButton(
                  onPressed: _pickReminderTime,
                  child: Text(time),
                ),
              Switch(
                value: _reminderOn,
                onChanged: (value) => _applyReminder(enabled: value),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reload() {
    _decks = ref.read(flashcardRepositoryProvider).summaries();
  }

  /// Shows the deck picker and, once a deck is chosen, the card editor.
  /// Returns nothing when the user backs out of either step.
  Future<void> _addCard(List<Space> spaces) async {
    final l10n = AppLocalizations.of(context)!;
    final pick = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.style_outlined,
                color: Theme.of(sheetContext).colorScheme.primary,
              ),
              title: Text(l10n.generalDeckLabel),
              onTap: () => Navigator.pop(sheetContext, _generalDeck),
            ),
            for (final space in spaces)
              ListTile(
                leading: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Color(space.color),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(space.name),
                onTap: () => Navigator.pop(sheetContext, space.id),
              ),
          ],
        ),
      ),
    );
    if (pick == null || !mounted) return;
    final saved = await showFlashcardEditor(
      context,
      ref,
      spaceId: pick == _generalDeck ? null : pick,
    );
    if (saved && mounted) setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.flashcardsTitle)),
      body: Column(
        children: [
          _reminderCard(l10n),
          Expanded(
            child: StreamBuilder<List<Space>>(
              stream: ref.watch(spaceRepositoryProvider).watchSpaces(),
        builder: (context, spacesSnapshot) {
          final spaces = (spacesSnapshot.data ?? const <Space>[])
              .where((space) => !space.archived)
              .toList();
          final nameOf = {for (final space in spaces) space.id: space};
          return FutureBuilder<List<DeckSummary>>(
            future: _decks,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final decks = snapshot.data ?? const <DeckSummary>[];
              final generalDeck =
                  decks.where((deck) => deck.spaceId == null).firstOrNull;
              final subjectDecks =
                  decks.where((deck) => deck.spaceId != null).toList();

              final rows = <Widget>[
                _DeckTile(
                  title: l10n.generalDeckLabel,
                  color: colors.primary,
                  total: generalDeck?.total ?? 0,
                  due: generalDeck?.due ?? 0,
                  onTap: () => _openDeck(null),
                ),
                for (final deck in subjectDecks)
                  _DeckTile(
                    title: deck.spaceId == null
                        ? l10n.generalDeckLabel
                        : nameOf[deck.spaceId]?.name ?? '?',
                    color: deck.spaceId == null
                        ? colors.primary
                        : Color(nameOf[deck.spaceId]?.color ??
                            colors.primary.toARGB32()),
                    total: deck.total,
                    due: deck.due,
                    onTap: () => _openDeck(deck.spaceId),
                  ),
              ];

              if (decks.isEmpty) {
                return Column(
                  children: [
                    Expanded(
                      child: EmptyState(
                        message: l10n.emptyDecksBody,
                        icon: Icons.style_outlined,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 88),
                      child: FilledButton.icon(
                        onPressed: () => _addCard(spaces),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addFlashcard),
                      ),
                    ),
                  ],
                );
              }

              return RefreshIndicator(
                onRefresh: () async => setState(_reload),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => rows[index],
                ),
              );
            },
          );
        },
          ),
        ),
        ],
      ),
      floatingActionButton: StreamBuilder<List<Space>>(
        stream: ref.watch(spaceRepositoryProvider).watchSpaces(),
        builder: (context, snapshot) {
          final spaces = (snapshot.data ?? const <Space>[])
              .where((space) => !space.archived)
              .toList();
          return FloatingActionButton.extended(
            onPressed: () => _addCard(spaces),
            icon: const Icon(Icons.add),
            label: Text(l10n.addFlashcard),
          );
        },
      ),
    );
  }

  Future<void> _openDeck(String? spaceId) async {
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => FlashcardDeckScreen(spaceId: spaceId),
      ),
    );
    if (mounted) setState(_reload);
  }
}

class _DeckTile extends StatelessWidget {
  const _DeckTile({
    required this.title,
    required this.color,
    required this.total,
    required this.due,
    required this.onTap,
  });

  final String title;
  final Color color;
  final int total;
  final int due;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(Icons.style_outlined, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(l10n.deckDueSummary(due, total)),
        trailing: due > 0
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$due',
                  style: TextStyle(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
