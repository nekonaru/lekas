import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models.dart';
import '../../data/providers.dart';
import '../../domain/search.dart';
import '../../l10n/app_localizations.dart';
import '../kebiasaan/kebiasaan_screen.dart';
import '../spaces/space_detail_screen.dart';
import '../study/flashcard_deck_screen.dart';
import '../tasks/task_detail_screen.dart';

/// One search box over the four local data sets. Results are filtered in
/// memory from a single snapshot, so typing never reads the database.
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen> {
  final _controller = TextEditingController();
  late Future<_Dataset> _data;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<_Dataset> _load() async {
    final tasks = await ref.read(taskRepositoryProvider).getTasks(includeInbox: true);
    final spaces = await ref.read(spaceRepositoryProvider).getSpaces();
    final habits = await ref.read(habitRepositoryProvider).watchActiveHabits().first;
    final cardsRepo = ref.read(flashcardRepositoryProvider);
    final cards = <FlashCard>[
      for (final space in spaces) ...await cardsRepo.cardsOf(space.id),
      ...await cardsRepo.cardsOf(null),
    ];
    return _Dataset(tasks, spaces, habits, cards);
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.globalSearchTitle)),
      body: FutureBuilder<_Dataset>(
        future: _data,
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final query = _query.trim();
          final taskHits = <Task>[];
          final cardHits = <FlashCard>[];
          final habitHits = <Habit>[];
          final spaceHits = <Space>[];
          if (query.isNotEmpty) {
            for (final task in data.tasks) {
              if (matchesQuery('${task.title} ${task.notes ?? ''} ${task.type ?? ''}', query)) {
                taskHits.add(task);
              }
            }
            for (final card in data.cards) {
              if (matchesQuery('${card.front} ${card.back}', query)) {
                cardHits.add(card);
              }
            }
            for (final habit in data.habits) {
              if (matchesQuery(habit.name, query)) habitHits.add(habit);
            }
            for (final space in data.spaces) {
              if (matchesQuery('${space.name} ${space.code ?? ''}', query)) {
                spaceHits.add(space);
              }
            }
          }
          final nameOf = {for (final space in data.spaces) space.id: space.name};
          final empty = query.isNotEmpty &&
              taskHits.isEmpty &&
              cardHits.isEmpty &&
              habitHits.isEmpty &&
              spaceHits.isEmpty;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.globalSearchHint,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: l10n.closeLabel,
                            onPressed: () {
                              _controller.clear();
                              setState(() => _query = '');
                            },
                          ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: empty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.globalSearchNoResults,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                        children: [
                          if (taskHits.isNotEmpty) ...[
                            _section(l10n.globalSearchSectionTasks),
                            for (final task in taskHits.take(20))
                              ListTile(
                                leading: const Icon(Icons.check_circle_outline),
                                title: Text(task.title, maxLines: 1),
                                subtitle: task.notes == null
                                    ? null
                                    : Text(
                                        task.notes!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                onTap: () =>
                                    _push(TaskDetailScreen(taskId: task.id)),
                              ),
                          ],
                          if (cardHits.isNotEmpty) ...[
                            _section(l10n.globalSearchSectionCards),
                            for (final card in cardHits.take(20))
                              ListTile(
                                leading: const Icon(Icons.style_outlined),
                                title: Text(card.front, maxLines: 1),
                                subtitle: Text(
                                  card.spaceId == null
                                      ? '–'
                                      : (nameOf[card.spaceId] ?? '–'),
                                  maxLines: 1,
                                ),
                                onTap: () => _push(FlashcardDeckScreen(
                                  spaceId: card.spaceId,
                                )),
                              ),
                          ],
                          if (habitHits.isNotEmpty) ...[
                            _section(l10n.globalSearchSectionHabits),
                            for (final habit in habitHits.take(20))
                              ListTile(
                                leading: const Icon(
                                  Icons.local_fire_department_outlined,
                                ),
                                title: Text(habit.name),
                                onTap: () => _push(const KebiasaanScreen()),
                              ),
                          ],
                          if (spaceHits.isNotEmpty) ...[
                            _section(l10n.globalSearchSectionSpaces),
                            for (final space in spaceHits.take(20))
                              ListTile(
                                leading: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color(space.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                title: Text(space.name),
                                subtitle: space.code == null
                                    ? null
                                    : Text(space.code!),
                                onTap: () => _push(SpaceDetailScreen(
                                  spaceId: space.id,
                                )),
                              ),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _section(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

class _Dataset {
  const _Dataset(this.tasks, this.spaces, this.habits, this.cards);

  final List<Task> tasks;
  final List<Space> spaces;
  final List<Habit> habits;
  final List<FlashCard> cards;
}
